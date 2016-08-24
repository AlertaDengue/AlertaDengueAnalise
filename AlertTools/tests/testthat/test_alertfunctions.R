setwd("../..")
## testando conexão com o banco 
con <-DenguedbConnect()
test_that("sql connection exists", {
      expect_equal(class(con)[1], "PostgreSQLConnection")
})

# -------------------------
# Testing twoalert
# -------------------------

geoc = 330240 # cidade para teste

dC0 = getCases(city = geoc, datasource=con)
dC11<-Rt(obj = dC0, count = "casos", gtdist="normal", meangt=3, sdgt = 1)
dT01 = getTweet(city = geoc, lastday = Sys.Date(), datasource = con) 
dW01 = getWU(stations = 'SBRJ',datasource= con)
d0<- mergedata(cases = dC11,tweet = dT01, climate = dW01)

test_that("output of merging is a non empty data.frame.", {
      expect_more_than(dim(d0)[1], 0)
})

test_that("output has the minimum set of columns.", {
      expect_true(all(c("cidade", "SE", "estacao","tweet","casos") %in% names(d0)))
})

#critgy <- c("temp_min > 22 | tweet > 80", 3, 3)
#alerta <- twoalert(d0, cy = critgy)

#test_that("twoalert has the minimum set of items.", {
#      expect_true(all(c("data", "indices", "rules","n") %in% names(alerta)))
#})


