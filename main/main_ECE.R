# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Ceará
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

# ---- Calcula alerta estadual ----------------------------

# ----- data do relatorio:
#data_relatorio = 201951

# Dengue
aleCE <- update.alerta(region = names(pars.CE)[1], state="Ceará", pars = pars.CE, crit = CE.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = FALSE) 

# Chik
aleCE.chik <- update.alerta(region = names(pars.CE)[1], state="Ceará", pars = pars.CE, crit = CE.criteria, cid10="A92.0",
                            datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = FALSE) 
# Zika
aleCE.zika <- update.alerta(region = names(pars.CE)[1], state="Ceará", pars = pars.CE, crit = CE.criteria, cid10="A92.8",
                            datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = FALSE) 

## boletim
if(write_report) {
  flog.info("writing boletim estadual...", name = aalog)
  bolCE <- configRelatorioEstadual(uf="Ceará", sigla = "CE", data=data_relatorio, varcli = "umid_max", tsdur=300,
                                    alert=aleCE, pars = pars.CE, shape=CE.shape, varid=CE.shapeID,
                                    dir=CE.out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale = aleCE, pdf = bolCE, dir = "Relatorio/CE/Estado")
  
  if (!bolCE %in% ls("Relatorio/CE/Estado")) futile.logger::flog.error("pdf boletin not saved")
  
} else {flog.warn("boletim estatual skipped by user", name = alog)}


# ----------------- Fortaleza

# Dengue

flog.info("alerta dengue Fortaleza executing...", name = aalog)
aleFort <- update.alerta(city = 2304400, pars = pars.CE[["Fortaleza"]], cid10="A90",crit = CE.criteria, 
                         datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE)

#res = write.alerta(obj = aleFort, write = "db")
#if(write_report) {
#bolFort <- configRelatorioMunicipal(alert = aleFort, tipo = "simples", varcli = "umid_max", siglaUF = "CE", 
#                                    data = data_relatorio, pars = pars.CE,
#                                    dir.out = CE.Fortaleza.out, geraPDF = TRUE)
#}
# Chik 
aleFortC <- update.alerta(city = 2304400, pars = pars.CE.chik[["Fortaleza"]], cid10="A92.0", crit = CE.criteria, 
                         datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = FALSE)

#Zika
aleFortZ <- update.alerta(city = 2304400, pars = pars.CE.zika[["Fortaleza"]], cid10="A92.8", crit = CE.criteria, 
                          datasource = con, sefinal=data_relatorio, writedb = writedb, adjustdelay = FALSE)

# Boletim Arbo
if(write_report) {
  flog.info("writing boletim Arbo Fortaleza...", name = aalog)
bolFort <- configRelatorioMunicipal(alert = aleFort, alechik = aleFortC, alezika = aleFortZ, tipo = "simples", varcli = "umid_max", siglaUF = "CE", 
                                   data = data_relatorio, pars = pars.CE,
                                   dir.out = CE.Fortaleza.out, geraPDF = TRUE)

publicarAlerta(ale = aleFort, pdf = bolFort, dir = "Relatorio/CE/Municipios/Fortaleza")
}

Rfile = paste0("alertasRData/aleCE",data_relatorio,".RData")
flog.info("saving ...", Rfile, capture = TRUE, name = aalog)

save(aleCE, aleCE.chik, aleCE.zika, aleFort, aleFortC, aleFortZ, file = Rfile)

# ----- Fechando o banco de dados
dbDisconnect(con)


