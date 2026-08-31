#!/usr/bin/env Rscript

options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  Ncpus = 1
)

ALERTTOOLS_REF <- "9199ac34e066a5617985ce5b73003b47056bcd6d"

is_installed <- function(pkg) {
  requireNamespace(pkg, quietly = TRUE)
}

installed_github_sha <- function(
  pkg,
  is_installed_fn = is_installed,
  package_description_fn = utils::packageDescription
) {
  if (!is_installed_fn(pkg)) {
    return(NULL)
  }

  description <- package_description_fn(pkg)
  sha <- description$RemoteSha
  if (is.null(sha) || length(sha) != 1L || is.na(sha) || !nzchar(sha)) {
    sha <- description$GithubSHA1
  }

  if (is.null(sha) || length(sha) != 1L || is.na(sha) || !nzchar(sha)) {
    return(NULL)
  }

  as.character(sha)
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

github_install <- function(
  pkg,
  repo,
  ref = NULL,
  is_installed_fn = is_installed,
  installed_sha_fn = installed_github_sha,
  install_github_fn = remotes::install_github
) {
  installed <- is_installed_fn(pkg)

  if (installed && is.null(ref)) {
    return(invisible(TRUE))
  }

  if (installed && !is.null(ref)) {
    installed_sha <- installed_sha_fn(pkg)
    if (!is.null(installed_sha) && identical(tolower(installed_sha), tolower(ref))) {
      return(invisible(TRUE))
    }

    cat("[deps] Reinstalling ", pkg, " to match GitHub SHA ", ref, "...\n", sep = "")
  }

  if (!is_installed("remotes")) {
    install.packages("remotes", Ncpus = 1)
  }

  install_args <- list(
    repo = repo,
    ref = ref,
    dependencies = FALSE,
    upgrade = "never"
  )
  if (installed && !is.null(ref)) {
    install_args$force <- TRUE
  }
  do.call(install_github_fn, install_args)

  if (!is_installed_fn(pkg)) {
    stop(
      "Could not install GitHub package: ",
      pkg,
      call. = FALSE
    )
  }

  if (!is.null(ref)) {
    installed_sha <- installed_sha_fn(pkg)
    if (is.null(installed_sha) || !identical(tolower(installed_sha), tolower(ref))) {
      stop(
        "GitHub package ", pkg, " is not installed at requested SHA ", ref,
        call. = FALSE
      )
    }
  }

  invisible(TRUE)
}

if (sys.nframe() == 0L) {
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
  "sn"
)

cat("[deps] Installing CRAN packages...\n")
cran_install(cran_pkgs)

cat("[deps] Installing brpop from GitHub...\n")
github_install("brpop", "rfsaldanha/brpop")

  cat("[deps] Installing AlertTools from GitHub...\n")
  github_install(
    "AlertTools",
    "AlertaDengue/AlertTools",
    ref = ALERTTOOLS_REF
  )

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
}
