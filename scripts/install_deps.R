#!/usr/bin/env Rscript

options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  Ncpus = 1
)

is_installed <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

cran_install <- function(pkgs) {
  missing <- pkgs[!vapply(pkgs, is_installed, logical(1))]
  if (length(missing) == 0) {
    return(invisible(TRUE))
  }

  install.packages(
    missing,
    dependencies = c("Depends", "Imports", "LinkingTo"),
    Ncpus = 1
  )

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

github_install <- function(pkg, repo, ref = NULL) {
  if (is_installed(pkg)) {
    return(invisible(TRUE))
  }

  if (!is_installed("remotes")) {
    install.packages("remotes", Ncpus = 1)
  }

  remotes::install_github(
    repo = repo,
    ref = ref,
    dependencies = FALSE,
    upgrade = "never"
  )

  if (!is_installed(pkg)) {
    stop(
      "Could not install GitHub package: ",
      pkg,
      call. = FALSE
    )
  }

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

cran_pkgs <- c(
  "cgwtools",
  "zendown",
  "fs",
  "sn",
  "brpop"
)

cat("[deps] Installing CRAN packages...\n")
cran_install(cran_pkgs)

cat("[deps] Installing AlertTools from GitHub...\n")
github_install("AlertTools", "AlertaDengue/AlertTools")

cat("[deps] Installing ggTimeSeries from GitHub...\n")
github_install("ggTimeSeries", "AtherEnergy/ggTimeSeries")

required <- c(
  "cgwtools",
  "zendown",
  "fs",
  "sn",
  "brpop",
  "AlertTools",
  "ggTimeSeries"
)

missing_required <- required[
  !vapply(required, is_installed, logical(1))
]

if (length(missing_required) > 0) {
  stop(
    "Missing required packages after installation: ",
    paste(missing_required, collapse = ", "),
    call. = FALSE
  )
}

cat("[deps] OK: required extra packages installed and loadable.\n")
