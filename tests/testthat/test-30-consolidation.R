test_that("BR consolidation matches the disease outputs from the state result", {
  result <- ensure_main_br_run()

  expected_d <- build_expected_consolidated_d(result$res)

  expect_true(is.data.frame(result$d))
  expect_true(is.data.frame(expected_d))

  expect_equal(names(result$d), names(expected_d))
  expect_equal(nrow(result$d), nrow(expected_d))
  expect_equal(result$d, expected_d)
})
