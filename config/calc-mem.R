# Uso do MEM 
library(tidyverse); library(assertthat)
library(AlertTools)
library(RPostgreSQL)
con <- DenguedbConnect(pass = "aldengue")

comando <- "SELECT geocodigo FROM \"Dengue_global\".\"Municipio\" where geocodigo < 2200000 AND
geocodigo > 2100000"
mun_list <- dbGetQuery(con, comando)

#mun_list <- getCidades(uf = "Maranhão", datasource=con)$municipio_geocodigo
thresMA <- infodengue_apply_mem(mun_list=mun_list$geocodigo[1],database=con)

save(thresMA, file ="thresMA.RData")

#thresMG$mem

#mun_list2 <- c(3117835, 3152139)

thresMA <- infodengue_apply_mem(mun_list=2101202,database=con)

#cida <-  getCidades(uf = "Minas Gerais", datasource=con)
#cida[cida$nome == "Confins",]

#thresPOA <- infodengue_apply_mem(4314902,database=con)
#save(thresPOA, file = "thresPOA.RData")
