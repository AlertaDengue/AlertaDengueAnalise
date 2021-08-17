### Parametrizacao do Infodengue ####
### autor: claudia codeco        ####
### data: jul-2021               ####   
#####################################

# Objetivo: o Infodengue tem parametros de clima e do mem que precisam ser
# recalculados periodicamente. Esse script faz a atualizacao deles no sistema

# INPUT
# o mem é calculado com o codigo calc_mem.R 
# os limiares de clima sao calculados de acordo com rotina na pasta clima-decision-tree
# que precisa ser melhor organizada
# Eles podem ser atualizados de forma independente


library("AlertTools"); library(assertthat) ; library(tidyverse)
library(RPostgreSQL)

con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)


# tabela atual de parametros
params <- dbReadTable(con, c("Dengue_global","parameters"))

# para juntar info de UF
ufs <- dbReadTable(con, c("Dengue_global", "estado"))
ufs <- ufs[,c(1,3,4,5)]
para <- params %>%
  mutate(geocodigoUF = floor(municipio_geocodigo/100000)) %>%
  left_join(ufs, by = c("geocodigoUF" = "geocodigo"))

table(para$uf)


## +++++++++++++++++++++++++++++++++++++++++++++++
## 1. Inserir todas as cidades na tabela parameters (so na primeira vez)
## +++++++++++++++++++++++++++++++++++++++++++++++

 for (i in 1:27){
   sig <- ufs$uf[i]
   nome <- str_to_title(ufs$nome[i])
   cids <- getCidades(uf = nome)
   cids <- cids$municipio_geocodigo
#   
   for (j in 1:length(cids)){
     pp = data.frame(municipio_geocodigo = cids[j], 
                         cid10 = "A90", varcli = "temp_min")
#     
     res <- write_parameters(city = pp$municipio_geocodigo,
                             cid10 = pp$cid10, 
                             params = pp, 
                             datasource = con)
   }
#   
#   
}


# ------------------------------------------
# 2. inserir estacoes (se precisar atualizar)
# ------------------------------------------
for (i in 1:27){
  sig <- ufs$uf[i]
  nome <- str_to_title(ufs$nome[i])
  wufile <- paste0("estacoes/estacoes_",sig,".csv")
  wu <- read.csv2(wufile)
  names(wu) <- c("x","municipio","geocodigo","ICAO")
  muns <- unique(wu$geocodigo)
  
  for (m in muns){
    dd <- wu[wu$geocodigo == m,]
    if (nrow(dd) == 2) dados <- data.frame(municipio_geocodigo = m,
                                           primary_station = dd$ICAO[1], 
                                           secondary_station = dd$ICAO[2])
    if (nrow(dd) == 1) dados <- data.frame(municipio_geocodigo = m,
                                           primary_station = dd$ICAO[1], 
                                           secondary_station = dd$ICAO[1])
    setWUstation(dados, UF = nome)
  }
  
}


read.parameters(cities = muns, cid10 = "A90")  # tudo OK?

#+++++++++++++++++++++++
# 3. limiares
#+++++++++++++++++++++++

load("parameters/limiar_mem_municipal_2010_2020.RData")

names(thres.mun)
n = which(is.na(thres.mun$limiar_preaseason))

for (i in 1:nrow(thres.mun)){
  if(i %in% n){
    params = data.frame(municipio_geocodigo = thres.mun$municipio_geocodigo[i], 
                        cid10 = "A90",
                        limiar_preseason = thres.mun$mininc_pre[i],
                        limiar_posseason = thres.mun$mininc_pos[i],
                        limiar_epidemico = thres.mun$mininc_epi[i])
  } else {
    params = data.frame(municipio_geocodigo = thres.mun$municipio_geocodigo[i], 
                        cid10 = "A90",
                        limiar_preseason = thres.mun$limiar_preaseason[i],
                        limiar_posseason = thres.mun$limiar_posseason[i],
                        limiar_epidemico = thres.mun$limiar_epidemico[i])
  }
  
  
  res <- write_parameters(city = params$municipio_geocodigo,
                          cid10 = params$cid10, 
                          params = params, 
                          overwrite = TRUE, datasource = con)
}



