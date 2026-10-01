#!/usr/bin/env Rscript

# One-time, insert-only dengue and chikungunya history backfill for issue 1129.
# Run with --week YYYYWW; --apply is required for any database write.

targets <- data.frame(
  invalid_geocode = c(2201911L, 2201986L, 2202257L, 2611531L,
                      3117835L, 3152139L, 4305876L, 5203930L, 5203963L),
  municipio_geocodigo = c(2201919L, 2201988L, 2202251L, 2611533L,
                          3117836L, 3152131L, 4305871L, 5203939L, 5203962L),
  municipio_nome = c("Bom Princípio do Piauí", "Brejo do Piauí", "Canavieira",
                     "Quixaba", "Cônego Marinho", "Ponto Chique",
                     "Coronel Barros", "Buriti de Goiás", "Buritinópolis"),
  uf = c("PI", "PI", "PI", "PE", "MG", "MG", "RS", "GO", "GO"),
  start_se = c(201001L, 201001L, 201001L, 201001L, 202124L,
               202124L, 201001L, 201001L, 201001L),
  end_se = rep(202341L, 9L)
)

diseases <- list(
  dengue = list(cid10 = "A90", table = "Historico_alerta",
                constraint = "alertas_unicos"),
  chikungunya = list(cid10 = "A92.0", table = "Historico_alerta_chik",
                     constraint = "alertas_unicos_chik")
)

parse_args <- function(args) {
  if (length(args) == 2L && identical(args[[1L]], "--week")) {
    apply <- FALSE
  } else if (length(args) == 3L && identical(args[[1L]], "--week") &&
             identical(args[[3L]], "--apply")) {
    apply <- TRUE
  } else {
    stop("Usage: Rscript scripts/backfill_exceptional_historico.R --week YYYYWW [--apply]",
         call. = FALSE)
  }
  if (!grepl("^[0-9]{6}$", args[[2L]])) {
    stop("--week must be YYYYWW", call. = FALSE)
  }
  list(week = as.integer(args[[2L]]), apply = apply)
}

calendar_weeks <- function(start_se, end_se) {
  weeks <- AlertTools::seqSE(start_se, end_se)$SE
  if (!length(weeks) || anyNA(weeks) || weeks[[1L]] != start_se ||
      tail(weeks, 1L) != end_se) {
    stop("Target epiweek is outside the AlertTools calendar", call. = FALSE)
  }
  as.integer(weeks)
}

validate_rows <- function(rows, target, disease) {
  weeks <- calendar_weeks(target$start_se, target$end_se)
  required <- c("SE", "municipio_geocodigo", "CID10", "Localidade_id", "data_iniSE")
  if (!is.data.frame(rows) || !all(required %in% names(rows)) ||
      nrow(rows) != length(weeks) || anyNA(rows[, required]) ||
      any(rows$municipio_geocodigo != target$municipio_geocodigo) ||
      any(rows$CID10 != disease$cid10) || any(rows$Localidade_id != 0L) ||
      any(rows$SE < target$start_se | rows$SE > target$end_se) ||
      anyDuplicated(rows[c("SE", "municipio_geocodigo", "Localidade_id")]) ||
      !setequal(as.integer(rows$SE), weeks) ||
      min(rows$SE) != target$start_se || max(rows$SE) != target$end_se) {
    details <- if (is.data.frame(rows) && all(required %in% names(rows))) {
      paste0(" expected=", length(weeks), " generated=", nrow(rows),
             " first=", if (nrow(rows)) min(rows$SE) else "none",
             " last=", if (nrow(rows)) max(rows$SE) else "none",
             " missing_weeks=", paste(head(setdiff(weeks, rows$SE), 5L), collapse = ","),
             " extra_weeks=", paste(head(setdiff(rows$SE, weeks), 5L), collapse = ","))
    } else " missing required columns"
    stop("Invalid generated coverage for municipality ", target$municipio_geocodigo,
         details, call. = FALSE)
  }
  expected_dates <- AlertTools::SE2date(as.integer(rows$SE))$ini
  if (anyNA(expected_dates) || anyNA(as.Date(rows$data_iniSE)) ||
      !identical(as.Date(rows$data_iniSE), as.Date(expected_dates))) {
    stop("Invalid data_iniSE for municipality ", target$municipio_geocodigo,
         call. = FALSE)
  }
  invisible(TRUE)
}

