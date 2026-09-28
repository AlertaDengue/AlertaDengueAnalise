find_job_root <- function() {
  candidates <- normalizePath(
    c(".", "..", "../.."), winslash = "/", mustWork = FALSE
  )
  candidates[file.exists(file.path(candidates, ".makim.yaml"))][[1]]
}

test_that("the environment template substitutes configured values", {
  skip_if(Sys.which("envsubst") == "")
  root <- find_job_root()
  template <- file.path(root, ".env.tpl")
  variables <- c(
    "ALERTA_DB_HOST", "ALERTA_DB_PORT", "ALERTA_DB_NAME", "ALERTA_DB_USER",
    "ALERTA_DB_PASSWORD", "ALERTA_OUTPUT_DIR", "ALERTA_OUT_DIR",
    "ALERTA_DO_SCP", "ALERTA_SCP_ENDPOINT", "ALERTA_SCP_PATH"
  )
  lines <- readLines(template)
  expect_true(all(vapply(variables, function(name) {
    any(lines == paste0(name, "=${", name, "}"))
  }, logical(1))))
  expect_false(any(grepl(
    "^ALERTA_(JOB_ID|INPUT_FINGERPRINT)=", lines
  )))

  values <- setNames(paste0("test-", seq_along(variables)), variables)
  old <- setNames(Sys.getenv(variables, unset = NA_character_), variables)
  on.exit({
    Sys.unsetenv(variables)
    if (any(!is.na(old))) {
      do.call(Sys.setenv, as.list(old[!is.na(old)]))
    }
  }, add = TRUE)
  do.call(Sys.setenv, as.list(values))

  output <- tempfile("alerta-env-")
  on.exit(unlink(output), add = TRUE)
  status <- system2(
    "envsubst", stdin = template, stdout = output, stderr = FALSE
  )
  expect_equal(status, 0L)
  rendered <- readLines(output)
  expect_true(all(vapply(variables, function(name) {
    any(rendered == paste0(name, "=", values[[name]]))
  }, logical(1))))
})

test_that("the job persists optional correlation metadata in its refresh log", {
  skip_if(Sys.which("makim") == "")
  root <- find_job_root()
  job_root <- tempfile("alerta-job-")
  dir.create(job_root)
  on.exit(unlink(job_root, recursive = TRUE), add = TRUE)
  expect_true(file.copy(file.path(root, ".makim.yaml"), job_root))
  old_wd <- getwd()
  setwd(job_root)
  on.exit(setwd(old_wd), add = TRUE)
  variables <- c(
    "ALERTA_DB_HOST", "ALERTA_DB_PORT", "ALERTA_DB_NAME", "ALERTA_DB_USER",
    "ALERTA_DB_PASSWORD", "ALERTA_OUT_DIR", "CONDA_EXE", "ALERTA_JOB_ID",
    "ALERTA_INPUT_FINGERPRINT"
  )
  old <- setNames(Sys.getenv(variables, unset = NA_character_), variables)
  on.exit({
    Sys.unsetenv(variables)
    if (any(!is.na(old))) {
      do.call(Sys.setenv, as.list(old[!is.na(old)]))
    }
  }, add = TRUE)

  Sys.setenv(
    ALERTA_DB_HOST = "db.example", ALERTA_DB_PORT = "5432",
    ALERTA_DB_NAME = "example", ALERTA_DB_USER = "example",
    ALERTA_DB_PASSWORD = "test-secret", CONDA_EXE = "false"
  )

  run_case <- function(name, with_metadata) {
    output_dir <- file.path(job_root, name)
    Sys.setenv(ALERTA_OUT_DIR = output_dir)
    if (with_metadata) {
      Sys.setenv(
        ALERTA_JOB_ID = "test-job",
        ALERTA_INPUT_FINGERPRINT = "test-fingerprint"
      )
    } else {
      Sys.unsetenv(c("ALERTA_JOB_ID", "ALERTA_INPUT_FINGERPRINT"))
    }
    output <- suppressWarnings(system2(
      "makim", c(
        "pipeline.refresh-alertas-job", "--week", "202520",
        "--states", "ALL", "--cores", "1", "--load", "false"
      ), stdout = TRUE, stderr = TRUE
    ))
    expect_true(!is.null(attr(output, "status")))
    logs <- list.files(
      file.path(output_dir, "logs"), pattern = "^refresh-alertas-job-.*[.]log$",
      full.names = TRUE
    )
    expect_length(logs, 1)
    internal_logs <- list.files(
      file.path(output_dir, "logs"), pattern = "^refresh-alertas-[0-9].*[.]log$",
      full.names = TRUE
    )
    expect_length(internal_logs, 1)
    expect_false(any(grepl("[II] job_id=", readLines(internal_logs[[1]]), fixed = TRUE)))
    expect_false(any(grepl(
      "[II] input_fingerprint=", readLines(internal_logs[[1]]), fixed = TRUE
    )))
    list(stdout = output, log = readLines(logs[[1]]))
  }

  present <- run_case("with-metadata", TRUE)
  for (line in c(
    "[II] job_id=test-job", "[II] input_fingerprint=test-fingerprint"
  )) {
    expect_true(any(present$stdout == line))
    expect_true(any(present$log == line))
  }

  absent <- run_case("without-metadata", FALSE)
  expect_false(any(grepl("[II] job_id=", absent$stdout, fixed = TRUE)))
  expect_false(any(grepl("[II] input_fingerprint=", absent$stdout, fixed = TRUE)))
  expect_false(any(grepl("[II] job_id=", absent$log, fixed = TRUE)))
  expect_false(any(grepl("[II] input_fingerprint=", absent$log, fixed = TRUE)))

  # Let the real job entrypoint reach its output validation without running R.
  makim_path <- Sys.which("makim")
  fake_bin <- file.path(job_root, "fake-bin")
  dir.create(fake_bin)
  fake_makim <- file.path(fake_bin, "makim")
  writeLines(c("#!/bin/sh", "exit 0"), fake_makim)
  Sys.chmod(fake_makim, mode = "0755")
  old_path <- Sys.getenv("PATH")
  on.exit(Sys.setenv(PATH = old_path), add = TRUE)
  Sys.setenv(PATH = paste(fake_bin, old_path, sep = .Platform$path.sep))
  failure_dir <- file.path(job_root, "missing-artifacts")
  Sys.setenv(ALERTA_OUT_DIR = failure_dir)
  failure_output <- suppressWarnings(system2(
    makim_path, c(
      "pipeline.refresh-alertas-job", "--week", "202520",
      "--states", "ALL", "--cores", "1", "--load", "false"
    ), stdout = TRUE, stderr = TRUE
  ))
  expect_true(!is.null(attr(failure_output, "status")))
  job_logs <- list.files(
    file.path(failure_dir, "logs"),
    pattern = "^refresh-alertas-job-.*[.]log$", full.names = TRUE
  )
  expect_length(job_logs, 1)
  failure_message <- "ERRO: nenhum RData estadual foi gerado"
  expect_true(any(grepl(failure_message, failure_output, fixed = TRUE)))
  expect_true(any(grepl(failure_message, readLines(job_logs[[1]]), fixed = TRUE)))
})
