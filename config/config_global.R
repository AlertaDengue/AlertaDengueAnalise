# ====================================================
# Arquivo de configuracao global do Alerta Dengue
# ====================================================

#------- Pacotes para carregar 

library(foreign)
library("RPostgreSQL")
library(xtable)
library(knitr)
#library(AlertTools)
devtools::load_all()
source("../config/codigofiguras.R")
source("../config/configRelatorio.r")

# ====================================================
## Parametros globais do alerta
# ====================================================

## -------- Distribuicao do tempo de geracao da dengue:
gtdist="normal"; meangt=3; sdgt = 1.2   


## --------- Regras de mudança de nivel de alerta
# (criterio, duracao da condicao para turnon, turnoff)
criteria = list(
crity = c("temp_min > tcrit | (temp_min < tcrit & inc > posseas)", 3, 2),
crito = c("p1 > 0.9 & inc > preseas", 2, 2),
critr = c("inc > inccrit", 1, 2)
)