validate_existing_dates <- function(rows, target, disease) {
  if (!nrow(rows)) return(invisible(TRUE))
  expected <- as.Date(AlertTools::SE2date(as.integer(rows$SE))$ini)
  actual <- as.Date(rows$data_iniSE)
  bad <- which(is.na(expected) | is.na(actual) | actual != expected)
  if (length(bad)) {
    stop("Invalid existing data_iniSE in ", disease$table, " (", disease$cid10,
         ") for municipality ", target$municipio_geocodigo,
         " SE ", rows$SE[[bad[[1L]]]], call. = FALSE)
  }
  invisible(TRUE)
}

existing_rows <- function(con, target, disease) {
  rows <- DBI::dbGetQuery(con, paste0(
    'SELECT "SE", municipio_geocodigo, "Localidade_id", "data_iniSE", ',
    'xmin::text AS row_version FROM "Municipio"."', disease$table,
    '" WHERE municipio_geocodigo = ',
    target$municipio_geocodigo, ' AND "SE" BETWEEN ', target$start_se,
    ' AND ', target$end_se, ' AND "Localidade_id" = 0 ORDER BY "SE"'
  ))
  validate_existing_dates(rows, target, disease)
  rows
}

missing_rows <- function(rows, existing) {
  rows[!(as.integer(rows$SE) %in% as.integer(existing$SE)), , drop = FALSE]
}

insert_columns <- c(
  '"SE"', '"data_iniSE"', 'casos_est', 'casos_est_min', 'casos_est_max',
  'casos', 'casprov', 'municipio_geocodigo', 'p_rt1', 'p_inc100k',
  '"Localidade_id"', 'nivel', 'id', 'versao_modelo', 'municipio_nome',
  '"Rt"', 'pop', 'tempmin', 'tempmed', 'tempmax', 'umidmin', 'umidmed',
  'umidmax', 'receptivo', 'transmissao', 'nivel_inc'
)
source_columns <- c(
  'SE', 'data_iniSE', 'casos_est', 'casos_est_min', 'casos_est_max',
  'casos', 'casprov', 'municipio_geocodigo', 'p_rt1', 'p_inc100k',
  'Localidade_id', 'nivel', 'id', 'versao_modelo', 'municipio_nome',
  'Rt', 'pop', 'temp_min', 'temp_med', 'temp_max', 'umid_min', 'umid_med',
  'umid_max', 'receptivo', 'transmissao', 'nivel_inc'
)

insert_sql <- function(con, row, disease,
                       quote_string = function(x) DBI::dbQuoteString(con, x)) {
  if (nrow(row) != 1L || !all(source_columns %in% names(row))) {
    stop("Incomplete historical row", call. = FALSE)
  }
  values <- vapply(source_columns, function(name) {
    value <- row[[name]][[1L]]
    if (is.na(value) || (is.numeric(value) && !is.finite(value))) {
      return("NULL")
    }
    as.character(quote_string(as.character(value)))
  }, character(1L))
  paste0('INSERT INTO "Municipio"."', disease$table, '" (',
         paste(insert_columns, collapse = ", "), ') VALUES (',
         paste(values, collapse = ", "),
         ') ON CONFLICT ON CONSTRAINT ', disease$constraint, ' DO NOTHING')
}

