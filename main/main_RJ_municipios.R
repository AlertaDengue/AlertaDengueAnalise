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

# qual municipio? -------------------------------
#geo <- 3304557


### Se Boletim da cidade do Rio de Janeiro por APS ------------------------
if(geo == 3304557){
  
  RJ.aps.shape = "AlertaDengueAnalise/report/RJ/Municipios/Rio_de_Janeiro/shape/CAPS_SMS.shp"
  RJ.aps.shapeID = "CD_GEOCMU"
  RJ.RiodeJaneiro.out = "AlertaDengueAnalise/report/RJ/Municipios/Rio_de_Janeiro"
  
  
  ale.den <- alertaRio(se = data_relatorio, cid10 = "A90", delaymethod = "fixedprob")
  ale.chik <- alertaRio(se = data_relatorio, cid10 = "A920", delaymethod = "fixedprob")
  #ale.zika <- alertaRio(se = data_relatorio, cid10 = "A92.8", delaymethod = "fixedprob")
  
  bol <- configRelatorioRio(data=data_relatorio, alert=ale.den, alertC= ale.chik, shape=RJ.aps.shape,
                                dirout=RJ.RiodeJaneiro.out, datasource=con, geraPDF=TRUE, inid = 201801)
  
  #publicarAlerta(ale = aleFort, pdf = bol, dir = "Relatorio/CE/Municipios/Fortaleza")
  save(ale.den,ale.chik, file = paste0("alertasRData/aleRJ-mn",data_relatorio,".RData"))
  #res<-write.alertaRio(alerioC, write = "db")
}else {
  
  
  
  #Se Boletim de municipios do RJ, exceto capital  ------------------------
  
  flog.info(paste("alerta dengue", geo ,"executing..."), name = aalog)
  
  ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)
  ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
  ale.zika <- pipe_infodengue(geo, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)
  
  
  # escreve?
  if(write_report) {
    # dir exists?
    nome <- ale.den[[1]]$data$nome[1]
    nomesemespaco = gsub(" ","",nome)
    nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
    out = paste0("AlertaDengueAnalise/report/RJ/Municipios/",nomesemacento) 
    dir.create(file.path(out), showWarnings = FALSE) # check if directory exists
    dir.create(file.path(paste0(out, "/figs/")), showWarnings = FALSE) # check if directory exists
    
    
    flog.info(paste("writing boletim de ", nome), name = aalog)
    bol <- configRelatorioMunicipal(alert = ale.den, alechik = ale.chik, alezika = ale.zika, tipo = "simples", 
                                    varcli = "temp_min", estado = estado, siglaUF = sig, data = data_relatorio, 
                                    dir.out = out, geraPDF = TRUE)
    
    #publicarAlerta(ale = aleFort, pdf = bol, dir = "Relatorio/RJ/Municipios/Fortaleza")
  }
  
}



# Fechando o banco de dados ------------------------------
dbDisconnect(con)


