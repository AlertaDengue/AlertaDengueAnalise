# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
# 3 arboviroses


# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R")  #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)
# parametros especificos -----------------
estado = "Maranhão"
sig = "MA"

# data do relatorio:---------------------
data_relatorio = 202053
#lastDBdate("tweet", 2111300)
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
#pars <- read.parameters(cidades)
nomeRData <- paste0("alertasRData/aleMA-",data_relatorio,".RData")

# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian", 
                            finalday = dia_relatorio,narule = "arima", 
                           completetail = 0) 
save(ale.den, file = nomeRData)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", 
                             finalday = dia_relatorio,narule = "arima", 
                            completetail = 0)
save(ale.den, ale.chik, file = nomeRData)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", 
                            finalday = dia_relatorio,narule = "arima", 
                            completetail = 0)
save(ale.den, ale.chik, ale.zika, file = nomeRData)

# escrevendo na tabela historico_alerta
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
write_alerta(restab.den)

restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
write_alerta(restab.chik)

restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
write_alerta(restab.zika)

# salvando alerta RData no servidor ----
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))
message("done")


# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em Setembro de 2020
# optou-se por apresentar analise por regional ampliada de saude: Norte, Sul e Leste
# poucas estacoes meteorologicas validas no Norte e Leste, suas por regional ampliada de saude
# Aw em todos (umid apenas)



