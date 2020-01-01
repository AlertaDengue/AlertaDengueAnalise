# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Paraná
# 6=============================================================================
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
#data_relatorio = 201949

alePR <- update.alerta(state = "Paraná",region = names(pars.PR), pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = writedb) #, state = "Paraná"

if(write_report) {
  bolPR=configRelatorioEstadual(uf="Paraná", sigla = "PR", data=data_relatorio, tsdur=104,
                                    alert=alePR, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                                    dir=PR.out, datasource=con, geraPDF=TRUE)



  publicarAlerta(ale = alePR, pdf = bolPR, dir = "Relatorio/PR/Estado")
}

save(alePR,file = paste0("alertasRData/alePR",data_relatorio,".RData"))

# ----- Fechando o banco de dados
dbDisconnect(con)

