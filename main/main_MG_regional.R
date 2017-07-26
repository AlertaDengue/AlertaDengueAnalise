# ==================================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado de Minas Gerais
# ==================================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201729


# ------------------------------- 
# Regional de Saude de Sete Lagoas
# -------------------------------
aleMG_RS_SeteLagoas <- update.alerta(region = "Sete Lagoas", pars = pars.MG, crit = MG.criteria, 
                                   datasource = con, sefinal=data_relatorio, writedb = FALSE)


bolSeteLagoas=configRelatorioRegional(tipo="simples",uf="Minas Gerais", regional="Sete Lagoas", sigla = "MG", data=data_relatorio, 
                                    alert=aleMG_RS_SeteLagoas, pars = pars.MG, shape=MG.shape, varid=MG.shapeID,
                                    dir=MG.SeteLagoas.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = aleMG_RS_SeteLagoas, pdf = bolSeteLagoas, dir = "Relatorio/MG/Regionais/SeteLagoas")


# ----- Fechando o banco de dados
dbDisconnect(con)
