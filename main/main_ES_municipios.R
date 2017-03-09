#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
#setwd("~/")
#source("config/config_global.R") # packages e regras gerais do alerta
#source("AlertaDengueAnalise/update-alerta-temp.R")
source("config/config_global.R") # packages e regras gerais do alerta
source("config/fun_initializeSites.R") # auxiliary functions
source("config/config.R") # arquivo de configuracao do alerta (parametros)

con <- DenguedbConnect()


#data_relatorio = 201706


#***************************************************
# Cidade de Alfredo Chaves
#***************************************************


#aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["Sul"]], crit = ES.criteria, 
#                                  datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)


aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "completo", siglaUF = "ES", 
                                             data = data_relatorio, pars = pars.ES, 
                                             dir.out = ES.MN.AlfredoChaves.out, geraPDF = TRUE) #

#publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "Relatorio/ES/Municipios/Alfredo_Chaves", writebd = FALSE)

#rm(aleAlfredoChaves,bolAlfredoChaves)

# ----- Fechando o banco de dados
dbDisconnect(con)
