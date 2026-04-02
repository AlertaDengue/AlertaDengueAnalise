library(testthat)
library(DBI)
library(RPostgreSQL)

num_equal_local <- function(a, b, tol = 1e-9) {
  both_na <- is.na(a) & is.na(b)
  both_na | abs(a - b) <= tol
}

normalize_date_cols_local <- function(df, cols) {
  for (col in cols) {
    if (!col %in% names(df)) {
      next
    }
    if (!inherits(df[[col]], "Date")) {
      df[[col]] <- as.Date(df[[col]])
    }
  }
  df
}

choose_ale_key_for_city_local <- function(res, city_key) {
  preferred <- c("ale.den", "ale.chik", "ale.zika")
  existing <- preferred[preferred %in% names(res)]

  for (key in existing) {
    obj <- res[[key]]
    if (!is.null(obj) && city_key %in% names(obj)) {
      return(key)
    }
  }

  stop(
    "Could not find an ale.* object containing city ",
    city_key,
    call. = FALSE
  )
}

cid10_from_ale_key_local <- function(ale_key) {
  mapping <- c(
    "ale.den" = "A90",
    "ale.chik" = "A92.0",
    "ale.zika" = "A92.8"
  )

  if (!ale_key %in% names(mapping)) {
    stop("Unsupported ale key: ", ale_key, call. = FALSE)
  }

  mapping[[ale_key]]
}

weekly_window_local <- function(data_relatorio, n_weeks = 20L) {
  weeks <- seqSE(201001, as.integer(data_relatorio))$SE
  tail(weeks, n_weeks)
}

get_sql_snapshot_counts_local <- function(con, city, cid10, weeks) {
  year_value <- as.integer(substr(max(weeks), 1, 4))
  week_min <- min(as.integer(substr(sprintf("%06d", weeks), 5, 6)))
  week_max <- max(as.integer(substr(sprintf("%06d", weeks), 5, 6)))

  sql <- paste0(
    "SELECT se_sin_pri, COUNT(*) AS sql_snapshot_count ",
    "FROM \"Municipio\".\"Notificacao\" ",
    "WHERE cid10_codigo = '", cid10, "' ",
    "AND municipio_geocodigo = ", city, " ",
    "AND dt_sin_pri IS NOT NULL ",
    "AND EXTRACT(YEAR FROM dt_sin_pri) = ", year_value, " ",
    "AND se_sin_pri BETWEEN ", week_min, " AND ", week_max, " ",
    "GROUP BY se_sin_pri ",
    "ORDER BY se_sin_pri"
  )

  out <- DBI::dbGetQuery(con, sql)

  if (nrow(out) == 0) {
    return(data.frame(
      SE = integer(),
      sql_snapshot_count = integer()
    ))
  }

  out$SE <- as.integer(
    paste0(year_value, sprintf("%02d", out$se_sin_pri))
  )

  out[, c("SE", "sql_snapshot_count"), drop = FALSE]
}

get_raw_notificacao_rows_local <- function(con, city, cid10) {
  sql <- paste0(
    "SELECT municipio_geocodigo, cid10_codigo, dt_notific, dt_sin_pri, ",
    "dt_digita, se_sin_pri ",
    "FROM \"Municipio\".\"Notificacao\" ",
    "WHERE cid10_codigo = '", cid10, "' ",
    "AND municipio_geocodigo = ", city
  )

  rows <- DBI::dbGetQuery(con, sql)

  normalize_date_cols_local(
    rows,
    c("dt_notific", "dt_sin_pri", "dt_digita")
  )
}

