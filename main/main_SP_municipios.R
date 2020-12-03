#====================================================
## Alertas municipais do Estado de São Paulo
#====================================================
# cidades: SJ Rio Preto (3549805), Bauru (3506003), Sorocaba (3552205)
<<<<<<< HEAD

# SJRio Preto: dengue e chik
# Sorocaba: dengue e chik 
# Bauru: dengue
=======
>>>>>>> 0655fecc1762ac9ac60847695a1548f72e6aa828

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "São Paulo"
uf = "SP"
#shape="AlertaDengueAnalise/report/SP/shape/35MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/SP/Municipios"
dir_rel = "Relatorio/SP/Municipios"


#data_relatorio = 202043
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# cidade -------------------------------
#geo <- 3552205
geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
AlertTools::lastDBdate("sinan", cid10 = "A92.0", cities = geo)

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", 
                           finalday = dia_relatorio, narule = "arima", 
                           completetail = 0)

if (geo %in% c(3549805, 3552205)) {
  ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
  restab.chik <- tabela_historico(ale.chik, iniSE = 201001)
  write_alerta(restab.chik)
  }
#ale.zika <- pipe_infodengue(geo, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)

# Boletim ----------------------------------

source("AlertaDengueAnalise/config/gera_boletim_municipio.R")

# nome do diretorio para salvar o boletim
nome <- iconv(gsub(" ","", ale.den[[1]]$data$nome[1]), to = "ASCII//TRANSLIT")
out = paste0("AlertaDengueAnalise/report/SP/Municipios/",nome) 
  
bol <- gera_boletim_municipio(ale.den, uf = uf, dir.out = out)  

if(write_report) {  
  dir_rel <- paste0("Relatorio/SP/Municipios/",nome) 
  dir.create(file.path(dir_rel), showWarnings = FALSE) # check if directory exists
  publicar_alerta(ale = ale.den, pdf = bol, dir = dir_rel)
}

save(ale.den, file = paste0("alertasRData/aleSP-mn",data_relatorio,".RData"))

# ----- Fechando o banco de dados
dbDisconnect(con)


