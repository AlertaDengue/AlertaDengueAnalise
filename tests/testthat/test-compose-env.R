# Exercise the real Sugar -> Docker Compose path without a Docker daemon or DB.
prepare_compose_env <- function() {
  skip_if(Sys.which("sugar") == "", "Containers Sugar is required")
  skip_if(Sys.which("docker") == "", "Docker Compose is required")
  skip_if_not_installed("yaml")
  version <- suppressWarnings(system2(
    "docker", c("compose", "version"), stdout = TRUE, stderr = TRUE
  ))
  skip_if(!is.null(attr(version, "status")), "Docker Compose is required")

  candidates <- normalizePath(
    c(".", "..", "../.."), winslash = "/", mustWork = FALSE
  )
  root <- candidates[file.exists(file.path(candidates, ".sugar.yaml"))][[1]]
  fixture <- tempfile("alerta-compose-env-")
  dir.create(fixture)
  withr::defer(unlink(fixture, recursive = TRUE), envir = parent.frame())
  dir.create(file.path(fixture, "containers"))
  stopifnot(file.copy(file.path(root, ".sugar.yaml"), fixture))
  compose_files <- c(
    "compose.yaml", paste0("compose-", c("dev", "staging", "prod"), ".yaml")
  )
  for (name in compose_files) {
    stopifnot(file.copy(
      file.path(root, "containers", name), file.path(fixture, "containers")
    ))
  }

  # Prevent the caller's deployment/Compose environment from entering fixtures.
  inherited <- names(Sys.getenv())
  names_to_clear <- unique(c(
    inherited[grepl("^(ALERTA_|DB_|COMPOSE_|INFODENGUE_|HOST_)", inherited)],
    "ALERTA_OUTPUT_DIR", "ALERTA_JOB_ID", "ALERTA_INPUT_FINGERPRINT"
  ))
  withr::local_envvar(
    setNames(rep(NA_character_, length(names_to_clear)), names_to_clear),
    .local_envir = parent.frame()
  )
  withr::local_dir(fixture, .local_envir = parent.frame())
  fixture
}

fake_compose_values <- function(fixture) {
  c(
    ALERTA_DB_HOST = "postgres", ALERTA_DB_PORT = "5432",
    ALERTA_DB_NAME = "fake-analysis", ALERTA_DB_USER = "fake-user",
    ALERTA_DB_PASSWORD = "fake-password",
    ALERTA_OUTPUT_DIR = file.path(fixture, "deployment-outputs")
  )
}

write_compose_env <- function(values) {
  writeLines(paste0(names(values), "=", values), ".env")
}

render_sugar_compose <- function(profile) {
  output <- tempfile("compose-output-")
  errors <- tempfile("compose-errors-")
  on.exit(unlink(c(output, errors)), add = TRUE)
  status <- suppressWarnings(system2(
    "sugar", c(
      "--profile", profile, "compose", "config", "--options",
      shQuote("--format json")
    ), stdout = output, stderr = errors
  ))
  list(
    status = status, output = readLines(output, warn = FALSE),
    errors = readLines(errors, warn = FALSE)
  )
}

test_that("Sugar renders ALERTA_DB values without legacy DB variables for every profile", {
  fixture <- prepare_compose_env()
  values <- fake_compose_values(fixture)
  legacy <- sub("^ALERTA_", "", names(values)[1:5])
  expect_true(all(is.na(Sys.getenv(legacy, unset = NA_character_))))
  write_compose_env(values)
  for (profile in c("dev", "staging", "prod")) {
    result <- render_sugar_compose(profile)
    expect_equal(result$status, 0L, info = paste(result$errors, collapse = "\n"))
    if (result$status != 0L) next
    config <- yaml::yaml.load(paste(result$output, collapse = "\n"))
    analysis <- config$services$analysis
    for (name in names(values)[1:5]) {
      expect_identical(analysis$environment[[name]], values[[name]])
    }
    expect_identical(analysis$environment$ALERTA_OUT_DIR, "/outputs")
    mount <- Filter(function(volume) volume$target == "/outputs", analysis$volumes)
    expect_identical(mount[[1]]$source, values[["ALERTA_OUTPUT_DIR"]])
    expect_identical(
      config$networks$infodengue$name,
      paste0("infodengue-", profile, "_infodengue")
    )
  }
})