manual_cleaned_counts_local <- function(rows, firstday, lastday, weeks) {
  dd <- rows

  ininotif <- as.numeric(dd$dt_notific - dd$dt_sin_pri)
  wrongdates <- ininotif > 365 | ininotif < 0 | is.na(dd$dt_sin_pri)

  invalid_rows <- dd[wrongdates, , drop = FALSE]
  dd <- dd[!wrongdates, , drop = FALSE]
  dd <- dd[!is.na(dd$dt_digita), , drop = FALSE]
  dd <- dd[
    dd$dt_digita <= lastday & dd$dt_digita >= firstday,
    ,
    drop = FALSE
  ]

  dd$SE <- data2SE(as.character(dd$dt_sin_pri), format = "%Y-%m-%d")
  dd <- dd[dd$SE %in% weeks, , drop = FALSE]

  agg <- aggregate(
    list(manual_pipeline_casos = rep(1L, nrow(dd))),
    by = list(SE = dd$SE),
    FUN = sum
  )

  out <- data.frame(SE = weeks)
  out <- merge(out, agg, by = "SE", all.x = TRUE, sort = TRUE)
  out$manual_pipeline_casos[is.na(out$manual_pipeline_casos)] <- 0L

  list(
    invalid_rows = invalid_rows,
    filtered_rows = dd,
    weekly = out
  )
}

get_getcases_counts_local <- function(
  city,
  con,
  cid10,
  firstday,
  lastday,
  weeks
) {
  old_wd <- getwd()
  tmp_wd <- tempdir()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(tmp_wd)

  gc <- getCases(
    cities = as.numeric(city),
    lastday = lastday,
    firstday = firstday,
    cid10 = cid10,
    dataini = "sinpri",
    completetail = 0,
    type = "all",
    datasource = con
  )

  gc <- gc[gc$SE %in% weeks, , drop = FALSE]

  keep <- c("SE", "casos")
  if ("cas_prov" %in% names(gc)) {
    keep <- c(keep, "cas_prov")
  }

  out <- gc[, keep, drop = FALSE]
  weeks_df <- data.frame(SE = weeks)
  out <- merge(weeks_df, out, by = "SE", all.x = TRUE, sort = TRUE)

  out$casos[is.na(out$casos)] <- 0
  if ("cas_prov" %in% names(out)) {
    out$cas_prov[is.na(out$cas_prov)] <- 0
  }

  out
}

