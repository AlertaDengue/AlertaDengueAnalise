# tratando dados de clima ###
# problemas: missing data, noise 

library(tidyverse)
library(imputeTS)

# data
load("parameters/dados/dadosclima2022_TO.RData")

unique(clima$estacao)
tapply(clima$temp_min, clima$estacao, summary)

est = "SBPJ"

d <- clima %>%
  filter(estacao == est)

par(mfrow = c(2,1), mar = c(2,4,4,2))
plot(d$temp_max[d$estacao == est], type = "l", ylab = "temp", main = est)
lines(d$temp_min[d$estacao == est], col = 2)
plot(d$umid_max[d$estacao == est], type = "l", ylab = "umid")
lines(d$umid_min[d$estacao == est], col = 2)

d$temp_max <- ts(d$temp_max, frequency = 52, start = c(2010, 1))
plot(d$temp_max)
d$temp_max_kal <- na_kalman(d$temp_max, model = "auto.arima")
d$temp_max_seadec <- na_seadec(d$temp_max, maxgap = 8)
d$temp_max_seasplit <- na_seasplit(d$temp_max)

ggplot_na_imputations(d$temp_max, d$temp_max_kal, title = "kalman-arima")
ggplot_na_imputations(d$temp_max, d$temp_max_seadec, title = "decomposicao")
ggplot_na_imputations(d$temp_max, d$temp_max_seasplit, title = "per season")

casosD <- casosDengue[, c("SE", "cidade", "casos", "nome", "pop")] %>%
  left_join(wu, by = c("cidade" = "municipio_geocodigo")) %>% 
  left_join(clima, by = c("SE"="SE", "estacao_wu_sec" = "estacao")) %>%
  left_join(clima, by = c("SE"="SE", "codigo_estacao_wu" = "estacao")) %>%
  mutate(ano = floor(SE/100),
         sem = SE-ano*100) %>%
  rename(dengue = casos)
names(casosD)

par(mfrow = c(2,1), mar = c(2,4,4,2))
plot(casosD$temp_max.x[casosD$cidade == 1700251], type = "l", ylab = "temp", main = est)
lines(casosD$temp_max.y[casosD$cidade == 1700251], col = 2)
plot(d$umid_max[d$estacao == est], type = "l", ylab = "umid")
lines(d$umid_min[d$estacao == est], col = 2)

names(casosD)

y <- lm(temp_max.x ~ temp_max.y , data = casosD[casosD$cidade == 1700251,])
summary(y)
temp_max.x.p <- fitted(y)
plot(casosD$temp_max.x[casosD$cidade == 1700251], type = "l")
lines(casosD$temp_max.y[casosD$cidade == 1700251], col = 2)
