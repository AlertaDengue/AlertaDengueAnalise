test_that("SQL outputs are generated and are not empty", {
  result <- ensure_main_br_run()

  expect_gte(length(result$sql_files), 1)

  for (path in result$sql_files) {
    expect_true(file.exists(path))
    expect_gt(file.info(path)$size, 0)
  }
})
