library(testthat)
library(DBI)
library(RPostgreSQL)

main_br_cache <- new.env(parent = emptyenv())

find_repo_root_local <- function(start_dir = getwd()) {
  cur <- normalizePath(start_dir, winslash = "/", mustWork = FALSE)

  for (i in seq_len(8)) {
    has_main <- file.exists(file.path(cur, "main", "main_BR.R"))
    has_cfg <- file.exists(file.path(cur, "config", "config_global_2020.R"))

    if (has_main && has_cfg) {
      return(cur)
    }

    parent <- normalizePath(
      file.path(cur, ".."),
      winslash = "/",
      mustWork = FALSE
    )

    if (identical(parent, cur)) {
      break
    }

    cur <- parent
  }

  stop("Could not locate repo root from: ", start_dir, call. = FALSE)
}

required_db_env <- function() {
  c(
    "ALERTA_DB_HOST",
    "ALERTA_DB_PORT",
    "ALERTA_DB_NAME",
    "ALERTA_DB_USER",
    "ALERTA_DB_PASSWORD"
  )
}

skip_if_local_main_br_disabled <- function() {
  enabled <- identical(
    tolower(Sys.getenv("ALERTA_RUN_LOCAL_INTEGRATION", unset = "false")),
    "true"
  )

  if (!enabled) {
    skip(
      paste(
        "Local integration disabled.",
        "Set ALERTA_RUN_LOCAL_INTEGRATION=true to run."
      )
    )
  }
}

skip_if_db_env_missing <- function() {
  required <- required_db_env()
  missing <- required[Sys.getenv(required, unset = "") == ""]

  if (length(missing) > 0) {
    skip(
      paste(
        "Missing DB env vars:",
        paste(missing, collapse = ", ")
      )
    )
  }
}

make_real_db_connection <- function() {
  DBI::dbConnect(
    drv = RPostgreSQL::PostgreSQL(),
    dbname = Sys.getenv("ALERTA_DB_NAME"),
    host = Sys.getenv("ALERTA_DB_HOST"),
    port = as.integer(Sys.getenv("ALERTA_DB_PORT")),
    user = Sys.getenv("ALERTA_DB_USER"),
    password = Sys.getenv("ALERTA_DB_PASSWORD")
  )
}

local_main_br_params <- function() {
  list(
    repo_root = find_repo_root_local(),
    state_sigla = Sys.getenv("ALERTA_TEST_STATE", unset = "DF"),
    week = Sys.getenv("ALERTA_TEST_WEEK", unset = "202520"),
    preferred_city = Sys.getenv("ALERTA_TEST_CITY", unset = ""),
    expect_nowcast_diff = identical(
      tolower(Sys.getenv("ALERTA_EXPECT_NOWCAST_DIFF", unset = "false")),
      "true"
    )
  )
}

create_main_br_sandbox <- function(repo_root, state_sigla) {
  sandbox_root <- tempfile("main-br-sandbox-")
  dir.create(sandbox_root, recursive = TRUE, showWarnings = FALSE)
  dir.create(
    file.path(sandbox_root, "main"),
    recursive = TRUE,
    showWarnings = FALSE
  )
  dir.create(
    file.path(sandbox_root, "config"),
    recursive = TRUE,
    showWarnings = FALSE
  )

  main_src <- file.path(repo_root, "main", "main_BR.R")
  cfg_src <- file.path(repo_root, "config", "config_global_2020.R")

  main_dst <- file.path(sandbox_root, "main", "main_BR.R")
  cfg_dst <- file.path(sandbox_root, "config", "config_global_2020.R")

  ok_main <- file.copy(main_src, main_dst, overwrite = TRUE)
  ok_cfg <- file.copy(cfg_src, cfg_dst, overwrite = TRUE)

  if (!ok_main || !ok_cfg) {
    stop("Could not copy main/config files into sandbox.", call. = FALSE)
  }

  override <- c(
    "",
    sprintf(
      "estados_Infodengue <- subset(estados_Infodengue, sigla == '%s')",
      state_sigla
    ),
    "if (nrow(estados_Infodengue) != 1) {",
    "  stop('Sandbox config did not isolate exactly one state.',",
    "       call. = FALSE)",
    "}",
    ""
  )

  cat(
    paste(override, collapse = "\n"),
    file = cfg_dst,
    append = TRUE
  )

  sandbox_root
}

