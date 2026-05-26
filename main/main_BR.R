# =============================================================================
# Alerta Dengue Nacional (executável via Rscript + Makim)
# =============================================================================

options(stringsAsFactors = FALSE)

log_msg <- function(..., level = "INFO") {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  msg <- paste0(...)
  cat(sprintf("[%s] [%s] %s\n", ts, level, msg))
}

find_repo_root <- function(start_dir) {
  cur <- normalizePath(start_dir, winslash = "/", mustWork = FALSE)

  for (i in 1:8) {
    has_main <- file.exists(file.path(cur, "main", "main_BR.R"))
    has_cfg1 <- file.exists(file.path(cur, "config", "config_global_2020.R"))
    has_cfg2 <- file.exists(
      file.path(cur, "AlertaDengueAnalise", "config", "config_global_2020.R")
    )

    if (has_main && (has_cfg1 || has_cfg2)) {
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

get_env_any <- function(names, default = NULL) {
  for (nm in names) {
    val <- Sys.getenv(nm, unset = "")
    if (nzchar(val)) {
      return(val)
    }
  }

  default
}

safe_gc <- function() {
  invisible(gc(verbose = FALSE))
}

format_call_stack <- function(max_calls = 20) {
  calls <- sys.calls()
  if (length(calls) == 0) {
    return(character(0))
  }

  calls <- tail(calls, max_calls)
  vapply(calls, function(call) paste(deparse(call), collapse = " "), "")
}

log_call_stack <- function(label) {
  calls <- format_call_stack()
  if (length(calls) == 0) {
    return(invisible(NULL))
  }

  log_msg(label, " stack:", level = "ERROR")
  for (line in calls) {
    log_msg("  ", line, level = "ERROR")
  }

  invisible(NULL)
}

configure_inla_threads <- function() {
  Sys.setenv(
    OMP_NUM_THREADS = "1",
    OPENBLAS_NUM_THREADS = "1",
    MKL_NUM_THREADS = "1",
    BLIS_NUM_THREADS = "1",
    VECLIB_MAXIMUM_THREADS = "1",
    RCPP_PARALLEL_NUM_THREADS = "1",
    NUMEXPR_NUM_THREADS = "1"
  )

  if (!requireNamespace("INLA", quietly = TRUE)) {
    return(invisible(FALSE))
  }

  set_option <- get0(
    "inla.setOption",
    envir = asNamespace("INLA"),
    inherits = FALSE
  )

  if (!is.function(set_option)) {
    log_msg(
      "INLA thread option helper not available; keeping INLA defaults.",
      level = "WARN"
    )
    return(invisible(FALSE))
  }

  ok <- tryCatch(
    {
      set_option(num.threads = "1:1")
      TRUE
    },
    error = function(e) {
      log_msg(
        "Could not set INLA num.threads='1:1': ",
        conditionMessage(e),
        level = "WARN"
      )
      FALSE
    }
  )

  if (ok) {
    log_msg("INLA num.threads set to 1:1")
  }

  invisible(ok)
}

args0 <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args0[grep("^--file=", args0)])
script_dir <- if (length(file_arg)) {
  dirname(normalizePath(file_arg))
} else {
  getwd()
}

repo_root <- find_repo_root(script_dir)
setwd(repo_root)
log_msg("Repo root: ", repo_root)

# Carrega a configuração global do pipeline (lista de estados, funções, libs).
cfg_path <- if (file.exists(file.path(repo_root, "config",
                                     "config_global_2020.R"))) {
  file.path(repo_root, "config", "config_global_2020.R")
} else {
  file.path(repo_root, "AlertaDengueAnalise", "config", "config_global_2020.R")
}
log_msg("Loading config: ", cfg_path)

source(cfg_path)
configure_inla_threads()

# Garante disponibilidade de mclapply (onde rotinas do pipeline usam paralelismo).
if (!exists("mclapply", mode = "function")) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    stop("Missing base R package 'parallel'.", call. = FALSE)
  }

  mclapply <- parallel::mclapply
  log_msg("Enabled parallel::mclapply()")
}

if (!exists("detectCores", mode = "function")) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    stop("Missing base R package 'parallel'.", call. = FALSE)
  }

  detectCores <- parallel::detectCores
  log_msg("Enabled parallel::detectCores()")
}

