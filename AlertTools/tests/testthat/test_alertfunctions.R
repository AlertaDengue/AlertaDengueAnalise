setwd("../..")

# -------------------------
# Testing twoalert
# -------------------------

dC0 = getCases(city = c(330455), withdivision = TRUE, datasource="data/sinan.rda")
dC1 = casesinlocality(obj = dC0, locality = "AP1") # Rio de Janeiro
dC31<-Rt(obj = dC1, count = "casos", gtdist="normal", meangt=3, sdgt = 1)
dT01 = getTweet(city = c(330455), lastday = Sys.Date()) # Rio de Janeiro
dW01 = getWU(stations = c('SBRJ','SBJR','SBAF','SBGL'))
d0<- mergedata(cases = dC31,tweet = dT01, climate = dW01[dW01$estacao=="SBJR",])

test_that("output of merging is a non empty data.frame.", {
      expect_more_than(dim(d0)[1], 0)
})

test_that("output has the minimum set of columns.", {
      expect_true(all(c("cidade", "SE", "estacao","tweet","casos") %in% names(d0)))
})

critgy <- c("temp_min > 22 | tweet > 80", 3, 3)
alerta <- twoalert(d0, cy = critgy)

test_that("twoalert has the minimum set of items.", {
      expect_true(all(c("data", "indices", "rules","n") %in% names(alerta)))
})


