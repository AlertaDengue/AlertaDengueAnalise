# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Ceará
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Ceará"
sig = "CE"
shape="AlertaDengueAnalise/report/CE/shape/23MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/CE"
dir_rel = "Relatorio/CE/Estado"


# data do relatorio:---------------------
#data_relatorio = 202002
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
print(Sys.time())

# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", 
                           finalday = dia_relatorio); save(ale.den, file="aleden.RData")

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "fixedprob", 
                            finalday = dia_relatorio); save(ale.chik, file="alechik.RData")

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "fixedprob", 
                            finalday = dia_relatorio); save(ale.zika, file="alezika.RData")
print(Sys.time())

data_relatorio <- max(ale.den[[1]]$data$SE, ale.chik[[1]]$data$SE, ale.zika[[1]]$data$SE)


## boletim dengue estadual
if(write_report) {
  flog.info("writing boletim estadual...", name = alog)
  bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
                                    alert=ale.den, shape=shape, varid=shapeID,varcli = "umid_max",
                                    dir=out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
  write_alerta(tabela_historico(ale.chik))
  write_alerta(tabela_historico(ale.zika))
  
}
  
# calcula alerta Fortaleza ----------------------
CE.F.out = "AlertaDengueAnalise/report/CE/Municipios/Fortaleza" 
flog.info("alerta dengue Fortaleza executing...", name = alog)

ale.F.den <- pipe_infodengue(2304400, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.F.chik <- pipe_infodengue(2304400, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.F.zika <- pipe_infodengue(2304400, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)

# Boletim Arbo ----------------------------------
if(write_report) {
  flog.info("writing boletim Arbo Fortaleza...", name = alog)
  bolFort <- configRelatorioMunicipal(alert = ale.F.den, alechik = ale.F.chik, alezika = ale.F.zika, tipo = "simples", 
                                    varcli = "umid_max", estado = estado, siglaUF = sig, data = data_relatorio, 
                                    dir.out = CE.F.out, geraPDF = TRUE)

publicarAlerta(ale = ale.F.den, pdf = bolFort, dir = "Relatorio/CE/Municipios/Fortaleza")
write_alerta(tabela_historico(ale.F.chik))
write_alerta(tabela_historico(ale.F.zika))
print(Sys.time())
#if (!bolFort %in% ls(dirbol)) futile.logger::flog.error("pdf boletin not saved")
}

# salvando objetos -------------------------
Rfile = paste0("alertasRData/aleCE",data_relatorio,".RData")
flog.info("saving ...", Rfile, capture = TRUE, name = alog)
save(ale.den, ale.chik, ale.zika, ale.F.den, ale.F.chik, ale.F.zika, file = Rfile)

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