# Função para resolver o modo de nowcasting, com fallback se INLA não estiver
# disponível.
# has_inla is set by config/config_global_2020.R (TRUE if INLA loaded ok).
check_inla_runtime <- function() {
  if (!requireNamespace("INLA", quietly = TRUE)) {
    return(FALSE)
  }

  if (!requireNamespace("sn", quietly = TRUE)) {
    return(FALSE)
  }

  tryCatch(
    {
      configure_inla_threads()

      suppressPackageStartupMessages(library(INLA))
      suppressPackageStartupMessages(library(sn))

      y <- c(1, 0, 1, 0)
      x <- c(0, 1, 0, 1)

      invisible(
        INLA::inla(
          y ~ x,
          family = "binomial",
          data = data.frame(y = y, x = x),
          control.compute = list(dic = FALSE, waic = FALSE, cpo = FALSE),
          control.predictor = list(compute = FALSE),
          num.threads = "1:1",
          verbose = FALSE
        )
      )

      TRUE
    },
    error = function(e) FALSE
  )
}

has_inla_runtime <- check_inla_runtime()
has_inla_config <- exists("has_inla", inherits = TRUE) && isTRUE(has_inla)
has_inla_flag <- isTRUE(has_inla_config) && isTRUE(has_inla_runtime)
log_msg("INLA available: ", has_inla_flag)

resolve_nowcasting <- function(mode) {
  if (!identical(mode, "bayesian")) {
    return(mode)
  }

  if (!has_inla_flag) {
    log_msg(
      "INLA indisponível: usando nowcasting='none' (fallback).",
      level = "WARN"
    )
    return("none")
  }

  mode
}

report_epiweek <- as.integer(
  get_env_any(
    c("ALERTA_REPORT_EPIWEEK", "ALERTA_DATA_RELATORIO", "report_epiweek"),
    default = NA
  )
)

if (is.na(report_epiweek)) {
  stop("Missing ALERTA_REPORT_EPIWEEK (expected YYYYWW).", call. = FALSE)
}
log_msg("Report epiweek: ", report_epiweek)

report_end_date <- seqSE(report_epiweek, report_epiweek)$Termino
log_msg("Report end date: ", as.character(report_end_date))

window_weeks <- as.integer(
  get_env_any(c("ALERTA_WINDOW_WEEKS"), default = "100")
)

if (is.na(window_weeks) || window_weeks < 1) {
  stop(
    "Invalid ALERTA_WINDOW_WEEKS (expected positive integer).",
    call. = FALSE
  )
}
log_msg("Historical window (weeks): ", window_weeks)

# Diretórios de saída:
# - alertas_dir: RData por estado/semana
# - sql_dir: scripts SQL gerados
# - br_dir: RData agregado nacional (BR)
out_base <- get_env_any(
  c("ALERTA_OUT_DIR"),
  default = file.path(repo_root, "main")
)
alertas_dir <- file.path(out_base, "alertas", as.character(report_epiweek))
sql_dir <- file.path(out_base, "sql")
br_dir <- file.path(out_base, "alertas", "BR")

