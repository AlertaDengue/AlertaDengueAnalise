test_that("state-level outputs are created and have expected structure", {
  result <- ensure_main_br_run()

  expect_true(file.exists(result$paths$state_rdata))
  expect_true(file.exists(result$paths$br_rdata))
  expect_true(dir.exists(result$paths$sql_dir))

  expect_true(is.list(result$res))
  expect_true(length(result$res) >= 1)

  ale_keys <- available_result_keys(result$res, "ale\\.")
  restab_keys <- available_result_keys(result$res, "restab\\.")

  expect_true(length(ale_keys) >= 1)
  expect_true(length(restab_keys) >= 1)

  for (key in ale_keys) {
    expect_true(is.list(result$res[[key]]))
    expect_true(length(result$res[[key]]) >= 1)
  }

  for (key in restab_keys) {
    expect_true(is.data.frame(result$res[[key]]))
    expect_true(nrow(result$res[[key]]) >= 1)
  }
})
