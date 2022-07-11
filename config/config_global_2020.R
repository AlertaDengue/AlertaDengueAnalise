# ====================================================
# Arquivo de configuracao global do Alerta Dengue 2020
# ====================================================

#------- Pacotes para carregar 

pkgs <- c("foreign", "tidyverse", "forecast", "RPostgreSQL", "xtable",
          "zoo","assertthat","DBI",
          "futile.logger","lubridate", "grid","INLA",
          "cgwtools","fs","miceadds","AlertTools")

lapply(pkgs, library, character.only = TRUE ,quietly = T)

# tirei: "ggplot2","gridExtra","ggTimeSeries","ggridges" 
# explicita o diretorio base
basedir = system("pwd", intern=TRUE)
print(basedir)

# estados no Infodengue
estados_Infodengue <- data.frame(estado = c("Santa Catarina", "Paraná", "Rio de Janeiro", "Minas Gerais",
                                            "Espírito Santo","Ceará", "Maranhão", "Acre"),
                                 sigla = c("SC","PR","RJ","MG","ES","CE","MA","AC"),
                                 dengue = TRUE,
                                 chik = c(FALSE,FALSE,FALSE,TRUE,FALSE,TRUE,TRUE,FALSE),
                                 zika = c(FALSE,FALSE,FALSE,FALSE,FALSE,TRUE,TRUE,FALSE))


# INLA
#INLA::inla.binary.install()