test_that("runtime output, metadata and DB overrides take precedence through Sugar", {
  fixture <- prepare_compose_env()
  values <- c(
    fake_compose_values(fixture), ALERTA_JOB_ID = "deployment-job",
    ALERTA_INPUT_FINGERPRINT = "deployment-fingerprint"
  )
  write_compose_env(values)
  overrides <- c(
    ALERTA_OUTPUT_DIR = file.path(fixture, "runtime-outputs"),
    ALERTA_JOB_ID = "runtime-job", ALERTA_INPUT_FINGERPRINT = "runtime-fingerprint",
    ALERTA_DB_HOST = "runtime-postgres", ALERTA_DB_PORT = "6543",
    ALERTA_DB_NAME = "runtime-database", ALERTA_DB_USER = "runtime-user",
    ALERTA_DB_PASSWORD = "runtime-password"
  )
  withr::local_envvar(overrides)
  for (profile in c("dev", "staging", "prod")) {
    result <- render_sugar_compose(profile)
    expect_equal(result$status, 0L, info = paste(result$errors, collapse = "\n"))
    if (result$status != 0L) next
    config <- yaml::yaml.load(paste(result$output, collapse = "\n"))
    analysis <- config$services$analysis
    for (name in setdiff(names(overrides), "ALERTA_OUTPUT_DIR")) {
      expect_identical(analysis$environment[[name]], overrides[[name]])
    }
    mount <- Filter(function(volume) volume$target == "/outputs", analysis$volumes)
    expect_identical(mount[[1]]$source, overrides[["ALERTA_OUTPUT_DIR"]])
  }
})

test_that("Compose rejects absent or empty required DB values for every profile", {
  fixture <- prepare_compose_env()
  values <- fake_compose_values(fixture)
  for (profile in c("dev", "staging", "prod")) {
    required <- c(
      "ALERTA_DB_HOST", "ALERTA_DB_NAME", "ALERTA_DB_USER", "ALERTA_DB_PASSWORD"
    )
    for (name in required) {
      for (empty in c(FALSE, TRUE)) {
        invalid <- values[names(values) != name]
        if (empty) invalid <- c(invalid, setNames("", name))
        # A legacy value must not satisfy the modern deployment requirement.
        legacy_name <- sub("^ALERTA_", "", name)
        write_compose_env(c(invalid, setNames(values[[name]], legacy_name)))
        result <- render_sugar_compose(profile)
        expect_true(result$status != 0L)
        message <- paste(c(result$output, result$errors), collapse = "\n")
        expect_match(
          message, paste0(name, " is required"),
          fixed = TRUE
        )
      }
    }
  }
})

test_that("ALERTA_DB_PORT defaults to 5432 without using legacy DB_PORT", {
  fixture <- prepare_compose_env()
  values <- fake_compose_values(fixture)
  values <- values[names(values) != "ALERTA_DB_PORT"]
  for (profile in c("dev", "staging", "prod")) {
    for (empty in c(FALSE, TRUE)) {
      defaulted <- c(values, DB_PORT = "6543")
      if (empty) defaulted <- c(defaulted, ALERTA_DB_PORT = "")
      write_compose_env(defaulted)
      result <- render_sugar_compose(profile)
      expect_equal(result$status, 0L, info = paste(result$errors, collapse = "\n"))
      if (result$status != 0L) next
      config <- yaml::yaml.load(paste(result$output, collapse = "\n"))
      environment <- config$services$analysis$environment
      expected <- fake_compose_values(fixture)
      for (name in names(expected)[1:5]) {
        expect_identical(environment[[name]], expected[[name]])
      }
      expect_identical(environment$ALERTA_JOB_ID, "")
      expect_identical(environment$ALERTA_INPUT_FINGERPRINT, "")
    }
  }
})

test_that("Sugar refuses to render when the deployment env file is missing", {
  prepare_compose_env()
  result <- render_sugar_compose("staging")
  expect_true(result$status != 0L)
})
