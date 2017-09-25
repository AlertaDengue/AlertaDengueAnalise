# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Espírito Santo
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

# ----- data do relatorio:

data_relatorio = 201737


# ---- Calcula alerta: 

aleES <- update.alerta(region = names(pars.ES), pars = pars.ES, state = "Espírito Santo", crit = ES.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

bolES=configRelatorioEstadual(uf="Espírito Santo", sigla = "ES", data=data_relatorio, tsdur=104,
                              alert=aleES, pars = pars.ES, shape=ES.shape, varid=ES.shapeID,
                              dir=ES.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = aleES, pdf = bolES, dir = "Relatorio/ES/Estado")

rm(aleES,bolES)

# ----- Fechando o banco de dados
dbDisconnect(con)

