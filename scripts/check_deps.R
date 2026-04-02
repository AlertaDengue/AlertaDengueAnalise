required <- c(
  "foreign", "forecast", "RPostgreSQL", "xtable", "zoo", "tidyverse",
  "assertthat", "futile.logger", "gridExtra", "ggridges", "grid",
  "cgwtools", "DBI", "remotes", "AlertTools", "ggTimeSeries",
  "fs", "miceadds"
)

missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]

if (length(missing) > 0) {
  stop(paste("Missing R packages:", paste(missing, collapse = ", ")))
}

if (requireNamespace("INLA", quietly = TRUE)) {
  cat("OK: INLA available\n")
} else {
  cat("WARN: INLA not installed; nowcasting bayesiano desativado\n")
}

cat("OK: required packages available\n")
