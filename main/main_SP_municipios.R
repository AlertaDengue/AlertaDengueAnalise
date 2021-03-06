#====================================================
## Alertas municipais do Estado de São Paulo
#====================================================
# cidades: SJ Rio Preto (3549805), Bauru (3506003), Sorocaba (3552205)

# SJRio Preto: dengue e chik
# Sorocaba: dengue e chik 
# Bauru: dengue

# Cabeçalho ------------------------------
#setwd("~/")
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = "flavivirus")
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
#AlertTools::lastDBdate("sinan", cid10 = "A92.0", cities = geo)

nome_arq <- paste0("aleSP-",geo,"-",data_relatorio,".RData")

# pipeline : dengue ------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, narule = "arima", 
                           completetail = 0)

# saving
save(ale.den, file = paste0("alertasRData/",nome_arq)) # local
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio-100) 
write_alerta(restab.den)

if (geo %in% c(3549805, 3552205)) {
  ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "bayesian", 
                              finalday = dia_relatorio, narule = "arima", 
                              completetail = 0)
  #saving
  save(ale.den, ale.chik, file = paste0("alertasRData/",nome_arq))
  restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio-100)
  write_alerta(restab.chik)
}

#sending to server
comando <- paste0("scp alertasRData/",nome_arq ," infodengue@info.dengue.mat.br:/home/infodengue/alertasRData")
system(comando)

# ----- Fechando o banco de dados
dbDisconnect(con)