build_weekly_reconciliation_local <- function() {
  result <- ensure_main_br_run()
  params <- result$params

  repo_root <- find_repo_root_local()
  source(file.path(repo_root, "config", "config_global_2020.R"))

  con <- make_real_db_connection()
  on.exit(try(DBI::dbDisconnect(con), silent = TRUE), add = TRUE)

  city_key <- result$preferred_city_key
  city <- as.integer(city_key)

  ale_key <- choose_ale_key_for_city_local(result$res, city_key)
  rest_key <- sub("^ale\\.", "restab.", ale_key)
  cid10 <- cid10_from_ale_key_local(ale_key)

  weeks <- weekly_window_local(params$week, n_weeks = 20L)
  firstday <- SE2date(201001)$ini
  lastday <- seqSE(
    as.integer(params$week),
    as.integer(params$week)
  )$Termino

  sql_snapshot <- get_sql_snapshot_counts_local(
    con = con,
    city = city,
    cid10 = cid10,
    weeks = weeks
  )

  raw_rows <- get_raw_notificacao_rows_local(
    con = con,
    city = city,
    cid10 = cid10
  )

  manual <- manual_cleaned_counts_local(
    rows = raw_rows,
    firstday = firstday,
    lastday = lastday,
    weeks = weeks
  )

  getcases_counts <- get_getcases_counts_local(
    city = city,
    con = con,
    cid10 = cid10,
    firstday = firstday,
    lastday = lastday,
    weeks = weeks
  )

  x <- result$res[[ale_key]][[city_key]]
  x_data <- x$data
  x_data <- x_data[x_data$SE %in% weeks, , drop = FALSE]

  x_sub <- x_data[
    ,
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
  names(x_sub) <- c(
    "SE",
    "alert_casos",
    "tcasesmed",
    "tcasesICmin",
    "tcasesICmax",
    "alert_cas_prov"
  )

  restab <- result$res[[rest_key]]
  restab_city <- restab[
    restab$municipio_geocodigo == city & restab$SE %in% weeks,
    c(
      "SE",
      "municipio_geocodigo",
      "casos",
      "casos_est",
      "casos_est_min",
      "casos_est_max",
      "casprov"
    ),
    drop = FALSE
  ]
  names(restab_city)[names(restab_city) == "casos"] <- "restab_casos"

  comp <- data.frame(SE = weeks)
  comp <- merge(comp, sql_snapshot, by = "SE", all.x = TRUE, sort = TRUE)
  comp <- merge(comp, manual$weekly, by = "SE", all.x = TRUE, sort = TRUE)

  gc <- getcases_counts
  names(gc)[names(gc) == "casos"] <- "getcases_casos"
  if ("cas_prov" %in% names(gc)) {
    names(gc)[names(gc) == "cas_prov"] <- "getcases_cas_prov"
  }

  comp <- merge(comp, gc, by = "SE", all.x = TRUE, sort = TRUE)
  comp <- merge(comp, x_sub, by = "SE", all.x = TRUE, sort = TRUE)
  comp <- merge(comp, restab_city, by = "SE", all.x = TRUE, sort = TRUE)

  num_cols <- setdiff(names(comp), "SE")
  for (col in num_cols) {
    if (is.numeric(comp[[col]]) || is.integer(comp[[col]])) {
      comp[[col]][is.na(comp[[col]])] <- 0
    }
  }

  comp$check_manual_vs_getcases <- (
    comp$manual_pipeline_casos == comp$getcases_casos
  )

  comp$check_getcases_vs_alert <- (
    comp$getcases_casos == comp$alert_casos
  )

  comp$check_getcases_casprov_vs_alert <- (
    comp$getcases_cas_prov == comp$alert_cas_prov
  )

  comp$check_alert_vs_restab_casos <- (
    comp$alert_casos == comp$restab_casos
  )

  comp$check_alert_vs_restab_est <- num_equal_local(
    comp$tcasesmed,
    comp$casos_est
  )

  comp$check_alert_vs_restab_est_min <- num_equal_local(
    comp$tcasesICmin,
    comp$casos_est_min
  )

  comp$check_alert_vs_restab_est_max <- num_equal_local(
    comp$tcasesICmax,
    comp$casos_est_max
  )

  comp$check_alert_vs_restab_casprov <- (
    comp$alert_cas_prov == comp$casprov
  )

  comp$check_all <- (
    comp$check_manual_vs_getcases &
    comp$check_getcases_vs_alert &
    comp$check_getcases_casprov_vs_alert &
    comp$check_alert_vs_restab_casos &
    comp$check_alert_vs_restab_est &
    comp$check_alert_vs_restab_est_min &
    comp$check_alert_vs_restab_est_max &
    comp$check_alert_vs_restab_casprov
  )

  list(
    city = city,
    city_key = city_key,
    ale_key = ale_key,
    cid10 = cid10,
    weeks = weeks,
    sql_snapshot = sql_snapshot,
    manual = manual,
    getcases_counts = getcases_counts,
    x_data = x_data,
    restab_city = restab_city,
    comparison = comp
  )
}

test_that(
  "weekly reconciliation is consistent for raw notificacao, getCases, x$data and restab",
  {
    skip_if_local_main_br_disabled()
    skip_if_db_env_missing()

    rec <- build_weekly_reconciliation_local()
    comp <- rec$comparison

    expect_true(nrow(comp) >= 1)

    all_ok <- all(comp$check_all)

    if (!all_ok) {
      mismatch <- comp[!comp$check_all, , drop = FALSE]
      fail(
        paste(
          c(
            paste("city:", rec$city),
            paste("ale_key:", rec$ale_key),
            paste("cid10:", rec$cid10),
            "",
            capture.output(print(mismatch))
          ),
          collapse = "\n"
        )
      )
    } else {
      succeed()
    }
  }
)

test_that(
  "raw SQL snapshot can differ from cleaned pipeline counts in the selected weeks",
  {
    skip_if_local_main_br_disabled()
    skip_if_db_env_missing()

    rec <- build_weekly_reconciliation_local()
    comp <- rec$comparison

    expect_true(nrow(comp) >= 1)
    expect_true(all(comp$manual_pipeline_casos == comp$getcases_casos))
    expect_true(all(comp$getcases_casos == comp$alert_casos))

    succeed()
  }
)
