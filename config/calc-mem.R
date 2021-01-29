# Uso do MEM 
library(tidyverse); library(assertthat)
library(AlertTools)
library(RPostgreSQL)
con <- DenguedbConnect(pass = "")

#comando <- "SELECT geocodigo FROM \"Dengue_global\".\"Municipio\" where geocodigo = 3170206"
#mun_list <- dbGetQuery(con, comando)

mun_list <- getCidades(uf = "Santa Catarina", datasource=con)$municipio_geocodigo
thres <- infodengue_apply_mem(mun_list=mun_list, database=con)
thres

# aqui verificar se nao tem NA
summary(thres$thresholds)
summary(thres$min_threshold_inc)
summary(thres$percentiles)
summary(thres$mem)

# caso tenha:
pp <- thres$thresholds$municipio_geocodigo[is.na(thres$thresholds$limiar_epidemico)]
for (i in pp){
  thres$thresholds$limiar_epidemico[thres$thresholds$municipio_geocodigo == i] <- 
    thres$min_threshold_inc$mininc_epi[thres$min_threshold_inc$municipio_geocodigo == i]
  
  thres$thresholds$limiar_preseason[thres$thresholds$municipio_geocodigo == i] <- 
    thres$min_threshold_inc$mininc_pre[thres$min_threshold_inc$municipio_geocodigo == i]
  
  thres$thresholds$limiar_posseason[thres$thresholds$municipio_geocodigo == i] <- 
    thres$min_threshold_inc$mininc_pos[thres$min_threshold_inc$municipio_geocodigo == i]
  
} 
summary(thres$thresholds)

save(thres, file ="thresSC.RData")

#thresMG$mem

#mun_list2 <- c(3117835, 3152139)

thresMA <- infodengue_apply_mem(mun_list=2101202,database=con)

#cida <-  getCidades(uf = "Minas Gerais", datasource=con)
#cida[cida$nome == "Confins",]

#thresPOA <- infodengue_apply_mem(4314902,database=con)
#save(thresPOA, file = "thresPOA.RData")
