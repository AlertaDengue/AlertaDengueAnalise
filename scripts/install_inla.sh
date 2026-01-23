#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="${1:-}"

if command -v mamba >/dev/null 2>&1; then
  PM="mamba"
elif command -v conda >/dev/null 2>&1; then
  PM="conda"
else
  echo "ERROR: neither 'mamba' nor 'conda' found in PATH" >&2
  exit 127
fi

run_in_env() {
  if [[ -n "${ENV_NAME}" ]]; then
    "${PM}" run -n "${ENV_NAME}" "$@"
  else
    "$@"
  fi
}

run_in_env R -q --vanilla -e '
options(timeout = 1200)
options(repos = c(
  CRAN = "https://cloud.r-project.org",
  INLA = "https://inla.r-inla-download.org/R/stable"
))

install.packages(
  "INLA",
  dependencies = c("Depends", "Imports", "LinkingTo")
)

suppressPackageStartupMessages(library(INLA))
cat("OK: INLA version:", as.character(packageVersion("INLA")), "\n")
'
