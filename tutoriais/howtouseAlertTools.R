
library(AlertTools)

con = DenguedbConnect()
ca = getCases(city = 3304557, datasource = con)
head(ca)

tw = getTweet(city = 3304557, datasource = con)

wu = getWU(stations = "SBRJ", vars = "temp_min", datasource = con)

bd = mergedata(ca,tw,wu)
tail(bd)

save(bd, file = "meusdados.RData")


# ==========================================

nafill(bd$temp_min, rule="arima")
res = adjustIncidence(bd)
tail(res)

# Rt
## -------- Distribuicao do tempo de geracao da dengue:
gtdist="normal"; meangt=3; sdgt = 1.2
res = Rt(res,meangt=3,gtdist="normal",sdgt = 1.2)

tail(res)

# Criterios
criteria = list(
  crity = c("temp_min > tcrit & inc > 0", 3, 1),
  crito = c("p1 > 0.95 & inc > preseas & temp_min >= tcrit", 3, 1),
  critr = c("inc > inccrit & casos > 5", 2, 2)
)

pars.RJ <- NULL
pars.RJ[nomesregs.RJ] <- list(NULL)
pars.RJ[["Metropolitana I"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = 100, preseas=8.2, posseas = 7.6, legpos="bottomright")


ale <- fouralert(res, pars = pars.RJ[["Metropolitana I"]], crit = criteria, pop = 1000000)


# insere param

library(devtools)
devtools::install_github("claudia-codeco/AlertTools")

?write.parameters

