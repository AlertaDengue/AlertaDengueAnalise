# ====================================================
# Arquivo de configuracao global do Alerta Dengue 2020
# ====================================================

#------- Pacotes para carregar 

pkgs <- c("foreign", "forecast", "RPostgreSQL", "xtable",
          "zoo","tidyverse","assertthat","AlertTools",
          "futile.logger","ggplot2","gridExtra","lubridate",
          "ggTimeSeries","ggridges","grid","INLA","cgwtools")

lapply(pkgs, library, character.only = TRUE ,quietly = T)

# explicita o diretorio base
basedir = system("pwd", intern=TRUE)
print(basedir)

# codigos das figuras dos boletins
source("AlertaDengueAnalise/config/publicar_alerta.R")

# INLA
INLA:::inla.dynload.workaround()


