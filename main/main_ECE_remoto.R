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


# data do relatorio:---------------------
data_relatorio = 202108
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

nomeRData <- paste0("alertasRData/aleCE-",data_relatorio,".RData")

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
print(Sys.time())

# Calcula alerta estadual ------------------ 
t1 <- Sys.time()
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, narule = "arima", 
                           iniSE = 201001, dataini = "sinpri", completetail = 0)
save(ale.den, file = nomeRData)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "bayesian", 
                            finalday = dia_relatorio, narule = "arima", 
                            iniSE = 201001, dataini = "sinpri", completetail = 0)
save(ale.den, ale.chik, file = nomeRData)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "bayesian",
                            finalday = dia_relatorio, narule = "arima", 
                            iniSE = 201001, dataini = "sinpri", completetail = 0)
save(ale.den, ale.chik, ale.zika, file = nomeRData)
t2 <- Sys.time()-t1

# inspecionando a capital
tail(ale.den$'2304400'$data)
tail(ale.den$'2304400'$indices$level) # nivel

# criando tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
summary(restab.den)
restab.den$casos_est_max[restab.den$casos_est_max > 10000] <- NA

restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
summary(restab.chik[restab.chik$SE == data_relatorio,])

restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
summary(restab.zika[restab.zika$SE == data_relatorio,])

# escrevendo
write_alerta(restab.den)
write_alerta(restab.chik)
write_alerta(restab.zika)

# salvando alerta RData no servidor  ----
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


