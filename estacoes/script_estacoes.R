##Script para escolher as estações preferênciais


library(devtools)
library(tidyverse)
library(assertthat)
library(RPostgreSQL)
#install_github("claudia-codeco/AlertTools")
library(AlertTools)
library(dplyr)

# Baixar csv do estado: https://estacoes.dengue.mat.br/

df <- read.csv2("~/boletins/estacoes/dados/estações-mais-proximas-pr.csv", sep=",", header = F)
df <- df %>%
  rename(Município=V1, Código=V2,Estação=V3,ICAO=V4,WMO=V5, Distância= V6) 

#selecionar as estações

df_icao <- unique(df$ICAO)
icao <- str_c(df_icao, collapse= "','")
icao <- as.name(icao)
print(paste0("'",icao,"'"))

##Verificar se tem todos municípios
length(unique(df$Município))

##Santa catarina
#Codigos: 4212650=4209409,   4220000= 4207007


#Municípios: Pescaria Brava = laguna , Balneário Rincão = içara


#pescaria_brava <- df %>%
#  filter(Código=="4209409")

#pescaria_brava$Município <- "PESCARIA BRAVA"
#pescaria_brava$Código <- as.integer(4212650)



#balneario_rincao <- df %>%
#  filter(Código=="4207007")

#balneario_rincao$Município <- "BALNEÁRIO RINCÃO"
#balneario_rincao$Código <- as.integer(4220000)


#df <- rbind(df,balneario_rincao,pescaria_brava)


###Dados clima

## acessar e consultar o servidor Infodengue ##
## requer autorização ##

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC


con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "infodengue_ro", host = "localhost", 
                 password = "denguezika")

con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = "flavivirus")

# consultar serie temporal de clima por estacao meteorologica
clima <- getWU(stations = c('SBAS','SBLO','SBXO','SBBI','SBPG','SBCT','SBJV','SBCA','SBTD','SBGU','SBFI','SBMG','SBDN','SBML','SBGS','SBTL','SBCH','SBCD','SBBU'
                            ), vars = c("temp_min", "umid_max", 
                                                      "umid_min", "temp_max"))



dbDisconnect(con)



clima <- clima %>% rename(ICAO=estacao)


#write.csv2(clima,"~/Documentos/infodengue/clima_rj.csv")

#clima <- read.csv2("~/Documentos/infodengue/clima_sc.csv")


##Frequência das melhores estações


df_freq <- clima %>%
   group_by(ICAO) %>%
  filter(temp_min != 'NA' & temp_min != 'NaN')

df_freq_new <- clima %>%
  filter(SE >= "201801") %>%
  group_by(ICAO) %>%
  filter(temp_min != 'NA' & temp_min != 'NaN')


freq_estacoes <- count(df_freq, 'ICAO')
freq_new <-  count(df_freq_new, 'ICAO') %>%
  rename(n_new=n)


freq_final <- freq_estacoes %>%
  left_join(freq_new)


df_estacoes <- freq_final %>%
  arrange(-n_new,-n)



dados <- df_estacoes %>%
  left_join(df)%>% 
  arrange(Município,-n_new,-n)


#dados final
#Critérios: Período: 201801 >= 85% ou 
#           Período: 201001 >= 50%

data_new <- clima %>%
  filter(SE >= "201801")


dados_final <- dados %>%
  filter(n >= length(unique(clima$SE))/2 | n_new >= length(unique(data_new$SE))*0.85) %>%
  group_by(Município) %>%
  slice_head(n=2)%>% 
  arrange(Município) 
#verificar se tem todos os municípios

length(unique(dados_final$Município))

estacoes <- dados_final %>%
  select(Município,Código,ICAO)

write.csv2(estacoes,"~/boletins/estacoes/estacoes_pr.csv")

###############################################################
