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
data_relatorio = 202105
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

nomeRData <- paste0("alertasRData/aleMG-",data_relatorio,".RData")

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# Calcula alerta estadual ------------------ 

t1 <- Sys.time()
ale.den1_300<- pipe_infodengue(cidades[1:300], cid10 = "A90", nowcasting = "bayesian", 
                                iniSE = 201001, finalday = dia_relatorio, 
                                narule = "arima", dataini = "sinpri", completetail = 0) 
save(ale.den1_300, file = nomeRData)
ale.den301_600<- pipe_infodengue(cidades[301:600], cid10 = "A90", nowcasting = "bayesian", 
                               iniSE = 201001, finalday = dia_relatorio, 
                               narule = "arima", dataini = "sinpri", completetail = 0) 
save(ale.den1_300, ale.den301_600, file = nomeRData)
ale.den601_853<- pipe_infodengue(cidades[601:853], cid10 = "A90", nowcasting = "bayesian", 
                                 iniSE = 201001, finalday = dia_relatorio, 
                                 narule = "arima", dataini = "sinpri", completetail = 0) 
save(ale.den1_300, ale.den301_600, ale.den601_853, file = nomeRData)
ale.den <- c(ale.den1_300, ale.den301_600, ale.den601_853)
save(ale.den, file = nomeRData)
t2 <- Sys.time() - t1

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "bayesian", 
                            iniSE = 201001, finalday = dia_relatorio, 
                            narule = "arima", dataini = "sinpri", completetail = 0)
save(ale.den, ale.chik, file = nomeRData)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "bayesian", 
                            iniSE = 201001, dataini = "sinpri", 
                            finalday = dia_relatorio, narule = "arima", completetail = 0)
save(ale.den, ale.chik, ale.zika, file = nomeRData)
t3 <- Sys.time() - t1

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
save(restab.den, restab.chik, restab.zika, file = "restabMG.RData")

summary(restab.den[restab.den$SE == data_relatorio, ])  # verificar se tem algo estranho
summary(restab.chik[restab.chik$SE == data_relatorio, ] )
summary(restab.zika[restab.zika$SE == data_relatorio, ])

#load("restabMG.RData")
write_alerta(restab.den)
write_alerta(restab.chik)
write_alerta(restab.zika)


# salvando alerta RData no servidor ----
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))


# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em agosto de 2020
#Analise feita por macroregiao. Poucas estacoes meteorologicas



