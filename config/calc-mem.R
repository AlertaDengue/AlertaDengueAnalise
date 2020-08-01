# Uso do MEM 
library(tidyverse); library(assertthat)
library(AlertTools)
library(RPostgreSQL)
con <- DenguedbConnect(pass = "aldengue")
#mun_list <- getCidades(uf = "Minas Gerais", datasource=con)$municipio_geocodigo
#thresMG <- infodengue_apply_mem(mun_list=mun_list,database=con)

#save(thresMG, file ="thresMG.RData")

#thresMG$mem

#mun_list2 <- c(3117835, 3152139)



#cida <-  getCidades(uf = "Minas Gerais", datasource=con)
#cida[cida$nome == "Confins",]

thresPOA <- infodengue_apply_mem(4314902,database=con)
save(thresPOA, file = "thresPOA.RData")
