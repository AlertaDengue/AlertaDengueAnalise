# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
pw = "aldengue"
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Maranhão"
sig = "MA"
shape="AlertaDengueAnalise/report/MA/shape/21MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/MA"
dir_rel = "Relatorio/MA/Estado"

#divisao territorial - relatorio 
divUF = "macroreg"


# data do relatorio:---------------------
data_relatorio = 202030
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
pars <- read.parameters(cidades)
print(Sys.time())

# Calcula alerta estadual ------------------ 
#ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", 
#                            finalday = dia_relatorio) 
#save(ale.den, pars, cidades, file="infodengueMA202009.RData")
 
#ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", 
#                             finalday = dia_relatorio); save(ale.chik, file="alechik.RData")

#ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", 
#                            finalday = dia_relatorio); save(ale.zika, file="alezika.RData")

  print(Sys.time())

#new_data_relatorio <- max(ale.den[[1]]$data$SE, ale.chik[[1]]$data$SE, ale.zika[[1]]$data$SE)
#load("aledenMA.RData")
#save(ale.den, ale.chik, ale.zika, file = "aleMA.RData")
load("aleMA.RData")

## boletim dengue estadual
#if(write_report){
#   flog.info("writing boletim estadual...", name = alog)
#   new_data_relatorio <- 202009 # max(ale.den[[1]]$data$SE)
#   print(paste("Data real do relatorio:", new_data_relatorio))
#   bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
#                                     alert=ale.den, shape=shape, varid=shapeID,varcli = "umid_max",
#                                     dir=out, datasource=con, geraPDF=TRUE)
 
#   publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
#   write_alerta(tabela_historico(ale.den))
   write_alerta(tabela_historico(ale.chik))
   write_alerta(tabela_historico(ale.zika))
#}
  
# calcula alerta São Luís ----------------------
#out = "AlertaDengueAnalise/report/MA/Municipios/SaoLuis" 
#flog.info("alerta dengue MA executing...", name = alog)

#aledenSL <- pipe_infodengue(, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio, userinput = TRUE); save(ale.F.den,file = "aleFden.RData")

# Boletim Dengue ----------------------------------
#if(write_report) {
#  flog.info("writing boletim dengue BH...", name = alog)
#  bolFort <- configRelatorioMunicipal(alert = ale.F.den, tipo = "simples", 
#                                    varcli = "umid_max", estado = estado, siglaUF = sig, data = data_relatorio, 
#                                    dir.out = CE.F.out, geraPDF = TRUE)

#publicarAlerta(ale = ale.F.den, pdf = bolFort, dir = "Relatorio/MG/Municipios/Dengue")
print(Sys.time())
#if (!bolFort %in% ls(dirbol)) futile.logger::flog.error("pdf boletin not saved")
#}

# salvando objetos -------------------------
#Rfile = paste0("alertasRData/aleCE",data_relatorio,".RData")
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
#save(ale.den, ale.chik, ale.zika, ale.F.den, ale.F.chik, ale.F.zika, file = Rfile)

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em Setembro de 2020
# optou-se por apresentar analise por regional ampliada de saude: Norte, Sul e Leste
# poucas estacoes meteorologicas validas no Norte e Leste, suas por regional ampliada de saude
# Aw em todos (umid apenas)



