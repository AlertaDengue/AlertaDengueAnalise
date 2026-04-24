#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-alertadengueanalise}"

if command -v mamba >/dev/null 2>&1; then
  PM="mamba"
else
  PM="conda"
fi

"${PM}" run -n "${ENV_NAME}" R -q --vanilla -e '
options(
  timeout = 1200,
  Ncpus = 1,
  download.file.method = "libcurl"
)

pkg_url <- "https://inla.r-inla-download.org/R/testing/src/contrib/INLA_26.01.26-1.tar.gz"
bin_url <- paste0(
  "https://www.inla.r-inla-download.org/Linux-builds/",
  "CentOS%20Linux-7%20%28Core%29%20%5Bx86_64%5D/",
  "Version_26.01.26-1/64bit.tgz"
)

if (requireNamespace("INLA", quietly = TRUE)) {
  remove.packages("INLA")
}

install.packages(pkg_url, repos = NULL, type = "source")

suppressPackageStartupMessages(library(INLA))
inla_bin_linux <- system.file("bin", "linux", package = "INLA")

tf <- tempfile(fileext = ".tgz")
download.file(bin_url, tf, mode = "wb", quiet = FALSE)

old_dir <- file.path(inla_bin_linux, "64bit")
if (dir.exists(old_dir)) {
  unlink(old_dir, recursive = TRUE, force = TRUE)
}

untar(tf, exdir = inla_bin_linux)

y <- c(1, 0, 1, 0)
x <- c(0, 1, 0, 1)

res <- INLA::inla(
  y ~ x,
  family = "binomial",
  data = data.frame(y = y, x = x),
  control.compute = list(dic = FALSE, waic = FALSE, cpo = FALSE),
  control.predictor = list(compute = FALSE),
  num.threads = 1,
  verbose = FALSE
)

cat("OK: INLA package version:", as.character(packageVersion("INLA")), "\n")
cat("OK: binary installed in:", file.path(inla_bin_linux, "64bit"), "\n")
'