## ++++++++++++++++++++++++++++++++++++++++++++++++
## 4. Atualizacao dos parametros de receptividade 
## ++++++++++++++++++++++++++++++++++++++++++++++++
# Norte 27 = AC; 7 = AM; 5 = RO; 14 = RR; 15 = PA, 16 = AP, 9 = TO
# CO: 19 = MT; 21 = MS; 8 = DF; 17 = GO
# SE: 25 = SP; 13 = RJ ; 23 = ES FALTA MG
# Nordeste: 6 = BA; 20 = SE; 3 = AL ;12 = PI
# Sul: 
i = 26  ## 
sig <- ufs$uf[i]
nome <- str_to_title(ufs$nome[i])

load(paste0("../clima-decision-tree/resultado receptividade/recept",toupper(sig),"_2021.RData"))
recept <- receptPB[c("nome_regional", "tcrit", "umincrit", "umaxcrit", "codmodelo")]
recept$cid10 <- "A90"

#recept$umaxcrit[is.na(recept$umaxcrit)] <- 85 
#recept$codmodelo[!is.na(recept$umaxcrit)] <- "AsAw"
#recept$codmodelo[is.na(recept$tcrit)] <- "Aw"
#recept$codmodelo[2] <- "AsAw"
# verificar se os nomes das regionais estao compativeis

cids <- getRegionais(uf = nome,output = "complete")
reg <- unique(cids$regional)
reg
unique(recept$nome_regional)
all(reg %in% recept$nome_regional)
all(recept$nome_regional %in% reg)
#which(!(reg %in% recept$nome_regional))

# formatar parametros de clima para a funcao write_parameters  
# primeiro arrumar na tabela de regional mesmo, depois join para municipios
# pois write_parameters e' por municipio

pars_reg <- data.frame(regional = recept$nome_regional, 
                       cid10 = recept$cid10, 
                       varcli = NA, clicrit = NA,
                       varcli2 = NA, clicrit2 = NA,
                       codmodelo = recept$codmodelo)

for (i in 1:nrow(recept)){
  
  if(pars_reg$codmodelo[i] == "Af"){
    pars_reg$varcli[i] <- "temp_min"
    pars_reg$clicrit[i] <- recept$tcrit[i]
  }  
  if(pars_reg$codmodelo[i] == "Aw"){
    pars_reg$varcli[i] <- "umid_max"
    pars_reg$clicrit[i] <- recept$umaxcrit[i]
  }
  if(pars_reg$codmodelo[i] == "AsAw"){
    pars_reg$varcli[i] <- "temp_min"
    pars_reg$clicrit[i] <- recept$tcrit[i]
    pars_reg$varcli2[i] <- "umid_max"
    pars_reg$clicrit2[i] <- recept$umaxcrit[i]
  }
  if(pars_reg$codmodelo[i] == "Awi"){
    pars_reg$varcli[i] <- "umid_min"
    pars_reg$clicrit[i] <- recept$umincrit[i]
  }
  if(pars_reg$codmodelo[i] == "AsAwi"){
    pars_reg$varcli[i] <- "temp_min"
    pars_reg$clicrit[i] <- recept$tcrit[i]
    pars_reg$varcli2[i] <- "umid_min"
    pars_reg$clicrit2[i] <- recept$umincrit[i]
  }
}

pars_reg

pars_cid <- cids[,c("municipio_geocodigo", "cidade", "regional")] %>%
  left_join(pars_reg)


# escrevendo
for (i in 1:nrow(pars_cid)){
  if(pars_cid$codmodelo[i] %in% c("Af","Aw","Awi")){
    params = data.frame(municipio_geocodigo = pars_cid$municipio_geocodigo[i], 
                        cid10 = pars_cid$cid10[i],
                        varcli = pars_cid$varcli[i],
                        clicrit = pars_cid$clicrit[i],
                        codmodelo = pars_cid$codmodelo[i])  
  } else {
    params = data.frame(municipio_geocodigo = pars_cid$municipio_geocodigo[i], 
                        cid10 = pars_cid$cid10[i],
                        varcli = pars_cid$varcli[i],
                        clicrit = pars_cid$clicrit[i],
                        varcli2 = pars_cid$varcli2[i],
                        clicrit2 = pars_cid$clicrit2[i],
                        codmodelo = pars_cid$codmodelo[i])  
  }
  
  
  
  res <- write_parameters(city = pars_cid$municipio_geocodigo[i],
                          cid10 = pars_cid$cid10[i], 
                          params = params, 
                          overwrite = TRUE, datasource = con)
}


read.parameters(pars_cid$municipio_geocodigo)  # tudo OK?


dbDisconnect(con)

##############
# verificando a tabela parameters

# tabela atual de parametros
params <- dbReadTable(con, c("Dengue_global","parameters"))

