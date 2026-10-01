source(file.path(find_repo_root_local(), "scripts", "backfill_exceptional_historico.R"),
       local = TRUE)

make_rows <- function(target, disease) {
  weeks <- calendar_weeks(target$start_se, target$end_se)
  rows <- as.data.frame(matrix(NA, nrow = length(weeks),
                               ncol = length(source_columns)))
  names(rows) <- source_columns
  rows$SE <- weeks
  rows$data_iniSE <- AlertTools::SE2date(weeks)$ini
  rows$municipio_geocodigo <- target$municipio_geocodigo
  rows$CID10 <- disease$cid10
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
  expect_identical(AlertTools::SE2date(201815L)$ini, as.Date("2018-04-08"))
  expect_equal(sum(vapply(seq_len(nrow(targets)), function(i) {
    length(calendar_weeks(targets$start_se[i], targets$end_se[i]))
  }, integer(1L))), 5277L)
})

test_that("only dengue and chikungunya are configured", {
  expect_identical(names(diseases), c("dengue", "chikungunya"))
  expect_identical(diseases$dengue,
                   list(cid10 = "A90", table = "Historico_alerta",
                        constraint = "alertas_unicos"))
  expect_identical(diseases$chikungunya,
                   list(cid10 = "A92.0", table = "Historico_alerta_chik",
                        constraint = "alertas_unicos_chik"))
  expect_false(any(vapply(diseases, function(x) x$cid10 == "A92.8", logical(1L))))
})

test_that("generated rows require exact municipality, disease, week and dates", {
  target <- targets[5L, ]
  rows <- make_rows(target, diseases$dengue)
  expect_silent(validate_rows(rows, target, diseases$dengue))
  expect_silent(validate_rows(make_rows(target, diseases$chikungunya),
                              target, diseases$chikungunya))
  wrong <- rows
  wrong$municipio_geocodigo[1L] <- targets$municipio_geocodigo[1L]
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid generated coverage")
  wrong <- rows
  wrong$CID10[1L] <- "A92.0"
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid generated coverage")
  wrong <- make_rows(target, diseases$chikungunya)
  wrong$CID10[1L] <- "A90"
  expect_error(validate_rows(wrong, target, diseases$chikungunya), "Invalid generated coverage")
  rows <- make_rows(target, diseases$dengue)
  wrong <- rows
  wrong$Localidade_id[1L] <- 1L
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid generated coverage")
  wrong <- rows
  wrong$SE[1L] <- 202123L
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid generated coverage")
  wrong <- rows
  wrong$SE[2L] <- wrong$SE[1L]
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid generated coverage")
  wrong <- rows
  wrong$data_iniSE[1L] <- wrong$data_iniSE[1L] + 1L
  expect_error(validate_rows(wrong, target, diseases$dengue), "Invalid data_iniSE")
  expect_error(validate_rows(rows[-1L, , drop = FALSE], target, diseases$dengue),
               "Invalid generated coverage")
})

test_that("existing target rows use the corrected calendar date", {
  target <- targets[1L, ]
  row <- data.frame(SE = 201815L, data_iniSE = as.Date("2018-04-04"))
  expect_error(validate_existing_dates(row, target, diseases$dengue),
               "Historico_alerta.*2201919.*201815")
  row$data_iniSE <- as.Date("2018-04-08")
  expect_silent(validate_existing_dates(row, target, diseases$dengue))
})

test_that("existing exact keys are excluded and a completed run is empty", {
  rows <- make_rows(targets[5L, ], diseases$dengue)
  existing <- data.frame(SE = rows$SE[1:2],
                         municipio_geocodigo = targets$municipio_geocodigo[5L],
                         Localidade_id = 0L)
  expect_equal(nrow(missing_rows(rows, existing)), nrow(rows) - 2L)
  existing <- rows[c("SE", "municipio_geocodigo", "Localidade_id")]
  expect_equal(nrow(missing_rows(rows, existing)), 0L)
})

test_that("SQL maps both diseases to insert-only history tables", {
  row <- make_rows(targets[5L, ], diseases$dengue)[1L, , drop = FALSE]
  row$municipio_nome <- "Cônego Marinho"
  row$versao_modelo <- "2026-09-30"
  row$id <- "123"
  for (disease in diseases) {
    sql <- insert_sql(NULL, row, disease, quote_string = function(x) {
      paste0("'", gsub("'", "''", x, fixed = TRUE), "'")
    })
    expect_match(sql, paste0('INSERT INTO "Municipio"."', disease$table, '"'),
                 fixed = TRUE)
    expect_match(sql, paste0("ON CONFLICT ON CONSTRAINT ", disease$constraint,
                             " DO NOTHING"), fixed = TRUE)
    expect_false(grepl("Historico_alerta_zika|UPDATE|DELETE", sql))
    expect_match(sql, '"SE", "data_iniSE", casos_est', fixed = TRUE)
    expect_match(sql, "'Cônego Marinho'", fixed = TRUE)
  }
})

test_that("dry-run is default and apply is opt-in", {
  expect_false(parse_args(c("--week", "202630"))$apply)
  expect_true(parse_args(c("--week", "202630", "--apply"))$apply)
  expect_error(parse_args(c("--week", "202630", "--unknown")), "Usage")
  expect_error(parse_args(c("--week", "2026XX")), "YYYYWW")
})
