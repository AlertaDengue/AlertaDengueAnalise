load_main_worker_helpers <- function() {
  base_dir <- getwd()
  if (!dir.exists(base_dir)) {
    base_dir <- dirname(base_dir)
  }
  candidates <- suppressWarnings(unique(vapply(
    c(base_dir, file.path(base_dir, ".."), file.path(base_dir, "..", "..")),
    normalizePath,
    "",
    winslash = "/",
    mustWork = FALSE
  )))
  repo_root <- candidates[vapply(candidates, function(path) file.exists(file.path(path, "main", "main_BR.R")), logical(1))][[1]]
  lines <- readLines(file.path(repo_root, "main", "main_BR.R"), warn = FALSE)
  helper_text <- paste(lines[seq_len(175)], collapse = "\n")
  helper_env <- new.env(parent = globalenv())
  eval(parse(text = helper_text), envir = helper_env)
  helper_env
}

test_that("state filter accepts ALL and preserves explicit state lists", {
  helpers <- suppressWarnings(load_main_worker_helpers())
  valid <- c("DF", "GO", "SP")

  expect_equal(helpers$normalize_state_filter("", valid), character(0))
  expect_equal(helpers$normalize_state_filter("ALL", valid), character(0))
  expect_equal(helpers$normalize_state_filter("all", valid), character(0))
  expect_equal(helpers$normalize_state_filter("DF", valid), "DF")
  expect_equal(helpers$normalize_state_filter("DF,GO", valid), c("DF", "GO"))
  expect_error(
    helpers$normalize_state_filter("DF,XX", valid),
    "Invalid ALERTA_STATES"
  )
})

test_that("forked state workers isolate and clean caselist scratch files", {
  helpers <- suppressWarnings(load_main_worker_helpers())
  base_dir <- getwd()
  if (!dir.exists(base_dir)) {
    base_dir <- dirname(base_dir)
  }
  candidates <- suppressWarnings(unique(vapply(
    c(base_dir, file.path(base_dir, ".."), file.path(base_dir, "..", "..")),
    normalizePath,
    "",
    winslash = "/",
    mustWork = FALSE
  )))
  repo_root <- candidates[vapply(candidates, function(path) file.exists(file.path(path, "main", "main_BR.R")), logical(1))][[1]]
  results <- parallel::mclapply(seq_len(8), function(worker) {
    scratch_dir <- helpers$state_scratch_dir(sprintf("T%02d", worker))
    original_wd <- getwd()
    setwd(scratch_dir)
    on.exit({
      setwd(original_wd)
      unlink(scratch_dir, recursive = TRUE, force = TRUE)
    }, add = TRUE)

    payload <- list(worker = worker, path = scratch_dir)
    save(payload, file = "caselist.RData")
    Sys.sleep(0.05)
    loaded <- new.env(parent = emptyenv())
    load("caselist.RData", envir = loaded)
    list(
      worker = loaded$payload$worker,
      path = loaded$payload$path,
      file = file.path(scratch_dir, "caselist.RData")
    )
  }, mc.cores = 8, mc.preschedule = FALSE)

  paths <- vapply(results, `[[`, "", "path")
  files <- vapply(results, `[[`, "", "file")
  expect_length(unique(paths), 8)
  expect_equal(sort(vapply(results, `[[`, integer(1), "worker")), seq_len(8))
  expect_true(all(!file.exists(paths)))
  expect_true(all(!file.exists(files)))
  expect_false(file.exists(file.path(repo_root, "caselist.RData")))
})
