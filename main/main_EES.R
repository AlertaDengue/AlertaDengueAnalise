# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Espírito Santo
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Espírito Santo"
sig = "ES"
shape="AlertaDengueAnalise/report/ES/shape/32MUE250GC_SIRm.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/ES"
dir_rel = "Relatorio/ES/Estado"


# data do relatorio:---------------------
#data_relatorio = 202006
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

print(Sys.time())
# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "fixedprob", 
                           finalday = dia_relatorio); save(ale.den, file="aleden.RData")

#ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "no", 
#                            finalday = dia_relatorio); save(ale.chik, file="alechik.RData")

#ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "no", 
#                            finalday = dia_relatorio); save(ale.zika, file="alezika.RData")

print(Sys.time())
## boletim dengue estadual
if(write_report) {
  flog.info("writing boletim estadual...", name = alog)
  dirbol = paste0("Relatorio/",sig,"/Estado")
  
  new_data_relatorio <- max(ale.den[[1]]$data$SE)
  print(paste("Data real do relatorio:", new_data_relatorio))
  bol <- configRelatorioEstadual(uf=estado, sigla=sig, data=new_data_relatorio, tsdur=300,
                                 alert=ale.den, shape=shape, varid=shapeID,
                                 dir=out, datasource=con, geraPDF=TRUE)
  
  publicarAlerta(ale = ale.den, pdf = bol, dir = dirbol)
  #write_alerta(tabela_historico(ale.chik))
 
  
  if (!bol %in% ls(dirbol)) futile.logger::flog.error("pdf boletin not saved")
  
} else {flog.warn("boletim estatual skipped by user", name = alog)}



# ----- Calcula alerta arbo para Vitoria
geo = 3205309

ES.V.out = "AlertaDengueAnalise/report/CE/Municipios/Vitoria" 
flog.info("alerta dengue Vitoria executing...", name = aalog)

ale.V.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", finalday = new_dia_relatorio)
ale.V.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
#ale.V.zika <- pipe_infodengue(geo, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)


# Boletim Arbo ----------------------------------
if(write_report) {
  flog.info("writing boletim Arbo Vitoria", name = aalog)
  bolV <- configRelatorioMunicipal(alert = ale.V.den, tipo = "simples", 
                                      varcli = "temp_min", estado = estado, siglaUF = sig, 
                                   data = new_data_relatorio, dir.out = ES.V.out, geraPDF = TRUE)
  
  publicarAlerta(ale = ale.V.den, pdf = bolV, dir = "Relatorio/ES/Municipios/Vitoria")
}

# salvando objetos -------------------------
Rfile = paste0("alertasRData/aleES",new_data_relatorio,".RData")

flog.info("saving ...", Rfile, capture = TRUE, name = alog)
save(ale.den, ale.chik, ale.zika, ale.V.den, file = Rfile)


# ----- Fechando o banco de dados
dbDisconnect(con)



