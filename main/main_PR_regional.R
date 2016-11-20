# =============================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado do Paraná
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201645


# ------------------------------- 
# Regional de Saude de Cascavel
# -------------------------------
alePR_RS_Cascavel <- update.alerta(region = "Cascavel", pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)


bolCascavel=configRelatorioRegional(uf="Paraná", regional="Cascavel", sigla = "PR", data=data_relatorio, tsdur=104,
                alert=alePR_RS_Cascavel, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.Cascavel.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = alePR_RS_Cascavel, pdf = bolCascavel, dir = "Relatorio/PR/Regionais/Cascavel")


# ----- Fechando o banco de dados
dbDisconnect(con)

