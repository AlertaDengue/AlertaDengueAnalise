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

has_inla <- FALSE
if (requireNamespace("INLA", quietly = TRUE)) {
  suppressPackageStartupMessages(library(INLA))
  has_inla <- exists("inla", mode = "function")
}

if (!has_inla) {
  message("[config] INLA/inla() indisponível. Nowcasting bayesiano desativado.")
}

# tirei: "ggplot2","gridExtra","ggTimeSeries","ggridges" 
# explicita o diretorio base
basedir = system("pwd", intern=TRUE)
print(basedir)

# estados no Infodengue
estados_Infodengue <- data.frame(estado = c("Acre", "Alagoas", "Amapá", "Amazonas",
                                            # "Bahia", "Ceará", "Distrito Federal",
                                            # "Espírito Santo", "Goiás", "Maranhão",
                                            # "Mato Grosso", "Mato Grosso do Sul",
                                            # "Minas Gerais", "Pará", "Paraíba",
                                            # "Paraná", "Pernambuco", "Piauí",
                                            # "Rio de Janeiro", "Rio Grande do Norte",
                                            # "Rio Grande do Sul", "Rondônia",
                                            # "Roraima", "Santa Catarina",
                                            "São Paulo", "Sergipe", "Tocantins"),
                                 sigla = c("AC", "AL", "AP", "AM",
                                          #  "BA", "CE", "DF",
                                          #  "ES", "GO", "MA",
                                          #  "MT", "MS",
                                          #  "MG", "PA", "PB",
                                          #  "PR", "PE", "PI",
                                          #  "RJ", "RN",
                                          #  "RS", "RO",
                                          #  "RR", "SC",
                                           "SP", "SE", "TO"),
                                 dengue = FALSE,
                                 chik = TRUE,
                                 zika = FALSE)