preflight <- function(con) {
  codes <- paste(targets$municipio_geocodigo, collapse = ",")
  invalid <- paste(targets$invalid_geocode, collapse = ",")
  refs <- DBI::dbGetQuery(con, paste0(
    'SELECT geocodigo FROM "Dengue_global"."Municipio" WHERE geocodigo IN (', codes, ')'
  ))
  absent <- setdiff(targets$municipio_geocodigo, refs$geocodigo)
  if (length(absent)) stop("Missing municipality references: ", paste(absent, collapse = ", "))
  old <- DBI::dbGetQuery(con, paste0(
    'SELECT municipio_geocodigo, COUNT(*) AS n FROM "Municipio"."Notificacao" ',
    'WHERE municipio_geocodigo IN (', invalid, ') GROUP BY municipio_geocodigo'
  ))
  if (nrow(old)) {
    print(old, row.names = FALSE)
    stop("Notifications remain under invalid geocodes", call. = FALSE)
  }
  for (name in names(diseases)) {
    disease <- diseases[[name]]
    source <- DBI::dbGetQuery(con, paste0(
      'SELECT municipio_geocodigo, COUNT(*) AS n FROM "Municipio"."Notificacao" ',
      "WHERE cid10_codigo = '", disease$cid10, "' AND municipio_geocodigo IN (", codes,
      ') GROUP BY municipio_geocodigo'
    ))
    absent <- setdiff(targets$municipio_geocodigo, source$municipio_geocodigo)
    if (length(absent)) {
      stop("No source ", name, " (", disease$cid10, ") notifications for: ",
           paste(absent, collapse = ", "), call. = FALSE)
    }
  }
}

nowcasting_mode <- function() {
  if (!isTRUE(has_inla) || !requireNamespace("INLA", quietly = TRUE) ||
      !requireNamespace("sn", quietly = TRUE)) return("none")
  Sys.setenv(OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1",
             MKL_NUM_THREADS = "1", BLIS_NUM_THREADS = "1",
             VECLIB_MAXIMUM_THREADS = "1", RCPP_PARALLEL_NUM_THREADS = "1")
  ok <- tryCatch({
    set_option <- get0("inla.setOption", envir = asNamespace("INLA"),
                       inherits = FALSE)
    if (is.function(set_option)) set_option(num.threads = "1:1")
    suppressPackageStartupMessages(library(INLA))
    suppressPackageStartupMessages(library(sn))
    INLA::inla(y ~ x, family = "binomial",
               data = data.frame(y = c(1, 0, 1, 0), x = c(0, 1, 0, 1)),
               control.compute = list(dic = FALSE, waic = FALSE, cpo = FALSE),
               control.predictor = list(compute = FALSE),
               num.threads = "1:1", verbose = FALSE)
    TRUE
  }, error = function(e) FALSE)
  if (isTRUE(ok)) "bayesian" else "none"
}

db_setting <- function(primary, legacy, default = "") {
  value <- Sys.getenv(primary, unset = "")
  if (!nzchar(value)) value <- Sys.getenv(legacy, unset = "")
  if (nzchar(value)) value else default
}

