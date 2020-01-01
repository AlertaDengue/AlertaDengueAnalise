# =============================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado do Paraná
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

#data_relatorio = 201739


# ------------------------------- 
# Regional de Saude de Cascavel
# -------------------------------
alePR_RS_Cascavel <- update.alerta(region = "Cascavel", pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = writedb)

if(write_report) {
  bolCascavel=configRelatorioRegional(uf="Paraná", regional="Cascavel", sigla = "PR", data=data_relatorio, tsdur=104,
                alert=alePR_RS_Cascavel, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.Cascavel.out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale = alePR_RS_Cascavel, pdf = bolCascavel, dir = "Relatorio/PR/Regionais/Cascavel")
}

save(alePR_RS_Cascavel, file = paste0("alertasRData/alePR-rg",data_relatorio,".RData"))
# ----- Fechando o banco de dados
dbDisconnect(con)

