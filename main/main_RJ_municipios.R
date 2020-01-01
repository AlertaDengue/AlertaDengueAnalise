## Alertas municipais do Estado do Rio de Janeiro
#==============================
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
#**********************************
### Cidade do Rio de Janeiro 
#***********************************

# Dengue 
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con,se = data_relatorio, verbose=FALSE)        # calcula o alerta


# Chikungunya
alerioC <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, cid10 = "A920", 
                     datasource=con, se = data_relatorio, verbose=FALSE) 


alerioC <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, cid10 = "A920", datasource=con, se = data_relatorio, verbose=FALSE) 
#dd <- write.alertaRio(obj = alerioC, write = "db")
#write.alertaRio(obj = alerio, write = "db")

# Boletim de dengue e chik
if(write_report) {
  bolrio <- configRelatorioRio( data=data_relatorio, alert=alerio, alertC= alerioC, shape=RJ.aps.shape,
                              dirout=RJ.RiodeJaneiro.out, datasource=con, geraPDF=TRUE)


  publicarAlerta(ale = alerio, pdf = bolrio, dir = "Relatorio/RJ/Municipios/RiodeJaneiro")
}

save(alerio,alerioC, file = paste0("alertasRData/aleRJ-mn",data_relatorio,".RData"))

res<-write.alertaRio(alerioC, write = "db")
rm(alerio,alerioC,bolrio)


#***************************************************
# Cidade de Campos de Goytacazes
#***************************************************

#aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
#                           datasource = con, sefinal=data_relatorio, writedb = TRUE, adjustdelay = TRUE)
#aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
#                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE)

#bolCampos <- configRelatorioMunicipal(alert = aleCampos, tipo = "completo", siglaUF = "RJ", data = data_relatorio, pars = pars.RJ,
#                                             dir.out = RJ_CamposdosGoytacazes.out, geraPDF = TRUE)

#publicarAlerta(ale = aleCampos, pdf = bolCampos, dir = "Relatorio/RJ/Municipios/CamposdosGoytacazes")

#rm(aleCampos,bolCampos)


# ----- Fechando o banco de dados
dbDisconnect(con)


