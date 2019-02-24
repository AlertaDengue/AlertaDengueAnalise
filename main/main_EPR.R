# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Paraná
# 6=============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ---- Calcula alerta: 
con <- DenguedbConnect()

# ----- data do relatorio:
data_relatorio = 201907

alePR <- update.alerta(state = "Paraná",region = names(pars.PR), pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE) #, state = "Paraná"

bolPR=configRelatorioEstadual(uf="Paraná", sigla = "PR", data=data_relatorio, tsdur=104,
                                    alert=alePR, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                                    dir=PR.out, datasource=con, geraPDF=TRUE)



publicarAlerta(ale = alePR, pdf = bolPR, dir = "Relatorio/PR/Estado")


rm(alePR,bolPR)
# ----- Fechando o banco de dados
dbDisconnect,(con)