run_backfill <- function(week, apply = FALSE) {
  file_arg <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  repo_root <- normalizePath(file.path(dirname(file_arg[[1L]]), ".."))
  source(file.path(repo_root, "config", "config_global_2020.R"))
  report_calendar <- calendar_weeks(week, week)
  report_end_date <- AlertTools::seqSE(report_calendar, report_calendar)$Termino[[1L]]
  host <- db_setting("ALERTA_DB_HOST", "DB_HOST", "127.0.0.1")
  port <- as.integer(db_setting("ALERTA_DB_PORT", "DB_PORT", "5432"))
  dbname <- db_setting("ALERTA_DB_NAME", "DB_NAME", "dengue")
  user <- db_setting("ALERTA_DB_USER", "DB_USER")
  password <- db_setting("ALERTA_DB_PASSWORD", "DB_PASSWORD")
  if (!nzchar(user) || !nzchar(password) || is.na(port)) stop("Missing/invalid DB connection settings")
  cat("report_week=", week, " report_end_date=", as.character(report_end_date),
      " database=", host, ":", port, "/", dbname,
      " mode=", if (apply) "APPLY" else "DRY-RUN", "\n", sep = "")
  con <- DBI::dbConnect(RPostgreSQL::PostgreSQL(), dbname = dbname,
                       host = host, port = port, user = user, password = password)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  assign("con", con, envir = .GlobalEnv)
  on.exit(rm("con", envir = .GlobalEnv), add = TRUE)
  preflight(con)
  mode <- nowcasting_mode()
  cat("nowcasting=", mode, "\n", sep = "")
  source_firstday <- AlertTools::SE2date(201001)$ini
  scratch <- tempfile("backfill-1129-")
  dir.create(scratch)
  oldwd <- getwd()
  setwd(scratch)
  on.exit({setwd(oldwd); unlink(scratch, recursive = TRUE)}, add = TRUE)
  generated <- list()
  summary <- NULL
  for (name in names(diseases)) {
    disease <- diseases[[name]]
    generated[[name]] <- vector("list", nrow(targets))
    for (i in seq_len(nrow(targets))) {
      target <- targets[i, ]
      cat("Generating ", name, " ", target$municipio_geocodigo,
          " (", target$uf, ")\n", sep = "")
      result <- pipe_infodengue(target$municipio_geocodigo, cid10 = disease$cid10,
        finalday = report_end_date, narule = "arima", iniSE = 201001,
        dataini = "sinpri", completetail = 0, nowcasting = mode,
        firstday = source_firstday)
      rows <- tabela_historico(result, iniSE = target$start_se, lastSE = target$end_se)
      validate_rows(rows, target, disease)
      generated[[name]][[i]] <- rows
      existing <- existing_rows(con, target, disease)
      summary <- rbind(summary, data.frame(
        disease = name, municipio_geocodigo = target$municipio_geocodigo,
        start_se = target$start_se, end_se = target$end_se,
        expected = length(calendar_weeks(target$start_se, target$end_se)),
        generated = nrow(rows), existing = nrow(existing),
        missing = nrow(missing_rows(rows, existing)),
        start_date = min(as.Date(rows$data_iniSE)),
        end_date = max(as.Date(rows$data_iniSE))))
    }
  }
  old_width <- getOption("width")
  options(width = 180)
  print(summary, row.names = FALSE)
  options(width = old_width)
  cat("Totals: expected=", sum(summary$expected), " generated=", sum(summary$generated),
      " existing=", sum(summary$existing), " missing=", sum(summary$missing), "\n", sep = "")
  if (!apply) {
    cat("DRY-RUN: no data changed.\n")
    return(invisible(summary))
  }
  DBI::dbBegin(con)
  committed <- FALSE
  on.exit(if (!committed) DBI::dbRollback(con), add = TRUE)
  inserted <- 0L
  transaction_missing <- 0L
  for (name in names(diseases)) {
    disease <- diseases[[name]]
    for (i in seq_len(nrow(targets))) {
      target <- targets[i, ]
      before <- existing_rows(con, target, disease)
      missing <- missing_rows(generated[[name]][[i]], before)
      transaction_missing <- transaction_missing + nrow(missing)
      for (j in seq_len(nrow(missing))) {
        inserted <- inserted + DBI::dbExecute(con, insert_sql(con, missing[j, , drop = FALSE], disease))
      }
      after <- existing_rows(con, target, disease)
      if (anyDuplicated(after[c("SE", "municipio_geocodigo", "Localidade_id")]) ||
          !identical(as.integer(after$SE), calendar_weeks(target$start_se, target$end_se)) ||
          !identical(before$row_version, after$row_version[match(before$SE, after$SE)]) ||
          (nrow(after) - nrow(before)) != nrow(missing)) {
        stop("Transaction validation failed for ", name, " municipality ",
             target$municipio_geocodigo, call. = FALSE)
      }
    }
  }
  if (inserted != transaction_missing) {
    stop("Inserted count differs from transaction-time missing count", call. = FALSE)
  }
  DBI::dbCommit(con)
  committed <- TRUE
  cat("Backfill committed. inserted=", inserted, "\n", sep = "")
  invisible(summary)
}

if (sys.nframe() == 0L) {
  args <- parse_args(commandArgs(trailingOnly = TRUE))
  run_backfill(args$week, args$apply)
}
