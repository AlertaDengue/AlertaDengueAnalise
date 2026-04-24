test_that("main_BR.R runs end-to-end locally with real packages and real DB", {
  result <- ensure_main_br_run()

  expect_equal(result$run$status, 0L)
  expect_true(length(result$run$log_lines) > 0)

  done_found <- any(grepl("\\[INFO\\] DONE$", result$run$log_lines)) ||
    any(grepl("DONE$", result$run$log_lines))

  expect_true(done_found)
})
