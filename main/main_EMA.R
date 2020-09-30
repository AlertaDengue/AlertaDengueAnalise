# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Maranhão"
sig = "MA"
shape="AlertaDengueAnalise/report/MA/shape/21MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/MA"
dir_rel = "Relatorio/MA/Estado"


# data do relatorio:---------------------
#data_relatorio = 202034
#lastDBdate("tweet", 2111300)
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
pars <- read.parameters(cidades)


# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", 
                            finalday = dia_relatorio,narule = "arima", completetail = 0) 

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", 
                             finalday = dia_relatorio)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", 
                            finalday = dia_relatorio)

#new_data_relatorio <- max(ale.den[[1]]$data$SE, ale.chik[[1]]$data$SE, ale.zika[[1]]$data$SE)
#load("aledenMA.RData")
save(ale.den, ale.chik, ale.zika, file = "aleMA.RData")


## boletim dengue estadual
if(write_report){
   flog.info("writing boletim estadual...", name = alog)
  new_data_relatorio <- max(ale.den[[1]]$data$SE)
  print(paste("Data real do relatorio:", new_data_relatorio))
   bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
                                     alert=ale.den, shape=shape, varid=shapeID,varcli = "umid_max",
                                     dir=out, datasource=con, geraPDF=TRUE)
 
   publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
   write_alerta(tabela_historico(ale.den))
   write_alerta(tabela_historico(ale.chik))
   write_alerta(tabela_historico(ale.zika))
}
  

# calcula alerta Sao Luis ----------------------
SL.out = "AlertaDengueAnalise/report/MA/Municipios/SaoLuis" 
flog.info("alerta dengue Sao Luis executing...", name = alog)

ale.SL.den <- pipe_infodengue(2111300, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio, completetail = 0)
ale.SL.chik <- pipe_infodengue(2111300, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio, completetail = 0)
ale.SL.zika <- pipe_infodengue(2111300, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio, completetail = 0)

# Boletim Arbo ----------------------------------
if(write_report) {
  flog.info("writing boletim Arbo Sao Luis...", name = alog)
  bolcap <- configRelatorioMunicipal(alert = ale.SL.den, alechik = ale.SL.chik, alezika = ale.SL.zika, tipo = "simples", 
                                      varcli = "umid_max", estado = estado, siglaUF = sig, data = new_data_relatorio, 
                                      dir.out = SL.out, geraPDF = TRUE)
  
  publicarAlerta(ale = ale.SL.den, pdf = bolcap, dir = "Relatorio/MA/Municipios/SaoLuis")
}

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em Setembro de 2020
# optou-se por apresentar analise por regional ampliada de saude: Norte, Sul e Leste
# poucas estacoes meteorologicas validas no Norte e Leste, suas por regional ampliada de saude
# Aw em todos (umid apenas)



