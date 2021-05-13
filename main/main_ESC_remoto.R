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
estado = "Santa Catarina"
sig = "SC"


# data do relatorio:---------------------
data_relatorio = 202117
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

nomeRData <- paste0("alertasRData/aleSC-",data_relatorio,".RData")

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
print(Sys.time())

# Calcula alerta estadual ------------------ 10 minutos
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

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)

# verificar se tem algum valor estranho 
summary(restab.den[restab.den$SE == data_relatorio,])
summary(restab.chik[restab.chik$SE == data_relatorio,])
summary(restab.zika[restab.zika$SE == data_relatorio,])

# salvando alerta RData no servidor  ----
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# escrever no banco de dados
write_alerta(restab.den)
write_alerta(restab.chik)
write_alerta(restab.zika)

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


