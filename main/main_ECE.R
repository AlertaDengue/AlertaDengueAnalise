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
shape="AlertaDengueAnalise/report/CE/shape/23MUE250GC_SIR.sh"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/CE"
dir_rel = "Relatorio/CE/Estado"

# logging -------------------------------- 
#habilitar se quiser
if (logging == TRUE){
  aalog <- paste0("AlertaDengueAnalise/",alog)
  print(aalog)
}


# data do relatorio:---------------------
#data_relatorio = 201851
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "fixedprob", 
                           finalday = dia_relatorio)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "fixedprob", 
                            finalday = dia_relatorio)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "fixedprob", 
                            finalday = dia_relatorio)

## boletim dengue estadual
if(write_report) {
  flog.info("writing boletim estadual...", name = aalog)
  bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
                                    alert=ale.den, shape=shape, varid=shapeID,
                                    dir=out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale = ale.den, pdf = bol, dir = "Relatorio/CE/Estado")
  
  if (!bol %in% ls("Relatorio/CE/Estado")) futile.logger::flog.error("pdf boletin not saved")
  
} else {flog.warn("boletim estatual skipped by user", name = alog)}


# calcula alerta Fortaleza ----------------------
CE.F.out = "AlertaDengueAnalise/report/CE/Municipios/Fortaleza" 
flog.info("alerta dengue Fortaleza executing...", name = aalog)

ale.F.den <- pipe_infodengue(2304400, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.F.chik <- pipe_infodengue(2304400, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.F.zika <- pipe_infodengue(2304400, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)

# Boletim Arbo ----------------------------------
if(write_report) {
  flog.info("writing boletim Arbo Fortaleza...", name = aalog)
bolFort <- configRelatorioMunicipal(alert = ale.F.den, alechik = ale.F.chik, alezika = ale.F.zika, tipo = "simples", 
                                    varcli = "umid_max", estado = estado, siglaUF = sig, data = data_relatorio, 
                                    dir.out = CE.F.out, geraPDF = TRUE)

#publicarAlerta(ale = aleFort, pdf = bolFort, dir = "Relatorio/CE/Municipios/Fortaleza")
}

# salvando objetos -------------------------
Rfile = paste0("alertasRData/aleCE",data_relatorio,".RData")

flog.info("saving ...", Rfile, capture = TRUE, name = aalog)
save(ale.den, ale.chik, ale.zika, ale.F.den, ale.F.chik, ale.F.zika, file = Rfile)

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


