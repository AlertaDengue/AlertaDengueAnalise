# ==================================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado de Minas Gerais
# ==================================================================================
setwd("~/"); library("AlertTools")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)


data_relatorio = 201850

# ------------------------------- 
# Regional de Saude de Sete Lagoas
# -------------------------------
aleMG_RS_SeteLagoas <- update.alerta(region = "Sete Lagoas", pars = pars.MG, crit = MG.criteria, 
                                   datasource = con, sefinal=data_relatorio, writedb = FALSE)


bolSeteLagoas=configRelatorioRegional(tipo="simples",uf="Minas Gerais", regional="Sete Lagoas", sigla = "MG", data=data_relatorio, 
                                    alert=aleMG_RS_SeteLagoas, pars = pars.MG, shape=MG.shape, varid=MG.shapeID,
                                    dir=MG.SeteLagoas.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = aleMG_RS_SeteLagoas, pdf = bolSeteLagoas, dir = "Relatorio/MG/Regionais/SeteLagoas")


# --------------------------------
# Municipio de Contagem
# --------------------------------

aleMG_MN_Contagem <- update.alerta(city = 3118601, pars = pars.MG[["Belo Horizonte"]], crit = MG.criteria, 
                                     datasource = con, sefinal=data_relatorio, adjustdelay = TRUE, delaymethod = "bayesian",
                                   writedb = FALSE)

bolContagem=configRelatorioMunicipal(tipo="simples", siglaUF ="MG", data=data_relatorio, 
                                      alert=aleMG_MN_Contagem, pars = pars.MG[["Belo Horizonte"]], dir.out=MG.MN.Contagem.out, 
                                      geraPDF=TRUE)


# ----- Fechando o banco de dados
dbDisconnect(con)