dir.create(alertas_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(sql_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(br_dir, recursive = TRUE, showWarnings = FALSE)

log_msg("Outputs:")
log_msg(" - alertas_dir: ", alertas_dir)
log_msg(" - sql_dir:     ", sql_dir)
log_msg(" - br_dir:      ", br_dir)

# Parâmetros de conexão ao Postgres (obtidos via ambiente/.env).
db_host <- get_env_any(c("ALERTA_DB_HOST", "DB_HOST"), default = "127.0.0.1")
db_port <- as.integer(
  get_env_any(c("ALERTA_DB_PORT", "DB_PORT"), default = "5432")
)
db_name <- get_env_any(c("ALERTA_DB_NAME", "DB_NAME"), default = "dengue")
db_user <- get_env_any(c("ALERTA_DB_USER", "DB_USER"), default = "")
db_pass <- get_env_any(c("ALERTA_DB_PASSWORD", "DB_PASSWORD"), default = "")

if (!nzchar(db_user) || !nzchar(db_pass)) {
  stop("Missing DB_USER/DB_PASSWORD in env (.env).", call. = FALSE)
}

log_msg(
  "Connecting DB: host=", db_host,
  " port=", db_port,
  " dbname=", db_name,
  " user=", db_user
)

connect_db <- function() {
  DBI::dbConnect(
    drv = RPostgreSQL::PostgreSQL(),
    dbname = db_name,
    host = db_host,
    port = db_port,
    user = db_user,
    password = db_pass
  )
}

# Valida a conexão no processo principal. Cada worker de estado abre sua própria
# conexão para evitar compartilhar um socket de Postgres após fork/mclapply.
con_check <- connect_db()
try(DBI::dbDisconnect(con_check), silent = TRUE)
log_msg("DB connected OK")

# Publicação opcional dos .RData via scp (independente do banco ser local/remoto).
do_scp <- tolower(get_env_any(c("ALERTA_DO_SCP"), default = "0")) %in%
  c("1", "true", "yes", "y")

scp_endpoint_raw <- get_env_any(c("ALERTA_SCP_ENDPOINT"), default = "")
scp_path <- get_env_any(c("ALERTA_SCP_PATH"), default = "")

scp_hostpart <- ""
scp_port <- "22"
scp_target <- ""

if (do_scp) {
  if (!nzchar(scp_endpoint_raw) || !nzchar(scp_path)) {
    stop(
      "SCP habilitado, mas faltam variáveis: ALERTA_SCP_ENDPOINT e/ou ALERTA_SCP_PATH.",
      call. = FALSE
    )
  }

  if (!grepl("/$", scp_path)) {
    scp_path <- paste0(scp_path, "/")
  }

  if (grepl(":[0-9]+$", scp_endpoint_raw)) {
    scp_port <- sub("^.*:([0-9]+)$", "\\1", scp_endpoint_raw)
    scp_hostpart <- sub(":([0-9]+)$", "", scp_endpoint_raw)
  } else {
    scp_hostpart <- scp_endpoint_raw
  }

  scp_target <- paste0(scp_hostpart, ":", scp_path)
  log_msg("SCP habilitado. Destino remoto: ", scp_path)
}

t1 <- Sys.time()

# Filtro de estados (opcional)
states_filter_raw <- get_env_any(c("ALERTA_STATES"), default = "")
states_filter <- character(0)

if (nzchar(states_filter_raw)) {
  states_filter <- unlist(strsplit(states_filter_raw, ",", fixed = TRUE))
  states_filter <- trimws(states_filter)
  states_filter <- toupper(states_filter)
  states_filter <- states_filter[nzchar(states_filter)]
  states_filter <- unique(states_filter)

  invalid_states <- setdiff(states_filter, estados_Infodengue$sigla)
  if (length(invalid_states) > 0) {
    stop(
      "Invalid ALERTA_STATES value(s): ",
      paste(invalid_states, collapse = ", "),
      call. = FALSE
    )
  }

  estados_Infodengue <- estados_Infodengue[
    estados_Infodengue$sigla %in% states_filter,
    ,
    drop = FALSE
  ]

  log_msg(
    "State filter enabled: ",
    paste(states_filter, collapse = ", ")
  )
}

n_states <- nrow(estados_Infodengue)
if (n_states == 0) {
  stop("No states selected for execution.", call. = FALSE)
}

log_msg("Starting pipeline for ", n_states, " state row(s)")

parallel_cores <- as.integer(
  get_env_any(c("ALERTA_PARALLEL_CORES"), default = "1")
)

if (is.na(parallel_cores) || parallel_cores < 1) {
  stop(
    "Invalid ALERTA_PARALLEL_CORES (expected positive integer).",
    call. = FALSE
  )
}

parallel_cores <- min(parallel_cores, n_states)
log_msg("State parallel workers: ", parallel_cores)

combine_ale_parts <- function(parts) {
  parts <- Filter(Negate(is.null), parts)

  if (length(parts) == 0) {
    return(NULL)
  }

  do.call(c, c(parts, recursive = FALSE))
}

run_city_pipeline <- function(city, cid10, now_mode, disease_label, sig) {
  log_msg(
    "[state] ", sig,
    " ", disease_label,
    " city=", city,
    " started"
  )

  result <- tryCatch(
    {
      pipe_infodengue(
        city,
        cid10 = cid10,
        nowcasting = now_mode,
        finalday = report_end_date,
        narule = "arima",
        iniSE = 201001,
        dataini = "sinpri",
        completetail = 0
      )
    },
    error = function(e) {
      log_msg(
        "[state] ", sig,
        " ", disease_label,
        " city=", city,
        " failed: ", conditionMessage(e),
        level = "ERROR"
      )
      NULL
    },
    warning = function(w) {
      log_msg(
        "[state] ", sig,
        " ", disease_label,
        " city=", city,
        " warning: ", conditionMessage(w),
        level = "WARN"
      )
      invokeRestart("muffleWarning")
    }
  )

  if (is.null(result)) {
    log_msg(
      "[state] ", sig,
      " ", disease_label,
      " city=", city,
      " returned no result after fallback execution",
      level = "WARN"
    )
  }

  result
}

run_disease_pipeline_by_city <- function(cidades, cid10, now_mode,
                                         disease_label, sig) {
  log_msg(
    " - ", disease_label,
    ": retrying municipality-level execution after state-level failure"
  )

  ale_parts <- vector("list", length(cidades))

  for (j in seq_along(cidades)) {
    city <- cidades[[j]]
    ale_parts[[j]] <- run_city_pipeline(city, cid10, now_mode, disease_label, sig)
    safe_gc()
  }

  ale <- combine_ale_parts(ale_parts)
  rm(ale_parts)
  safe_gc()

  if (is.null(ale)) {
    stop(
      "All municipality executions failed for ", sig,
      " / ", disease_label,
      call. = FALSE
    )
  }

  restab <- tabela_historico(
    ale,
    iniSE = report_epiweek - window_weeks
  )

  list(ale = ale, restab = restab)
}

run_disease_pipeline <- function(cidades, cid10, now_mode, disease_label, sig) {
  tryCatch(
    {
      ale <- pipe_infodengue(
        cidades,
        cid10 = cid10,
        nowcasting = now_mode,
        finalday = report_end_date,
        narule = "arima",
        iniSE = 201001,
        dataini = "sinpri",
        completetail = 0
      )

      restab <- tabela_historico(
        ale,
        iniSE = report_epiweek - window_weeks
      )

      list(ale = ale, restab = restab)
    },
    error = function(e) {
      log_msg(
        "[state] ", sig,
        " ", disease_label,
        " failed in state-level execution: ", conditionMessage(e),
        level = "ERROR"
      )

      log_msg(
        "[state] ", sig,
        " ", disease_label,
        " fallback: municipality-level isolation",
        level = "WARN"
      )

      run_disease_pipeline_by_city(cidades, cid10, now_mode, disease_label, sig)
    }
  )
}

store_disease_result <- function(res, disease_result, ale_key, restab_key) {
  res[[ale_key]] <- disease_result$ale
  res[[restab_key]] <- disease_result$restab
  res
}

run_state_pipeline <- function(i) {
  configure_inla_threads()

  row_i <- estados_Infodengue[i, ]
  estado <- as.character(row_i$estado)
  sig <- as.character(row_i$sigla)
  current_step <- "initializing"

  tryCatch(
    {
      log_msg(sprintf("[state] %d/%d %s (%s)", i, n_states, estado, sig))

      current_step <- "connecting database"
      con <- connect_db()
      assign("con", con, envir = .GlobalEnv)
      on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)
      on.exit(safe_gc(), add = TRUE)

      nomeRData <- paste0("ale-", sig, "-", report_epiweek, ".RData")
      out_rdata <- file.path(alertas_dir, nomeRData)

      current_step <- "loading cities"
      cidades <- getCidades(uf = estado)[, "municipio_geocodigo"]
      if (length(cidades) == 0) {
        stop("No cities returned for state: ", estado, call. = FALSE)
      }

      res <- list()
      now_mode <- resolve_nowcasting("bayesian")

      current_step <- "dengue pipe_infodengue"
      log_msg(" - dengue: running pipe_infodengue (nowcasting=", now_mode, ")")
      if (isTRUE(row_i$dengue)) {
        disease_result <- run_disease_pipeline(
          cidades,
          "A90",
          now_mode,
          "dengue",
          sig
        )
        res <- store_disease_result(res, disease_result, "ale.den", "restab.den")
        rm(disease_result)
        safe_gc()
      } else {
        log_msg(" - dengue: skipped")
      }

      current_step <- "chik pipe_infodengue"
      log_msg(" - chik: running pipe_infodengue (nowcasting=", now_mode, ")")
      if (isTRUE(row_i$chik)) {
        disease_result <- run_disease_pipeline(
          cidades,
          "A92.0",
          now_mode,
          "chik",
          sig
        )
        res <- store_disease_result(
          res,
          disease_result,
          "ale.chik",
          "restab.chik"
        )
        rm(disease_result)
        safe_gc()
      } else {
        log_msg(" - chik: skipped")
      }

      current_step <- "zika pipe_infodengue"
      log_msg(" - zika: running pipe_infodengue (nowcasting=", now_mode, ")")
      if (isTRUE(row_i$zika)) {
        disease_result <- run_disease_pipeline(
          cidades,
          "A92.8",
          now_mode,
          "zika",
          sig
        )
        res <- store_disease_result(
          res,
          disease_result,
          "ale.zika",
          "restab.zika"
        )
        rm(disease_result)
        safe_gc()
      } else {
        log_msg(" - zika: skipped")
      }

      current_step <- "saving state RData"
      save(res, file = out_rdata)
      log_msg("Saved: ", out_rdata)

      rm(res, cidades)
      safe_gc()

      if (do_scp) {
        current_step <- "scp state RData"
        cmd <- paste(
          "scp -P",
          shQuote(scp_port),
          shQuote(out_rdata),
          shQuote(scp_target)
        )
        log_msg("SCP: ", cmd)
        system(cmd)
      }

      out_rdata
    },
    error = function(e) {
      log_msg(
        "[state] failed ", sig,
        " during ", current_step,
        ": ", conditionMessage(e),
        level = "ERROR"
      )

      log_call_stack(paste0("[state] ", sig))
      safe_gc()

      structure(
        list(
          state = sig,
          step = current_step,
          message = conditionMessage(e)
        ),
        class = "state-error"
      )
    }
  )
}

# Execução do pipeline por linha da configuração de estados.
state_outputs <- if (parallel_cores > 1 && n_states > 1) {
  parallel::mclapply(
    seq_len(n_states),
    run_state_pipeline,
    mc.cores = parallel_cores,
    mc.preschedule = FALSE
  )
} else {
  lapply(seq_len(n_states), run_state_pipeline)
}

failed_states <- vapply(state_outputs, inherits, logical(1), "state-error")
failed_try_errors <- vapply(state_outputs, inherits, logical(1), "try-error")
failed_states <- failed_states | failed_try_errors

if (any(failed_states)) {
  failed_outputs <- state_outputs[failed_states]
  failed_labels <- vapply(
    seq_along(failed_outputs),
    function(idx) {
      item <- failed_outputs[[idx]]
      if (inherits(item, "state-error") && !is.null(item$state)) {
        return(item$state)
      }
      estados_Infodengue$sigla[failed_states][[idx]]
    },
    ""
  )

  for (item in failed_outputs) {
    if (inherits(item, "state-error")) {
      log_msg(
        "Failed state summary: state=", item$state,
        " step=", item$step,
        " message=", item$message,
        level = "ERROR"
      )
    }
  }

  stop(
    "State pipeline failed for: ",
    paste(failed_labels, collapse = ", "),
    call. = FALSE
  )
}

t2 <- Sys.time()
log_msg("Pipeline loop finished. Elapsed: ", as.character(t2 - t1))

# Agregação dos resultados salvos em alertas_dir para geração dos outputs finais.
log_msg("Loading .RData outputs from: ", alertas_dir)
file_paths <- list.files(alertas_dir, full.names = TRUE, pattern = "\\.RData$")
if (length(file_paths) == 0) {
  stop("No .RData files found in: ", alertas_dir, call. = FALSE)
}

load_state_result <- function(path) {
  env <- new.env(parent = emptyenv())
  load(path, envir = env)

  if (!exists("res", envir = env, inherits = FALSE)) {
    stop("Missing object 'res' inside: ", path, call. = FALSE)
  }

  env$res
}

append_part <- function(parts, value) {
  if (!is.null(value)) {
    parts[[length(parts) + 1]] <- value
  }

  parts
}

normalize_restab <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  if (is.list(x) && !is.data.frame(x)) {
    return(dplyr::bind_rows(x))
  }

  x
}

