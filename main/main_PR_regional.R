# =============================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado do Paraná
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201636


# ------------------------------- 
# Regional de Saude de Cascavel
# -------------------------------
alePR_RS_Cascavel <- update.alerta(region = "Cascavel", pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

res=configRelatorioRegional(uf="Paraná", regional="Cascavel", sigla = "PR", data=data_relatorio, 
                alert=alePR_RS_Cascavel, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.Cascavel.out, datasource=con)

#nome = "EPR-2016-teste.pdf"
system(paste("cp ~/AlertaDengueAnalise/report/PR/Regionais/Cascavel/boletins/PR-RS-Cascavel-2016-09-19.pdf Relatorio/PR/PR-RS-Cascavel"))#,nome,sep=""

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(alePR_RS_Cascavel)) res=write.alerta(alePR_RS_Cascavel[[i]], write="db")  


# ----- Fechando o banco de dados
dbDisconnect(con)

