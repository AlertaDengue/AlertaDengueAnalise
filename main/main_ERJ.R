# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
# Cabeçalho igual para todos ------------------------------
setwd("~/"); library("AlertTools", quietly = TRUE)
library("RPostgreSQL", quietly = TRUE)
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
INLA:::inla.dynload.workaround()

aalog <- paste0("AlertaDengueAnalise/",alog)
print(aalog)
# ---------------------------------------------------------
# ----- data do relatorio:
#data_relatorio = 201951


# ---- Calcula alerta Dengue: 
aleRJ <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, 
                   datasource = con, sefinal=data_relatorio, writedb = writedb,adjustdelay = TRUE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

# ---- Calcula alerta Chik:
aleRJ.chik <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, cid10="A92.0",
                            datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = TRUE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

if(write_report) { # so dengue
  bolRJ=configRelatorioEstadual(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, tsdur=104,
                             alert=aleRJ, pars = pars.RJ, shape=RJ.shape, varid=RJ.shapeID,
                              dir=RJ.out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale = aleRJ, pdf = bolRJ, dir = "Relatorio/RJ/Estado")
}


save(aleRJ,aleRJ.chik, file = paste0("alertasRData/aleRJ",data_relatorio,".RData"))


# ----- Fechando o banco de dados
dbDisconnect(con)




