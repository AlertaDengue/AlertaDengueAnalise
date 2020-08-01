#====================================================
## Alertas municipais do Estado do Rio Grande do Sul
#====================================================
# cidades: Porto Alegre (4314902)

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Rio Grande do Sul"
uf = "RS"
#shape="AlertaDengueAnalise/report/RS/shape/35MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 

# onde salvar boletim
out = "AlertaDengueAnalise/report/RS/Municipios"
dir_rel = "Relatorio/RS/Municipios"


# data do relatorio:---------------------
#data_relatorio = 202031
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# cidade -------------------------------
#geo <- 4314902
geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
AlertTools::lastDBdate("sinan", cities = geo)

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "none", 
                           finalday = dia_relatorio, completetail = 0,narule = "arima")                          

# habilitar se quiser salvar os objetos para analisar fora do pipeline
#pars <- read.parameters(cities = geo,cid10 = "A90")
#save(ale.den, pars, file = "dadosPOA.RData")

# Boletim ----------------------------------

source("AlertaDengueAnalise/config/gera_boletim_municipio.R")

# nome do diretorio para salvar o boletim
nome <- iconv(gsub(" ","",ale.den[[1]]$data$nome[1]), to = "ASCII//TRANSLIT")
out = paste0("AlertaDengueAnalise/report/RS/Municipios/",nome) 
  
bol <- gera_boletim_municipio(ale.den, uf = uf, dir.out = out)  

if(write_report){
  dir_rel <- paste0("Relatorio/RS/Municipios/",nomesemacento) 
  dir.create(file.path(dir_rel), showWarnings = FALSE) # check if directory exists
  publicar_alerta(ale = ale.den, pdf = bol, dir = dir_rel)
  
}  


save(ale.den, file = paste0("alertasRData/aleRS-mn",data_relatorio,".RData"))

# ----- Fechando o banco de dados
dbDisconnect(con)


