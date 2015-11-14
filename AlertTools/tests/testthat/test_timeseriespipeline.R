setwd("../..")

# Testing function getCases

test_that("sinan data exists", {
  le <- length(load("data/sinan.rda"))
  expect_equal(le, 1)
})

dC0 = getCases(city = c(330455), withdivision = TRUE, datasource="data/sinan.rda")
dC00 = getCases(city = c(330455), withdivision = FALSE,datasource="data/sinan.rda")


test_that("output getCases has the required columns", {
  expect_true(all(c("bairro", "SE", "casos") %in% names(dC0)))
  expect_true(all(c("localidade", "SE", "casos") %in% names(dC00)))
})

# Testing function casesinlocality
dC1 = casesinlocality(obj = dC0, locality = "AP1") # Rio de Janeiro

test_that("output of casesinlocality has the required columns.", {
  expect_true(all(c("localidade", "SE", "casos") %in% names(dC1)))
})

# Testing the adjustIncidence function
dC2<-adjustIncidence(obj=dC1)

test_that("output of adjustIncidence has the required columns.", {
  expect_true(all(c("localidade", "SE", "casos", "pdig", "tcasesICmin", 
                    "tcasesmed", "tcasesICmax") %in% names(dC2)))
})

# Testing Rt functions
# different ways to run it

dC31<-Rt(obj = dC1, count = "casos", gtdist="normal", meangt=3, sdgt = 1)
dC32<-Rt(obj = dC2, count = "casos", gtdist="normal", meangt=3, sdgt = 1)
dC33<-Rt(obj = dC2, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)

test_that("output of Rt has the required columns.", {
  expect_true(all(c("localidade", "SE", "casos", "Rt", "lwr", "upr", "p1") %in% names(dC31)))
  expect_true(all(c("localidade", "SE", "casos", "Rt", "lwr", "upr", "p1") %in% names(dC32)))
  expect_true(all(c("localidade", "SE", "casos", "Rt", "lwr", "upr", "p1") %in% names(dC33)))  
})

# ----------------------
# Testing getTweet function
# ----------------------
dT01 = getTweet(city = c(330455), lastday = Sys.Date()) # Rio de Janeiro
dT02 = getTweet(city = c(330455), lastday = "2014-03-01") # Rio de Janeiro

test_that("output of getTweet has the required columns.", {
  expect_true(all(c("cidade", "SE", "tweet") %in% names(dT01)))
  expect_true(all(c("cidade", "SE", "tweet") %in% names(dT02)))  
})


# ----------------------
# Testing getWU function
# ----------------------
dW01 = getWU(stations = c('SBRJ','SBJR','SBAF','SBGL'))
dW03 = getWU(stations = 'SBRJ', var="temp_min")

test_that("output of getWU has the required columns.", {
  expect_true(all(c("cidade", "SE", "estacao") %in% names(dW01)))
  expect_true(all(c("cidade", "SE", "estacao") %in% names(dW03)))  
})


# ---------------------
# Testing mergedata 
d0<- mergedata(cases = dC31,tweet = dT01, climate = dW01[dW01$estacao=="SBJR",])
d1<- mergedata(tweet = dT01, climate = dW01[dW01$estacao=="SBJR",])
d2<- mergedata(cases = dC31, climate = dW01[dW01$estacao=="SBJR",])
d3<- mergedata(cases = dC31, tweet = dT01)

test_that("output of merging is a non empty data.frame.", {
  expect_more_than(dim(d0)[1], 0)
  expect_more_than(dim(d1)[1], 0)
  expect_more_than(dim(d2)[1], 0)
  expect_more_than(dim(d3)[1], 0)
})

test_that("output has the minimum set of columns.", {
      expect_true(all(c("cidade", "SE", "estacao","tweet","casos") %in% names(d0)))
      expect_true(all(c("cidade", "SE", "estacao","tweet") %in% names(d1)))
      expect_true(all(c("cidade", "SE", "estacao","casos") %in% names(d2)))
      expect_true(all(c("cidade", "SE", "tweet","casos") %in% names(d3)))
})


