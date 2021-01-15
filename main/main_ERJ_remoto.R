# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R")  #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# parametros especificos -----------------
estado = "Rio de Janeiro"
sig = "RJ"

# data do relatorio:---------------------
data_relatorio = 202102
#lastDBdate("historico_alerta", 2111300)
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
#pars <- read.parameters(cidades)
nomeRData <- paste0("alertasRData/aleRJ-",data_relatorio,".RData")

# Calcula alerta ---------------------------- 
t1 <- Sys.time()
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian",
                           iniSE = 201001, finalday = dia_relatorio, 
                           narule = "arima", completetail = 0) 
save(ale.den, file = nomeRData)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "bayesian",
                           iniSE = 201001, finalday = dia_relatorio, 
                           narule = "arima", completetail = 0)

save(ale.den, ale.chik, file = nomeRData)
t2 <- Sys.time()-t1

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
save(restab.den, restab.chik, file = "restab.RData")

summary(restab.den[restab.den$SE == data_relatorio,])
summary(restab.chik[restab.chik$SE == data_relatorio,])

write_alerta(restab.den)
write_alerta(restab.chik)

# salvando alerta RData no servidor ----
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))
message("done")

print(Sys.time())
# ----- Fechando o banco de dados
dbDisconnect(con)




