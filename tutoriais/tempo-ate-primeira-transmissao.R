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

st_write(shape_den, "mapa-1a-transmissao-dengue-22.shp")

table(shape_den$initrans)

# ini em 23 ou 24
library(sf)
library(ggplot2)

shape_den2023 <- shape_den %>%
  mutate(
      ini = case_when(
      initrans %in% c("2010","2011","2012","2013","2014","2015","2016","2017",
                      "2018","2019","2020","2021","2022") ~ "2010-2022",
      initrans %in% c("2023","2024") ~ "2023-2024",
      TRUE ~ NA ))
           
          
ggplot() +
  geom_sf(data = shape_den2023, aes(fill = as.factor(ini))) +
  scale_fill_manual(values = c("grey", "red"), na.value = "white",
                    name = "ano") + # Escolha de paleta de cores
  theme_minimal() +
  ggtitle("Início de transmissão de dengue")

# 22, 23 e 24

m234 <- tt2 %>%
  filter(initrans >= 2022) %>%
  mutate(uf = floor(municipio_geocodigo/10^5))

shape_den234 <- shape_city %>%
  left_join(m234, by = c("City"="municipio_geocodigo"))

ggplot() +
  geom_sf(data = shape_den234, aes(fill = initrans)) +
  scale_fill_manual(values = c("red", "orange", "yellow")) + # Definir cores para cada categoria de 'x'
  theme_minimal()
mun24 <- shape_den234[which(shape_den234$initrans == "2024"), c(1,2,3,4,5,6,7,8)]

### caracteristicas pop das cidades 

load("historico-alerta.RData")

dd <- dd %>%
  mutate(pop10000 = as.numeric(pop > 10000),
         pop100000 = as.numeric(pop > 100000),
         ano = floor(SE/100))

names(dd)

d10000 <- dd %>% 
  group_by(pop10000, ano) %>%
  summarise(casos = sum(casos),
            pop = sum(pop)) %>%
  mutate(inc = casos/pop *100000)


barplot(casos ~ ano + pop10000, data = d10000,beside = TRUE)
barplot(inc ~ ano + pop10000, data = d10000,beside = TRUE)


d100000 <- dd %>% 
  group_by(pop100000, ano) %>%
  summarise(casos = sum(casos),
            pop = sum(pop)) %>%
  mutate(inc = casos/pop,
         p = inc/(1-inc),
         odds = p/(1-p))


barplot(casos ~ ano + pop100000, data = d100000,
        beside = TRUE, main = "total de casos de dengue", names.arg = d100000$ano, las = 2,
        xlab = "", col = c(rep("blue", 15), rep("green",15)))
abline(h = 1000000, lty = 2)

barplot(inc*100000 ~ ano + pop100000, data = d100000,
        beside = TRUE, main = "incidência acumulada de dengue", names.arg = d100000$ano, las = 2,
        xlab = "", col = c(rep("blue", 15), rep("green",15)))
abline(h = c(10,20,30,40), lty = 3)


totpop <- sum(d100000$pop[d100000$ano == 2024])
d100000$pop[d100000$ano == 2024]/totpop

p0 <- d100000 %>%
  filter(pop100000 == 0) %>%
  arrange(ano)

p1 <- d100000 %>%
  filter(pop100000 == 1) %>%
  arrange(ano)

p0$odds1 <- p1$odds
p0$oddsratio <- p0$odds1/p0$odds

barplot(p0$oddsratio ~ p0$ano, col = "orange", xlab = "", 
        ylab = "odds ratio", main = "razão de chance de caso em muns populosos")  
abline(h = 1, col = 2)

