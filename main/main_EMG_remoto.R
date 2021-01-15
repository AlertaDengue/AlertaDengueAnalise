# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado de Minas Gerais 
# =============================================================================
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC

# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw) 

# parametros especificos -----------------
estado = "Minas Gerais"
sig = "MG"

# data do relatorio:---------------------
data_relatorio = 202102
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

nomeRData <- paste0("alertasRData/aleMG-",data_relatorio,".RData")

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# Calcula alerta estadual ------------------ 

t1 <- Sys.time()
ale.den1_200 <- pipe_infodengue(cidades[1:200], cid10 = "A90", nowcasting = "bayesian", iniSE = 201001,
                           finalday = dia_relatorio, narule = "arima", completetail = 0) 
save(ale.den1_200, file = nomeRData)

ale.den201_400 <- pipe_infodengue(cidades[201:400], cid10 = "A90", nowcasting = "bayesian", iniSE = 201001,
                                finalday = dia_relatorio, narule = "arima", completetail = 0) 
save(ale.den1_200, ale.den201_400, file = nomeRData)

ale.den401_600 <- pipe_infodengue(cidades[401:600], cid10 = "A90", nowcasting = "bayesian", iniSE = 201001,
                                  finalday = dia_relatorio, narule = "arima", completetail = 0) 
save(ale.den1_200, ale.den201_400, ale.den401_600, file = nomeRData)

ale.den601_853 <- pipe_infodengue(cidades[601:853], cid10 = "A90", nowcasting = "bayesian", iniSE = 201001,
                                  finalday = dia_relatorio, narule = "arima", completetail = 0) 

ale.den <- c(ale.den1_200, ale.den201_400, ale.den401_600, ale.den601_853)
save(ale.den , file = nomeRData)
t2 <- Sys.time() - t1

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "bayesian", iniSE = 201001,
                             finalday = dia_relatorio, narule = "arima", completetail = 0)

save(ale.den, ale.chik, file = nomeRData)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", iniSE = 201001,
                            finalday = dia_relatorio, narule = "arima", completetail = 0)
save(ale.den, ale.chik, ale.zika, file = nomeRData)

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
restab.den$casos_est_max[restab.den$casos_est_max > 1e4] <- NA
summary(restab.den[restab.den$SE == data_relatorio, ])  # verificar se tem algo estranho

restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
summary(restab.chik[restab.chik$SE == data_relatorio, ] )

restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
summary(restab.zika[restab.zika$SE == data_relatorio, ])

save(restab.den, restab.chik, restab.zika, file = "restab.RData")
load("restab.RData")
write_alerta(restab.den)
write_alerta(restab.chik[40001:46062,])
write_alerta(restab.zika)


# salvando alerta RData no servidor ----
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))


# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em agosto de 2020
#Analise feita por macroregiao. Poucas estacoes meteorologicas



