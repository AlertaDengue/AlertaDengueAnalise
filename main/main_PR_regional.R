# =============================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado do Paraná
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201635


# ------------------------------- 
# Regional de Saude de Cascavel
# -------------------------------
alePR_RS_Cascavel <- update.alerta(region = "Cascavel", pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

res=configRelatorioRegional(uf="Paraná", regional="Cascavel", sigla = "PR", data=data_relatorio, 
                alert=alePR_RS_Cascavel, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.Cascavel.out, datasource=con)

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(alePR_RS_Cascavel)) res=write.alerta(alePR_RS_Cascavel[[i]], write="db")  


# ----- Fechando o banco de dados
dbDisconnect(con)