summary(params)
n <- which(is.na(params$clicrit))
params$municipio_geocodigo[n]

# codmodelos estao coerentes com os varcli?

table(params$codmodelo, params$varcli)
table(params$codmodelo, params$varcli2)
summary(params$clicrit, params$varcli == "temp_min")

parAf <- subset(params, params$codmodelo == "Af")
table(parAf$varcli)
max(parAf$clicrit)

parAw <- subset(params, params$codmodelo == "Aw")
table(parAw$varcli)
range(parAw$clicrit)

parAwi <- subset(params, params$codmodelo == "Awi")
table(parAwi$varcli)
range(parAwi$clicrit)

parAsAw <- subset(params, params$codmodelo == "AsAw")
table(parAsAw$varcli)
range(parAsAw$clicrit)
table(parAsAw$varcli2)
range(parAsAw$clicrit2)

parAsAwi <- subset(params, params$codmodelo == "AsAwi")
table(parAsAwi$varcli)
range(parAsAwi$clicrit)
table(parAsAwi$varcli2)
range(parAsAwi$clicrit2)


########### Atualizar a tabela regional_saude! enquanto nao ela nao sumir #####

dbListFields(con, c("Dengue_global","regional_saude"))

pp <- dbReadTable(con, c("Dengue_global","parameters"))
summary(pp)

#[1] "row.names"           "municipio_geocodigo" "limiar_preseason"   
#[4] "limiar_posseason"    "limiar_epidemico"    "varcli"             
#[7] "clicrit"             "cid10"               "codmodelo"          
#[10] "varcli2"             "clicrit2"            "codigo_estacao_wu"  
#[13] "estacao_wu_sec"     

reg <- dbReadTable(con, c("Dengue_global","regional_saude"))
summary(reg)

#[1] "id"                  "municipio_geocodigo" "id_regional"        
#[4] "codigo_estacao_wu"   "nome_regional"       "limiar_preseason"   
#[7] "limiar_posseason"    "limiar_epidemico"    "estacao_wu_sec"     
#[10] "varcli"              "tcrit"               "ucrit"              
#[13] "nome_macroreg" 

inserelinha <- function(newd,li){
  el1 = paste("'",as.character(newd[li,"codigo_estacao_wu"]),"'",sep="")
  el2 = paste("'",as.character(newd[li,"estacao_wu_sec"]),"'",sep="")
  el3 = paste("'",as.character(newd[li,"varcli"]),"'",sep="")
  el4 = as.character(newd[li,"clicrit"])
  #linha = paste(el1,el2,el3,el4, sep=",")
  if (newd$varcli[li] == "temp_min") sql = paste0("UPDATE \"Dengue_global\".\"regional_saude\" SET
                                             codigo_estacao_wu = ", el1, ", estacao_wu_sec = ", el2, 
                                                  " , varcli = ", el3, ", tcrit = ",el4, " WHERE municipio_geocodigo = ",
                                                  newd$municipio_geocodigo[li])
  if (newd$varcli[li] != "temp_min") sql = paste0("UPDATE \"Dengue_global\".\"regional_saude\" SET
                                             codigo_estacao_wu = ", el1, ", estacao_wu_sec = ", el2, 
                                                  " , varcli = ", el3, ", ucrit = ",el4, " WHERE municipio_geocodigo = ",
                                                  newd$municipio_geocodigo[li])
  #print(sql)
  #dbGetQuery(con, sql)    
}
#for(i in 1:nrow(pp)) inserelinha(pp, i)

inserelinha2 <- function(newd,li){
  el1 = as.character(newd[li,"limiar_preseason"])
  el2 = as.character(newd[li,"limiar_posseason"])
  el3 = as.character(newd[li,"limiar_epidemico"])
  #linha = paste(el1,el2,el3, sep=",")
 sql = paste0("UPDATE \"Dengue_global\".\"regional_saude\" SET
              limiar_preseason = ", el1, ", limiar_posseason = ", el2, 
             " , limiar_epidemico = ", el3, " WHERE municipio_geocodigo = ",
              newd$municipio_geocodigo[li])
# print(sql)
 dbGetQuery(con, sql)
}
  
for(i in 1:nrow(pp)) inserelinha2(pp, i)


#for (i in muns52){
#sql_del <- paste0("DELETE from \"Dengue_global\".\"regional_saude\" 
#WHERE municipio_geocodigo= ",i, "")
#dbGetQuery(con, sql_del)
#}