run_main_br_script <- function(sandbox_root, week, out_dir) {
  log_file <- tempfile("main-br-log-", fileext = ".log")

  env <- c(
    paste0("ALERTA_DATA_RELATORIO=", week),
    paste0("ALERTA_OUT_DIR=", out_dir),
    paste0("ALERTA_DB_HOST=", Sys.getenv("ALERTA_DB_HOST")),
    paste0("ALERTA_DB_PORT=", Sys.getenv("ALERTA_DB_PORT")),
    paste0("ALERTA_DB_NAME=", Sys.getenv("ALERTA_DB_NAME")),
    paste0("ALERTA_DB_USER=", Sys.getenv("ALERTA_DB_USER")),
    paste0("ALERTA_DB_PASSWORD=", Sys.getenv("ALERTA_DB_PASSWORD")),
    "ALERTA_DO_SCP=false"
  )

  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(sandbox_root)

  status <- system2(
    command = "Rscript",
    args = c("--vanilla", "main/main_BR.R"),
    stdout = log_file,
    stderr = log_file,
    env = env,
    wait = TRUE,
    timeout = 0
  )

  log_lines <- if (file.exists(log_file)) {
    readLines(log_file, warn = FALSE)
  } else {
    character()
  }

  list(
    status = as.integer(status),
    log_file = log_file,
    log_lines = log_lines
  )
}

load_rdata_object <- function(path, object_name) {
  env <- new.env(parent = emptyenv())
  load(path, envir = env)

  if (!exists(object_name, envir = env, inherits = FALSE)) {
    stop(
      "Object '", object_name, "' not found in file: ", path,
      call. = FALSE
    )
  }

  get(object_name, envir = env, inherits = FALSE)
}

get_state_output_paths <- function(out_dir, week, state_sigla) {
  list(
    state_rdata = file.path(
      out_dir,
      "alertas",
      week,
      paste0("ale-", state_sigla, "-", week, ".RData")
    ),
    br_rdata = file.path(
      out_dir,
      "alertas",
      "BR",
      paste0("ale-BR-", week, ".RData")
    ),
    sql_dir = file.path(out_dir, "sql")
  )
}

available_result_keys <- function(res, prefix) {
  keys <- grep(paste0("^", prefix), names(res), value = TRUE)
  keys[!vapply(res[keys], is.null, logical(1))]
}

flatten_ale_object <- function(ale_obj) {
  tr <- purrr::transpose(ale_obj)
  data <- dplyr::bind_rows(tr[[1]])
  idx <- dplyr::bind_rows(tr[[2]])
  cbind(data, idx)
}

build_expected_consolidated_d <- function(res) {
  ale_keys <- available_result_keys(res, "ale\\.")
  parts <- lapply(ale_keys, function(key) {
    flatten_ale_object(res[[key]])
  })

  dplyr::bind_rows(parts)
}

get_preferred_city_key <- function(res, preferred_city = "") {
  ale_keys <- available_result_keys(res, "ale\\.")
  if (length(ale_keys) == 0) {
    stop("No non-null ale.* objects found.", call. = FALSE)
  }

  if (nzchar(preferred_city)) {
    for (key in ale_keys) {
      if (preferred_city %in% names(res[[key]])) {
        return(preferred_city)
      }
    }

    stop(
      "Preferred city not found in any ale.* object: ",
      preferred_city,
      call. = FALSE
    )
  }

  names(res[[ale_keys[[1]]]])[[1]]
}

