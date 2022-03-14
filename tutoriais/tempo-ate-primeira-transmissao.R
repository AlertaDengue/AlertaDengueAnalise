########################################
## time of first event of transmission
## Infodengue
## claudia codeco                       
## 14 mar 2022
########################################

# Goal: calculate the first event of transmission 

library(tidyverse)
library(RPostgreSQL)
library(zoo)

# 1) get data table (precisa de conexao com o banco de dados)
# dengue
dbListFields(con, c("Municipio","Historico_alerta"))
d <- dbReadTable(con, c("Municipio","Historico_alerta"))
# chik 
ch <- dbReadTable(con, c("Municipio","Historico_alerta_chik"))
dbDisconnect(con)

save(d, ch, file = "historico-alerta.RData")
load("historico-alerta.RData")


## dengue ----

# contar semanas consecutivas com Rt > 1

dd <- d %>%
  group_by(municipio_geocodigo) %>%
  mutate(transmissao2 = zoo::rollapply(transmissao, 2, sum, align = "right", fill = NA),
         transmissao3 = zoo::rollapply(transmissao, 3, sum, align = "right", fill = NA))

# data do primeiro evento de transmissao (1 semana)
tt1 <- d %>%
  filter(transmissao ==1) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

# data do primeiro evento de transmissao (2 semanas)
tt2 <- dd %>%
  filter(transmissao2 ==2) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

# data do primeiro evento de transmissao (3 semanas)
tt3 <- dd %>%
  filter(transmissao3 ==3) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

## chik ----

cc <- ch %>%
  group_by(municipio_geocodigo) %>%
  mutate(transmissao2 = zoo::rollapply(transmissao, 2, sum, align = "right", fill = NA),
         transmissao3 = zoo::rollapply(transmissao, 3, sum, align = "right", fill = NA))

# data do primeiro evento de transmissao (1 semana)
cc1 <- ch %>%
  filter(transmissao ==1) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

# data do primeiro evento de transmissao (2 semanas)
cc2 <- cc %>%
  filter(transmissao2 ==2) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

# data do primeiro evento de transmissao (3 semanas)
cc3 <- cc %>%
  filter(transmissao3 ==3) %>%
  group_by(municipio_geocodigo) %>%
  summarise(initrans = min(data_iniSE))

