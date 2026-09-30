source(file.path(find_repo_root_local(), "scripts", "backfill_exceptional_historico.R"),
       local = TRUE)

make_rows <- function(target) {
  weeks <- calendar_weeks(target$start_se, target$end_se)
  rows <- as.data.frame(matrix(NA, nrow = length(weeks),
                               ncol = length(source_columns)))
  names(rows) <- source_columns
  rows$SE <- weeks
  rows$data_iniSE <- AlertTools::SE2date(weeks)$ini
  rows$municipio_geocodigo <- target$municipio_geocodigo
  rows$CID10 <- "A90"
  rows$Localidade_id <- 0L
  rows
}

test_that("the nine corrected municipalities have the exact fixed windows", {
  expect_equal(nrow(targets), 9L)
  expect_equal(targets$municipio_geocodigo,
               c(2201919L, 2201988L, 2202251L, 2611533L, 3117836L,
                 3152131L, 4305871L, 5203939L, 5203962L))
  expect_equal(targets$start_se,
               c(rep(201001L, 4L), rep(202124L, 2L), rep(201001L, 3L)))
  expect_true(all(targets$end_se == 202341L))
  expect_equal(calendar_weeks(202052L, 202102L),
               c(202052L, 202053L, 202101L, 202102L))
  expect_identical(AlertTools::SE2date(201001L)$ini, as.Date("2010-01-03"))
})

test_that("generated rows require exact municipality, disease, week and dates", {
  target <- targets[5L, ]
  rows <- make_rows(target)
  expect_silent(validate_rows(rows, target))
  wrong <- rows
  wrong$municipio_geocodigo[1L] <- targets$municipio_geocodigo[1L]
  expect_error(validate_rows(wrong, target), "Invalid generated coverage")
  wrong <- rows
  wrong$CID10[1L] <- "A92.0"
  expect_error(validate_rows(wrong, target), "Invalid generated coverage")
  wrong <- rows
  wrong$Localidade_id[1L] <- 1L
  expect_error(validate_rows(wrong, target), "Invalid generated coverage")
  wrong <- rows
  wrong$SE[1L] <- 202123L
  expect_error(validate_rows(wrong, target), "Invalid generated coverage")
  wrong <- rows
  wrong$SE[2L] <- wrong$SE[1L]
  expect_error(validate_rows(wrong, target), "Invalid generated coverage")
  wrong <- rows
  wrong$data_iniSE[1L] <- wrong$data_iniSE[1L] + 1L
  expect_error(validate_rows(wrong, target), "Invalid data_iniSE")
  expect_error(validate_rows(rows[-1L, , drop = FALSE], target),
               "Invalid generated coverage")
})

test_that("existing exact keys are excluded and a completed run is empty", {
  rows <- make_rows(targets[5L, ])
  existing <- data.frame(SE = rows$SE[1:2],
                         municipio_geocodigo = targets$municipio_geocodigo[5L],
                         Localidade_id = 0L)
  expect_equal(nrow(missing_rows(rows, existing)), nrow(rows) - 2L)
  existing <- rows[c("SE", "municipio_geocodigo", "Localidade_id")]
  expect_equal(nrow(missing_rows(rows, existing)), 0L)
})

test_that("SQL maps only dengue history columns and ignores conflicts", {
  row <- make_rows(targets[5L, ])[1L, , drop = FALSE]
  row$municipio_nome <- "Cônego Marinho"
  row$versao_modelo <- "2026-09-30"
  row$id <- "123"
  sql <- insert_sql(NULL, row, quote_string = function(x) {
    paste0("'", gsub("'", "''", x, fixed = TRUE), "'")
  })
  expect_match(sql, '^INSERT INTO "Municipio"\\."Historico_alerta"')
  expect_match(sql, "ON CONFLICT ON CONSTRAINT alertas_unicos DO NOTHING", fixed = TRUE)
  expect_false(grepl("DO UPDATE|DELETE FROM|Historico_alerta_chik|Historico_alerta_zika",
                     sql))
  expect_match(sql, '"SE", "data_iniSE", casos_est', fixed = TRUE)
  expect_match(sql, "'Cônego Marinho'", fixed = TRUE)
})

test_that("dry-run is default and apply is opt-in", {
  expect_false(parse_args(c("--week", "202630"))$apply)
  expect_true(parse_args(c("--week", "202630", "--apply"))$apply)
  expect_error(parse_args(c("--week", "202630", "--unknown")), "Usage")
  expect_error(parse_args(c("--week", "2026XX")), "YYYYWW")
})
