## Alertas municipais do Estado do Rio de Janeiro
#==============================
# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Rio de Janeiro"
sig = "RJ"
shape="AlertaDengueAnalise/report/RJ/shape/33MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/RJ/Municipios"
dir_rel = "Relatorio/RJ/Municipios"


# logging -------------------------------- 
#habilitar se quiser
# alog = paste0("ale_",Sys.Date(),".log")
if (logging == TRUE){
  aalog <- paste0("AlertaDengueAnalise/",alog)
  print(aalog)
}

# data do relatorio:---------------------
#data_relatorio = 201851
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidade -------------------------------
#geo <- 3304557

#
### Cidade do Rio de Janeiro ------------
if(geo == 3304557){
  params <- read.parameters(geo, cid10 = "A90")
  criter <- setCriteria(rule="Af", values = )
  ale.den <- alertaRio()
}


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


