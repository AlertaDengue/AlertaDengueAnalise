# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Ceará
# =============================================================================
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC

# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# parametros especificos -----------------
estado = "Ceará"
sig = "CE"

nomeRData <- paste0("alertasRData/aleCE-",data_relatorio,".RData")
  
# data do relatorio:---------------------
data_relatorio = 202053
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
print(Sys.time())

# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, narule = "arima", 
                           completetail = 0)
save(ale.den, file = nomeRData)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", 
                            finalday = dia_relatorio, narule = "arima", 
                            completetail = 0)
save(ale.den, ale.chik, file = nomeRData)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "bayesian",
                            finalday = dia_relatorio, narule = "arima", 
                            completetail = 0)
save(ale.den, ale.chik, ale.zika, file = nomeRData)


print(Sys.time())

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
write_alerta(tabela_historico(restab.den))

restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
write_alerta(tabela_historico(restab.chik))

restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
write_alerta(tabela_historico(restab.zik))

# salvando alerta RData no servidor  ----
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


