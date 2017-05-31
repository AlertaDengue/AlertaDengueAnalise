# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

# ----- data do relatorio:
data_relatorio = 201721
=======

# ---- Calcula alerta: 

aleRJ <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, 
                   datasource = con, sefinal=data_relatorio, writedb = FALSE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

bolRJ=configRelatorioEstadual(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, tsdur=104,
                              alert=aleRJ, pars = pars.RJ, shape=RJ.shape, varid=RJ.shapeID,
                              dir=RJ.out, datasource=con, geraPDF=TRUE)


publicarAlerta(ale = aleRJ, pdf = bolRJ, dir = "Relatorio/RJ/Estado")

rm(aleRJ,bolRJ)

# ----- Fechando o banco de dados
dbDisconnect(con)




