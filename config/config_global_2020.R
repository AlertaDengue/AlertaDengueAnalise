# ====================================================
# Arquivo de configuracao global do Alerta Dengue 2020
# ====================================================

#------- Pacotes para carregar 

pkgs <- c(
  "parallel",
  "foreign", "tidyverse", "forecast", "RPostgreSQL", "xtable",
  "zoo", "assertthat", "DBI",
  "futile.logger", "lubridate", "grid",
  "cgwtools", "fs", "miceadds", "AlertTools"
)


lapply(pkgs, library, character.only = TRUE, quietly = TRUE)

has_inla <- requireNamespace("INLA", quietly = TRUE)
if (has_inla) {
  suppressPackageStartupMessages(library("INLA", character.only = TRUE))
} else {
  message("[config] INLA not installed. Bayesian nowcasting will be disabled.")
}

# tirei: "ggplot2","gridExtra","ggTimeSeries","ggridges" 
# explicita o diretorio base
basedir = system("pwd", intern=TRUE)
print(basedir)

# estados no Infodengue
estados_Infodengue <- data.frame(estado = c("Acre"),
                                 sigla = c("AC"),
                                 dengue = TRUE,
                                 chik = FALSE,
                                 zika = FALSE)
