# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado de Minas Gerais 
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
source("AlertaDengueAnalise/config/gera_boletim_estado.R")

con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Minas Gerais"
sig = "MG"
shape="AlertaDengueAnalise/report/MG/shape/31MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/MG"
dir_rel = "Relatorio/MG/Estado"


# data do relatorio:---------------------
#data_relatorio = 201843
ini_relatorio = data_relatorio - 200

#lastDBdate("sinan", 3106200, cid10 = "A92.0") #chik
#lastDBdate("sinan", 3106200, cid10 = "A90") #dengue
#lastDBdate("sinan", 3106200, cid10 = "A92.8") #zika

dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
pars <- read.parameters(cidades)
      
# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", iniSE = 201001,
                           finalday = dia_relatorio, narule = "arima", completetail = 0) 

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", iniSE = 201001,
                             finalday = dia_relatorio, narule = "arima", completetail = 0)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", iniSE = 201001,
                            finalday = dia_relatorio, narule = "arima", completetail = 0)

#new_data_relatorio <- max(ale.den[[1]]$data$SE, ale.chik[[1]]$data$SE, ale.zika[[1]]$data$SE)
load("aleMG.RData")
#save(ale.den, ale.chik, ale.zika, file = "aleMG.RData")


## boletim dengue estadual
if(write_report){
   flog.info("writing boletim estadual...", name = alog)
  #new_data_relatorio <- max(ale.den[[1]]$data$SE)
  #print(paste("Data real do relatorio:", new_data_relatorio))
   #bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
  #                                   alert=ale.den, shape=shape, varid=shapeID,varcli = "temp_min",
  #                                   dir=out, datasource=con, geraPDF=TRUE)

 #  publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
   restab <- tabela_historico(ale.den, iniSE = 201001)
   write_alerta(restab)
   
   restab.chik <- tabela_historico(ale.chik, iniSE = 201001)
   write_alerta(restab.chik)
   
   restab.zika <- tabela_historico(ale.zika, iniSE = 201001)
   write_alerta(restab.zika)
   
}


# calcula alerta para mun especificoH ----------------------
#SL.out = "AlertaDengueAnalise/report/MG/Municipios/BeloHorizonte"
#flog.info("alerta dengue Belo Horizonte executing...", name = alog)

#ale.SL.den <- pipe_infodengue(3106200, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio, completetail = 0)
#ale.SL.chik <- pipe_infodengue(3106200, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio, completetail = 0)
#ale.SL.chik <- pipe_infodengue(c(317026), cid10 = "A92.0", nowcasting = "none",
#                               finalday = dia_relatorio, completetail = 0)
#ale.SL.zika <- pipe_infodengue(3170206, cid10 = "A92.8", nowcasting = "none",
#                               finalday = dia_relatorio, completetail = 0)

# Boletim Arbo ----------------------------------
#if(write_report) {
#  flog.info("writing boletim Arbo BH...", name = alog)
#  bolcap <- configRelatorioMunicipal(alert = ale.SL.den, alechik = ale.SL.chik, tipo = "simples",
#                                      varcli = "umid_max", estado = estado, siglaUF = sig, data = new_data_relatorio,
#                                      dir.out = SL.out, geraPDF = TRUE)

#  publicarAlerta(ale = ale.SL.den, pdf = bolcap, dir = "Relatorio/MG/Municipios/BeloHorizonte")
#}
#class(ale.SL.den[[1]])
#write_alerta(tabela_historico(ale.SL.den, iniSE = 201801))
#write_alerta(restab.den)

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em agosto de 2020
#Analise feita por macroregiao. Poucas estacoes meteorologicas