normalize_ale <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  tr <- transpose(x)
  data <- dplyr::bind_rows(tr[[1]])
  idx <- dplyr::bind_rows(tr[[2]])

  cbind(data, idx)
}

bind_parts <- function(parts) {
  parts <- Filter(Negate(is.null), parts)

  if (length(parts) == 0) {
    return(NULL)
  }

  dplyr::bind_rows(parts)
}

restab_den_parts <- list()
restab_chik_parts <- list()
restab_zika_parts <- list()
ale_den_parts <- list()
ale_chik_parts <- list()
ale_zika_parts <- list()

for (k in seq_along(file_paths)) {
  res_k <- load_state_result(file_paths[k])

  restab_den_parts <- append_part(
    restab_den_parts,
    normalize_restab(res_k[["restab.den"]])
  )
  restab_chik_parts <- append_part(
    restab_chik_parts,
    normalize_restab(res_k[["restab.chik"]])
  )
  restab_zika_parts <- append_part(
    restab_zika_parts,
    normalize_restab(res_k[["restab.zika"]])
  )

  ale_den_parts <- append_part(
    ale_den_parts,
    normalize_ale(res_k[["ale.den"]])
  )
  ale_chik_parts <- append_part(
    ale_chik_parts,
    normalize_ale(res_k[["ale.chik"]])
  )
  ale_zika_parts <- append_part(
    ale_zika_parts,
    normalize_ale(res_k[["ale.zika"]])
  )

  rm(res_k)
  safe_gc()
}

