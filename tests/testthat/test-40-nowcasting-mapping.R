test_that("nowcasting fields map consistently from x$data to tabela_historico()", {
  result <- ensure_main_br_run()

  expect_true(length(result$nowcasting_comparison) >= 1)

  for (key in names(result$nowcasting_comparison)) {
    comp <- result$nowcasting_comparison[[key]]

    expect_true(is.data.frame(comp))
    expect_true(nrow(comp) >= 1)

    expect_true(all(comp$check_casos))
    expect_true(all(comp$check_est))
    expect_true(all(comp$check_est_min))
    expect_true(all(comp$check_est_max))
    expect_true(all(comp$check_casprov))
    expect_true(all(comp$check_alert_interval))
    expect_true(all(comp$check_restab_interval))
  }
})

test_that("preferred city can show a real nowcasting adjustment when expected", {
  result <- ensure_main_br_run()

  any_adjustment <- any(vapply(
    result$nowcasting_comparison,
    function(comp) any(comp$nowcast_adjusted),
    logical(1)
  ))

  if (isTRUE(result$params$expect_nowcast_diff)) {
    expect_true(
      any_adjustment,
      info = paste(
        "Expected at least one adjusted week for city",
        result$preferred_city_key,
        "but none was found."
      )
    )
  } else {
    succeed()
  }
})
