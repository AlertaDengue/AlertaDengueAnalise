required <- c(
  "foreign","forecast","RPostgreSQL","xtable","zoo","tidyverse","assertthat",
  "futile.logger","gridExtra","ggridges","grid","cgwtools","DBI",
  "remotes","AlertTools","ggTimeSeries","INLA"
)

missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  stop(paste("Missing R packages:", paste(missing, collapse = ", ")))
}
cat("OK: required packages available\n")
