installer_path <- file.path("..", "..", "scripts", "install_deps.R")

load_installer <- function() {
  installer <- new.env(parent = baseenv())
  source(installer_path, local = installer)
  installer
}

expect_install_args <- function(args, repo, ref, force) {
  expect_equal(args$repo, repo)
  expect_equal(args$ref, ref)
  expect_identical(args$dependencies, FALSE)
  expect_identical(args$upgrade, "never")
  if (is.null(force)) {
    expect_false("force" %in% names(args))
  } else {
    expect_identical(args$force, force)
  }
}

test_that("AlertTools uses the required production SHA", {
  installer <- load_installer()
  expect_identical(installer$ALERTTOOLS_REF, "9199ac34e066a5617985ce5b73003b47056bcd6d")
})

test_that("installed_github_sha uses RemoteSha before GithubSHA1", {
  installer <- load_installer()
  sha <- installer$installed_github_sha(
    "AlertTools",
    is_installed_fn = function(pkg) TRUE,
    package_description_fn = function(pkg) list(
      RemoteSha = "remote-sha",
      GithubSHA1 = "github-sha"
    )
  )

  expect_identical(sha, "remote-sha")
})

test_that("installed_github_sha returns NULL for an absent package", {
  installer <- load_installer()
  sha <- installer$installed_github_sha(
    "AlertTools",
    is_installed_fn = function(pkg) FALSE
  )

  expect_null(sha)
})

test_that("installed_github_sha falls back to GithubSHA1", {
  installer <- load_installer()
  for (remote_sha in list(NULL, NA_character_, "")) {
    sha <- installer$installed_github_sha(
      "AlertTools",
      is_installed_fn = function(pkg) TRUE,
      package_description_fn = function(pkg) list(
        RemoteSha = remote_sha,
        GithubSHA1 = "github-sha"
      )
    )

    expect_identical(sha, "github-sha")
  }
})

test_that("github_install skips a pinned package at the matching RemoteSha", {
  installer <- load_installer()
  install_calls <- 0L

  result <- installer$github_install(
    pkg = "AlertTools",
    repo = "AlertaDengue/AlertTools",
    ref = installer$ALERTTOOLS_REF,
    is_installed_fn = function(pkg) TRUE,
    installed_sha_fn = function(pkg) installer$ALERTTOOLS_REF,
    install_github_fn = function(...) install_calls <<- install_calls + 1L
  )

  expect_true(result)
  expect_equal(install_calls, 0L)
})

test_that("github_install skips a pinned package at the matching GithubSHA1", {
  installer <- load_installer()
  install_calls <- 0L

  result <- installer$github_install(
    pkg = "AlertTools",
    repo = "AlertaDengue/AlertTools",
    ref = installer$ALERTTOOLS_REF,
    is_installed_fn = function(pkg) TRUE,
    installed_sha_fn = function(pkg) installer$installed_github_sha(
      pkg,
      is_installed_fn = function(pkg) TRUE,
      package_description_fn = function(pkg) list(
        RemoteSha = "",
        GithubSHA1 = installer$ALERTTOOLS_REF
      )
    ),
    install_github_fn = function(...) install_calls <<- install_calls + 1L
  )

  expect_true(result)
  expect_equal(install_calls, 0L)
})

test_that("github_install installs an absent pinned package without force", {
  installer <- load_installer()
  installed <- FALSE
  install_args <- NULL

  result <- installer$github_install(
    pkg = "AlertTools",
    repo = "AlertaDengue/AlertTools",
    ref = installer$ALERTTOOLS_REF,
    is_installed_fn = function(pkg) installed,
    installed_sha_fn = function(pkg) if (installed) installer$ALERTTOOLS_REF else NULL,
    install_github_fn = function(...) {
      install_args <<- list(...)
      installed <<- TRUE
    }
  )

  expect_true(result)
  expect_install_args(install_args, "AlertaDengue/AlertTools", installer$ALERTTOOLS_REF, NULL)
})

test_that("github_install replaces a mismatched pinned package with force", {
  installer <- load_installer()
  installed_sha <- "975f3470000000000000000000000000000000000"
  install_args <- NULL

  result <- installer$github_install(
    pkg = "AlertTools",
    repo = "AlertaDengue/AlertTools",
    ref = installer$ALERTTOOLS_REF,
    is_installed_fn = function(pkg) TRUE,
    installed_sha_fn = function(pkg) installed_sha,
    install_github_fn = function(...) {
      install_args <<- list(...)
      installed_sha <<- installer$ALERTTOOLS_REF
    }
  )

  expect_true(result)
  expect_install_args(install_args, "AlertaDengue/AlertTools", installer$ALERTTOOLS_REF, TRUE)
})

test_that("github_install replaces missing pinned SHA metadata with force", {
  installer <- load_installer()
  installed_sha <- NULL
  install_args <- NULL

  result <- installer$github_install(
    pkg = "AlertTools",
    repo = "AlertaDengue/AlertTools",
    ref = installer$ALERTTOOLS_REF,
    is_installed_fn = function(pkg) TRUE,
    installed_sha_fn = function(pkg) installed_sha,
    install_github_fn = function(...) {
      install_args <<- list(...)
      installed_sha <<- installer$ALERTTOOLS_REF
    }
  )

  expect_true(result)
  expect_install_args(install_args, "AlertaDengue/AlertTools", installer$ALERTTOOLS_REF, TRUE)
})

test_that("github_install fails when post-install SHA verification fails", {
  installer <- load_installer()
  install_args <- NULL

  expect_error(
    installer$github_install(
      pkg = "AlertTools",
      repo = "AlertaDengue/AlertTools",
      ref = installer$ALERTTOOLS_REF,
      is_installed_fn = function(pkg) TRUE,
      installed_sha_fn = function(pkg) "wrong-sha",
      install_github_fn = function(...) install_args <<- list(...)
    ),
    "not installed at requested SHA"
  )
  expect_install_args(install_args, "AlertaDengue/AlertTools", installer$ALERTTOOLS_REF, TRUE)
})

test_that("github_install skips an installed unpinned dependency", {
  installer <- load_installer()
  install_calls <- 0L

  result <- installer$github_install(
    pkg = "brpop",
    repo = "rfsaldanha/brpop",
    is_installed_fn = function(pkg) TRUE,
    install_github_fn = function(...) install_calls <<- install_calls + 1L
  )

  expect_true(result)
  expect_equal(install_calls, 0L)
})

test_that("github_install installs an absent unpinned dependency without force", {
  installer <- load_installer()
  installed <- FALSE
  install_args <- NULL

  result <- installer$github_install(
    pkg = "brpop",
    repo = "rfsaldanha/brpop",
    is_installed_fn = function(pkg) installed,
    install_github_fn = function(...) {
      install_args <<- list(...)
      installed <<- TRUE
    }
  )

  expect_true(result)
  expect_install_args(install_args, "rfsaldanha/brpop", NULL, NULL)
})
