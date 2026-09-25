find_artifact_root <- function() {
  candidates <- normalizePath(
    c(".", "..", "../.."), winslash = "/", mustWork = FALSE
  )
  candidates[file.exists(file.path(candidates, "main", "artifact_guard.R"))][[1]]
}

test_that("filtered consolidation uses only new selected-state outputs", {
  source(file.path(find_artifact_root(), "main", "artifact_guard.R"))
  expect_identical(
    selected_state_output_paths(
      "/tmp/alertas/202520", 202520, c("DF", "GO")
    ),
    c(
      "/tmp/alertas/202520/ale-DF-202520.RData",
      "/tmp/alertas/202520/ale-GO-202520.RData"
    )
  )
  output_dir <- tempfile("alerta-states-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE), add = TRUE)

  week <- 202520
  selected <- selected_state_output_paths(output_dir, week, "DF")
  unrelated <- selected_state_output_paths(output_dir, week, c("GO", "SP"))
  res <- list(state = "stale")
  for (path in c(selected, unrelated)) {
    save(res, file = path)
  }

  clear_generated_artifacts(selected)
  expect_false(file.exists(selected))
  expect_true(all(file.exists(unrelated)))
  expect_error(
    require_current_artifacts(selected, "state RData"),
    "Missing current-run state RData"
  )

  file.create(selected)
  expect_error(
    require_current_artifacts(selected, "state RData"),
    "Missing current-run state RData"
  )

  res <- list(state = "DF-current")
  save(res, file = selected)
  paths <- require_current_artifacts(selected, "state RData")
  expect_equal(paths, selected)
  loaded <- new.env(parent = emptyenv())
  load(paths[[1]], envir = loaded)
  expect_equal(loaded$res$state, "DF-current")
  expect_true(all(file.exists(unrelated)))
})

test_that("BR artifact must be regenerated for the current week", {
  source(file.path(find_artifact_root(), "main", "artifact_guard.R"))
  br_dir <- tempfile("alerta-br-")
  dir.create(br_dir)
  on.exit(unlink(br_dir, recursive = TRUE), add = TRUE)

  current <- br_output_path(br_dir, 202520)
  other_weeks <- vapply(
    c(202519, 202521),
    function(week) br_output_path(br_dir, week),
    ""
  )
  expect_identical(basename(current), "ale-BR-202520.RData")
  d <- data.frame(week = 202520)
  for (path in c(current, other_weeks)) {
    save(d, file = path)
  }

  clear_generated_artifacts(current)
  expect_false(file.exists(current))
  expect_true(all(file.exists(other_weeks)))
  expect_error(
    require_current_artifacts(current, "BR RData"),
    "Missing current-run BR RData"
  )

  file.create(current)
  expect_error(
    require_current_artifacts(current, "BR RData"),
    "Missing current-run BR RData"
  )

  save(d, file = current)
  expect_identical(require_current_artifacts(current, "BR RData"), current)
  expect_true(all(file.exists(other_weeks)))
})

test_that("stale disease SQL is cleared without touching unrelated files", {
  source(file.path(find_artifact_root(), "main", "artifact_guard.R"))
  sql_dir <- tempfile("alerta-sql-")
  dir.create(sql_dir)
  on.exit(unlink(sql_dir, recursive = TRUE), add = TRUE)
  generated <- generated_sql_paths(sql_dir)
  unrelated <- file.path(sql_dir, "keep.sql")
  for (path in c(generated, unrelated)) {
    writeLines("old content", path)
  }

  clear_generated_artifacts(generated)
  expect_false(any(file.exists(generated)))
  expect_true(file.exists(unrelated))
})

test_that("artifact cleanup fails when a targeted path remains", {
  source(file.path(find_artifact_root(), "main", "artifact_guard.R"))
  output_dir <- tempfile("alerta-blocked-")
  dir.create(output_dir)
  on.exit(unlink(output_dir, recursive = TRUE), add = TRUE)
  blocked <- file.path(output_dir, "ale-DF-202520.RData")
  dir.create(blocked)
  writeLines("keep", file.path(blocked, "inside"))

  expect_error(
    clear_generated_artifacts(blocked),
    "Could not remove previous generated artifact"
  )
  expect_true(dir.exists(blocked))
})

test_that("load refuses stale SQL when analysis regenerates none", {
  skip_if(Sys.which("makim") == "")
  root <- find_artifact_root()
  sandbox <- tempfile("alerta-load-")
  dir.create(sandbox)
  on.exit(unlink(sandbox, recursive = TRUE), add = TRUE)
  expect_true(file.copy(file.path(root, ".makim.yaml"), sandbox))

  output_dir <- file.path(sandbox, "outputs")
  sql_dir <- file.path(output_dir, "sql")
  dir.create(sql_dir, recursive = TRUE)
  generated <- file.path(sql_dir, c(
    "output_dengue.sql", "output_chik.sql", "output_zika.sql"
  ))
  unrelated <- file.path(sql_dir, "keep.sql")
  for (path in c(generated, unrelated)) {
    writeLines("stale SQL", path)
  }

  fake_bin <- file.path(sandbox, "bin")
  dir.create(fake_bin)
  fake_conda <- file.path(fake_bin, "fake-conda")
  writeLines(c("#!/bin/sh", "exit 0"), fake_conda)
  Sys.chmod(fake_conda, mode = "0755")
  psql_marker <- file.path(sandbox, "psql-called")
  fake_psql <- file.path(fake_bin, "psql")
  writeLines(c(
    "#!/bin/sh",
    paste("touch", shQuote(psql_marker))
  ), fake_psql)
  Sys.chmod(fake_psql, mode = "0755")

  variables <- c(
    "PATH", "CONDA_EXE", "ALERTA_OUT_DIR", "ALERTA_DB_HOST",
    "ALERTA_DB_PORT", "ALERTA_DB_NAME", "ALERTA_DB_USER",
    "ALERTA_DB_PASSWORD"
  )
  old <- setNames(Sys.getenv(variables, unset = NA_character_), variables)
  on.exit({
    Sys.unsetenv(variables)
    if (any(!is.na(old))) {
      do.call(Sys.setenv, as.list(old[!is.na(old)]))
    }
  }, add = TRUE)
  Sys.setenv(
    PATH = paste(fake_bin, Sys.getenv("PATH"), sep = .Platform$path.sep),
    CONDA_EXE = fake_conda,
    ALERTA_OUT_DIR = output_dir,
    ALERTA_DB_HOST = "db.example",
    ALERTA_DB_PORT = "5432",
    ALERTA_DB_NAME = "example",
    ALERTA_DB_USER = "example",
    ALERTA_DB_PASSWORD = "test-secret"
  )

  old_wd <- getwd()
  setwd(sandbox)
  on.exit(setwd(old_wd), add = TRUE)
  output <- suppressWarnings(system2(
    "makim", c(
      "pipeline.refresh-alertas", "--week", "202520",
      "--states", "DF", "--load"
    ), stdout = TRUE, stderr = TRUE
  ))

  expect_true(!is.null(attr(output, "status")))
  expect_true(any(grepl("required current-run SQL missing", output, fixed = TRUE)))
  expect_false(any(file.exists(generated)))
  expect_true(file.exists(unrelated))
  expect_false(file.exists(psql_marker))

  # Even a newly generated dengue file must not be applied before chik exists.
  partial_output_dir <- file.path(sandbox, "partial-outputs")
  partial_sql_dir <- file.path(partial_output_dir, "sql")
  dir.create(partial_sql_dir, recursive = TRUE)
  writeLines("stale SQL", file.path(partial_sql_dir, "output_chik.sql"))
  writeLines(c(
    "#!/bin/sh",
    "printf 'fresh SQL' > \"${ALERTA_OUT_DIR}/sql/output_dengue.sql\""
  ), fake_conda)
  Sys.chmod(fake_conda, mode = "0755")
  Sys.setenv(ALERTA_OUT_DIR = partial_output_dir)
  partial_output <- suppressWarnings(system2(
    "makim", c(
      "pipeline.refresh-alertas", "--week", "202520",
      "--states", "DF", "--load"
    ), stdout = TRUE, stderr = TRUE
  ))
  expect_true(!is.null(attr(partial_output, "status")))
  expect_true(any(grepl(
    "output_chik.sql", partial_output, fixed = TRUE
  )))
  expect_true(file.exists(file.path(partial_sql_dir, "output_dengue.sql")))
  expect_false(file.exists(file.path(partial_sql_dir, "output_chik.sql")))
  expect_false(file.exists(psql_marker))

  # An empty required SQL file also fails before either database write.
  empty_output_dir <- file.path(sandbox, "empty-outputs")
  empty_sql_dir <- file.path(empty_output_dir, "sql")
  dir.create(empty_sql_dir, recursive = TRUE)
  writeLines(c(
    "#!/bin/sh",
    "printf 'fresh SQL' > \"${ALERTA_OUT_DIR}/sql/output_dengue.sql\"",
    ": > \"${ALERTA_OUT_DIR}/sql/output_chik.sql\""
  ), fake_conda)
  Sys.chmod(fake_conda, mode = "0755")
  Sys.setenv(ALERTA_OUT_DIR = empty_output_dir)
  empty_output <- suppressWarnings(system2(
    "makim", c(
      "pipeline.refresh-alertas", "--week", "202520",
      "--states", "DF", "--load"
    ), stdout = TRUE, stderr = TRUE
  ))
  expect_true(!is.null(attr(empty_output, "status")))
  expect_true(any(grepl("output_chik.sql", empty_output, fixed = TRUE)))
  expect_equal(file.info(file.path(empty_sql_dir, "output_chik.sql"))$size, 0)
  expect_false(file.exists(psql_marker))
})
