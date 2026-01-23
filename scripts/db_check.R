#!/usr/bin/env Rscript

options(warn = 2)

get_env_any <- function(names) {
  for (nm in names) {
    val <- Sys.getenv(nm, unset = "")
    if (nzchar(val)) {
      return(val)
    }
  }
  stop(
    paste0("Missing env var: one of [", paste(names, collapse = ", "), "]"),
    call. = FALSE
  )
}

host <- get_env_any(c("ALERTA_DB_HOST", "DB_HOST"))
port <- as.integer(get_env_any(c("ALERTA_DB_PORT", "DB_PORT")))
dbname <- get_env_any(c("ALERTA_DB_NAME", "DB_NAME"))
user <- get_env_any(c("ALERTA_DB_USER", "DB_USER"))
password <- get_env_any(c("ALERTA_DB_PASSWORD", "DB_PASSWORD"))

con <- DBI::dbConnect(
  drv = RPostgreSQL::PostgreSQL(),
  dbname = dbname,
  host = host,
  port = port,
  user = user,
  password = password
)

on.exit(DBI::dbDisconnect(con), add = TRUE)

ok <- DBI::dbGetQuery(con, "SELECT 1 AS ok;")
stopifnot(nrow(ok) == 1, ok$ok[[1]] == 1)

version <- DBI::dbGetQuery(con, "SELECT version() AS v;")$v[[1]]
cat("OK: connected to Postgres\n")
cat("Server: ", version, "\n", sep = "")
