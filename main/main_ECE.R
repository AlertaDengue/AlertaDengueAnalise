# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Ceará
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ---- Calcula alerta: 
con <- DenguedbConnect()

# ----- data do relatorio:
data_relatorio = 201739

aleCE <- update.alerta(region = names(pars.CE), state="Ceará", pars = pars.CE, crit = CE.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE) 

bolCE=configRelatorioEstadual(uf="Ceará", sigla = "CE", data=data_relatorio, tsdur=300,
                                    alert=aleCE, pars = pars.CE, shape=CE.shape, varid=CE.shapeID,
                                    dir=CE.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = aleCE, pdf = bolCE, dir = "Relatorio/CE/Estado")


# ----------------- Fortaleza

aleFort <- update.alerta(city = 2304400, pars = pars.CE[["Fortaleza"]], crit = CE.criteria, 
                         datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE)

bolFort = configRelatorioMunicipal(alert = aleFort, tipo = "completo", siglaUF = "CE", 
                                   data = data_relatorio, pars = pars.CE,
                                   dir.out = CE.Fortaleza.out, geraPDF = TRUE)

publicarAlerta(ale = aleFort, pdf = bolFort, dir = "Relatorio/CE/Municípios/Fortaleza")

rm(aleCE,bolCE)
# ----- Fechando o banco de dados
dbDisconnect(con)

