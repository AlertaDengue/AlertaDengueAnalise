########################################
## time of first event of transmission
## Infodengue
## claudia codeco                       
## 14 mar 2022
########################################

# Goal: calculate the first event of transmission 

library(tidyverse)
#library(RPostgreSQL)
library(zoo)
library(lubridate)
library(DescTools) 
library(sf)
library(brazilmaps)


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

dd <- d |>
  group_by(municipio_geocodigo) |>
  mutate(pop = mean(pop),
         transmissao2 = zoo::rollapply(transmissao, 2, sum, align = "right", fill = NA),
         transmissao3 = zoo::rollapply(transmissao, 3, sum, align = "right", fill = NA)) 


cc <- ch |>
  group_by(municipio_geocodigo) |>
  mutate(pop = mean(pop),
         transmissao2 = zoo::rollapply(transmissao, 2, sum, align = "right", fill = NA),
         transmissao3 = zoo::rollapply(transmissao, 3, sum, align = "right", fill = NA))

# data do primeiro evento de transmissao (2 semanas)
tt2 <- dd |>
  filter(transmissao2 ==2) |>
  group_by(municipio_geocodigo) |>
  summarise(initrans = min(data_iniSE),
            pop = mean(pop))

# data do primeiro evento de transmissao (2 semanas)
cc2 <- cc |>
  filter(transmissao2 ==2) |>
  group_by(municipio_geocodigo) |>
  summarise(initrans = min(data_iniSE))

tt2$initrans <- format(as.Date(tt2$initrans, format="%Y-%m-%d"),"%Y")
cc2$initrans <- format(as.Date(cc2$initrans, format="%Y-%m-%d"),"%Y")

tapply(tt2$municipio_geocodigo, tt2$initrans,length)

mean(tapply(tt2$municipio_geocodigo, tt2$initrans,length)[9:13])
tttt <- tapply(tt2$pop, tt2$initrans,sum)
sum(tttt[9:13])
sd(tttt[8:13])

# focus on 2022
m22 <- tt2 %>%
  filter(initrans == 2022) %>%
  mutate(uf = floor(municipio_geocodigo/10^5))

table(m22$uf)
(8+11+14)/sum(table(m22$uf))
## Mapa
shape_city <- get_brmap("City")
shape_uf <- get_brmap("State")

shape_den <- shape_city %>%
  left_join(tt2, by = c("City"="municipio_geocodigo"))

st_write(shape_den, "mapa-1a-transmissao-dengue.shp")
