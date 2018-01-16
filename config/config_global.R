# ====================================================
# Arquivo de configuracao global do Alerta Dengue
# ====================================================

#------- Pacotes para carregar 

library(foreign)
library(forecast)
library("RPostgreSQL")
library(xtable)
library(zoo)
library(AlertTools)

# explicita o diretorio base
basedir = system("pwd", intern=TRUE)

source("AlertaDengueAnalise/config/codigofiguras.R")
source("AlertaDengueAnalise/config/configRelatorio.r")

# ====================================================
## Parametros globais do alerta
# ====================================================

## -------- Distribuicao do tempo de geracao da dengue:
gtdist="normal"; meangt=3; sdgt = 1.2   


## --------- Regras de mudança de nivel de alerta
# (criterio, duracao da condicao para turnon, turnoff)
#criteria = list(
#crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 2),
#crito = c("p1 > 0.9 & inc > preseas", 2, 2),
#critr = c("inc > inccrit", 1, 2)
#)

### DENGUE  ### 

criteria = list(
  #crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 2),
  crity = c("temp_min > tcrit & inc > 0", 3, 1),
  crito = c("p1 > 0.95 & inc > preseas", 3, 1),
  critr = c("inc > inccrit & casos > 5", 2, 2)
)

criteriaCE = list(
  #crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 2),
  crity = c("umid_max > ucrit & inc > 0", 3, 1),
  crito = c("p1 > 0.95", 3, 1),
  critr = c("inc > inccrit & casos > 5", 2, 2)
)

criteriaCE.chik = list(
  #crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 2),
  crity = c("umid_max > ucrit & inc > 0", 3, 1),
  crito = c("p1 > 0.95", 3, 1),
  critr = c("inc > inccrit & casos > 5", 2, 2)
)

### CHIK ###

criteriaChik = list(
  crity = c("temp_min > tcrit & inc > 0", 3, 1),
  crito = c("p1 > 0.95 & temp_min >= tcrit", 3, 1),
  critr = c("inc > inccrit & casos > 5", 2, 2)
)