log_msg("Loaded ", length(file_paths), " result file(s)")

restab_den <- bind_parts(restab_den_parts)
restab_chik <- bind_parts(restab_chik_parts)
restab_zika <- bind_parts(restab_zika_parts)

rm(restab_den_parts, restab_chik_parts, restab_zika_parts)
safe_gc()

# Ajuste de segurança para valores extremos de 'casos_est_max'
cap_max <- function(df) {
  if (is.null(df)) {
    return(NULL)
  }

  if ("casos_est_max" %in% names(df)) {
    df$casos_est_max[df$casos_est_max > 10000] <- NA
  }

  df
}

restab_den <- cap_max(restab_den)
restab_chik <- cap_max(restab_chik)
restab_zika <- cap_max(restab_zika)

# Geração dos arquivos SQL por agravo (quando houver dados).
if (!is.null(restab_den)) {
  out_sql <- file.path(sql_dir, "output_dengue.sql")
  log_msg("Writing SQL dengue: ", out_sql)
  write_alerta(restab_den, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No dengue restab found. Skipping dengue SQL.", level = "WARN")
}

if (!is.null(restab_chik)) {
  out_sql <- file.path(sql_dir, "output_chik.sql")
  log_msg("Writing SQL chik: ", out_sql)
  write_alerta(restab_chik, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No chik restab found. Skipping chik SQL.", level = "WARN")
}

if (!is.null(restab_zika)) {
  out_sql <- file.path(sql_dir, "output_zika.sql")
  log_msg("Writing SQL zika: ", out_sql)
  write_alerta(restab_zika, writetofile = TRUE, arq = out_sql)
} else {
  log_msg("No zika restab found. Skipping zika SQL.", level = "WARN")
}

rm(restab_den, restab_chik, restab_zika)
safe_gc()

ale_den <- bind_parts(ale_den_parts)
ale_chik <- bind_parts(ale_chik_parts)
ale_zika <- bind_parts(ale_zika_parts)

rm(ale_den_parts, ale_chik_parts, ale_zika_parts)
safe_gc()

# Combine all available disease data for the BR consolidated RData.
# Use dplyr::bind_rows so that columns present in some but not all disease
# frames are filled with NA rather than causing an error.
parts_br <- Filter(Negate(is.null), list(ale_den, ale_chik, ale_zika))
d <- if (length(parts_br) > 0) dplyr::bind_rows(parts_br) else NULL

rm(ale_den, ale_chik, ale_zika, parts_br)
safe_gc()

if (is.null(d)) {
  log_msg("No 'ale.*' data found. Skipping BR RData.", level = "WARN")
} else {
  out_br <- file.path(br_dir, paste0("ale-BR-", report_epiweek, ".RData"))
  log_msg("Saving BR RData: ", out_br)
  save(d, file = out_br)
  rm(d)
  safe_gc()
}

log_msg("DONE")
