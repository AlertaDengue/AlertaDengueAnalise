#!/usr/bin/env Rscript

options(repos = c(CRAN = "https://cloud.r-project.org"))
options(Ncpus = 1)

is_installed <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

cran_install <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, is_installed, logical(1))]
  if (length(missing) == 0) return(invisible(TRUE))
  install.packages(missing, dependencies = TRUE, Ncpus = 1)
  still_missing <- missing[!vapply(missing, is_installed, logical(1))]
  if (length(still_missing) > 0) {
    stop(
      "Could not install CRAN packages: ",
      paste(still_missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

github_install <- function(repo, ref = NULL) {
  if (!is_installed("remotes")) {
    install.packages("remotes", Ncpus = 1)
  }
  remotes::install_github(
    repo = repo,
    ref = ref,
    dependencies = TRUE,
    upgrade = "never",
    force = TRUE
  )
  invisible(TRUE)
}

cat("[deps] R version: ", as.character(getRversion()), "\n", sep = "")

conda_prefix <- Sys.getenv("CONDA_PREFIX", unset = "")
if (nzchar(conda_prefix)) {
  inc <- file.path(conda_prefix, "include")
  lib <- file.path(conda_prefix, "lib")
  Sys.setenv(
    CFLAGS = paste0("-I", inc, " ", Sys.getenv("CFLAGS", "")),
    CPPFLAGS = paste0("-I", inc, " ", Sys.getenv("CPPFLAGS", "")),
    LDFLAGS = paste0("-L", lib, " ", Sys.getenv("LDFLAGS", "")),
    PKG_CONFIG_PATH = paste(
      file.path(lib, "pkgconfig"),
      Sys.getenv("PKG_CONFIG_PATH", ""),
      sep = .Platform$path.sep
    ),
    MAKEFLAGS = Sys.getenv("MAKEFLAGS", unset = "-j1")
  )
}

cran_install(c("cgwtools", "zendown"))

cat("[deps] Installing brpop from GitHub (CRAN may not support this R)...\n")
github_install("rfsaldanha/brpop")  # documented install path :contentReference[oaicite:1]{index=1}

cat("[deps] Installing AlertTools from GitHub...\n")
github_install("AlertaDengue/AlertTools")

cat("[deps] Installing ggTimeSeries from GitHub...\n")
github_install("AtherEnergy/ggTimeSeries")

stopifnot(is_installed("brpop"), is_installed("AlertTools"))
cat("[deps] OK: brpop + AlertTools installed and loadable.\n")