build_nowcasting_comparison <- function(res, city_key) {
  ale_keys <- available_result_keys(res, "ale\\.")
  out <- list()

  for (ale_key in ale_keys) {
    rest_key <- sub("^ale\\.", "restab.", ale_key)

    ale_obj <- res[[ale_key]]
    restab <- res[[rest_key]]

    if (is.null(ale_obj) || is.null(restab) || !city_key %in% names(ale_obj)) {
      next
    }

    x <- ale_obj[[city_key]]
    x_data <- x$data
    city_restab <- restab[
      restab$municipio_geocodigo == as.integer(city_key),
      ,
      drop = FALSE
    ]

    x_sub <- x_data[
      x_data$SE %in% city_restab$SE,
      c(
        "SE",
        "casos",
        "tcasesmed",
        "tcasesICmin",
        "tcasesICmax",
        "cas_prov"
      ),
      drop = FALSE
    ]

    comp <- merge(
      x_sub,
      city_restab[
        ,
        c(
          "SE",
          "casos",
          "casos_est",
          "casos_est_min",
          "casos_est_max",
          "casprov"
        ),
        drop = FALSE
      ],
      by = "SE",
      suffixes = c("_alert", "_restab"),
      all = FALSE,
      sort = TRUE
    )

    comp$check_casos <- comp$casos_alert == comp$casos_restab
    comp$check_est <- comp$tcasesmed == comp$casos_est
    comp$check_est_min <- comp$tcasesICmin == comp$casos_est_min
    comp$check_est_max <- comp$tcasesICmax == comp$casos_est_max
    comp$check_casprov <- comp$cas_prov == comp$casprov

    comp$check_alert_interval <- (
      comp$tcasesICmin <= comp$tcasesmed &
      comp$tcasesmed <= comp$tcasesICmax
    )

    comp$check_restab_interval <- (
      comp$casos_est_min <= comp$casos_est &
      comp$casos_est <= comp$casos_est_max
    )

    comp$nowcast_adjusted <- abs(comp$casos_est - comp$casos_restab) > 1e-9

    out[[ale_key]] <- comp
  }

  out
}

ensure_main_br_run <- function() {
  if (exists("result", envir = main_br_cache, inherits = FALSE)) {
    return(get("result", envir = main_br_cache, inherits = FALSE))
  }

  skip_if_local_main_br_disabled()
  skip_if_db_env_missing()

  params <- local_main_br_params()
  sandbox_root <- create_main_br_sandbox(
    repo_root = params$repo_root,
    state_sigla = params$state_sigla
  )

  out_dir <- tempfile("main-br-out-")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  run <- run_main_br_script(
    sandbox_root = sandbox_root,
    week = params$week,
    out_dir = out_dir
  )

  paths <- get_state_output_paths(
    out_dir = out_dir,
    week = params$week,
    state_sigla = params$state_sigla
  )

  state_rdata_exists <- file.exists(paths$state_rdata)
  br_rdata_exists <- file.exists(paths$br_rdata)
  sql_dir_exists <- dir.exists(paths$sql_dir)

  if (
    run$status != 0L ||
    !state_rdata_exists ||
    !br_rdata_exists ||
    !sql_dir_exists
  ) {
    stop(
      paste(
        c(
          "main_BR.R local integration failed.",
          paste("status:", run$status),
          paste("sandbox:", sandbox_root),
          paste("out_dir:", out_dir),
          paste("log_file:", run$log_file),
          "",
          run$log_lines
        ),
        collapse = "\n"
      ),
      call. = FALSE
    )
  }

  res <- load_rdata_object(paths$state_rdata, "res")
  d <- load_rdata_object(paths$br_rdata, "d")
  sql_files <- list.files(
    paths$sql_dir,
    pattern = "^output_.*\\.sql$",
    full.names = TRUE
  )

  preferred_city_key <- get_preferred_city_key(
    res = res,
    preferred_city = params$preferred_city
  )

  nowcasting_comparison <- build_nowcasting_comparison(
    res = res,
    city_key = preferred_city_key
  )

  result <- list(
    params = params,
    sandbox_root = sandbox_root,
    out_dir = out_dir,
    run = run,
    paths = paths,
    res = res,
    d = d,
    sql_files = sql_files,
    preferred_city_key = preferred_city_key,
    nowcasting_comparison = nowcasting_comparison
  )

  assign("result", result, envir = main_br_cache)
  result
}
