# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
setwd("~/");library("AlertTools")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)


# ----- data do relatorio:
data_relatorio = 201912


# ---- Calcula alerta Dengue: 

aleRJ <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, 
                   datasource = con, sefinal=data_relatorio, writedb = FALSE,adjustdelay = TRUE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

bolRJ=configRelatorioEstadual(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, tsdur=104,
                              alert=aleRJ, pars = pars.RJ, shape=RJ.shape, varid=RJ.shapeID,
                              dir=RJ.out, datasource=con, geraPDF=TRUE)


publicarAlerta(ale = aleRJ, pdf = bolRJ, dir = "Relatorio/RJ/Estado")

rm(aleRJ,bolRJ)


# ---- Calcula alerta Chik:
aleCRJ <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, cid10="A92.0",
                       datasource = con, sefinal=data_relatorio, writedb = TRUE, adjustdelay = FALSE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar



# ----- Fechando o banco de dados
dbDisconnect(con)




