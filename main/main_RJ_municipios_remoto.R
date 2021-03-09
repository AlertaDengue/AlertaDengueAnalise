# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
# 2 arboviroses                                                                                                                                                                                                                                                                                                                                                                                                                        ''## Alertas municipais do Estado do Rio de Janeiro


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
data_relatorio = 202108
#lastDBdate("sinan", 3304557) # ultimo caso registrado
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

nomeRData <- paste0("alertasRData/aleRio-",data_relatorio,".RData")

### Se Boletim da cidade do Rio de Janeiro por APS ------------------------

ale.den <- pipe_infodengue_intra(city = 3304557, datarelatorio = data_relatorio, iniSE = 201001,
                                 cid10 = "A90", dataini = "sinpri", delaymethod = "bayesian")
ale.chik <- pipe_infodengue_intra(city = 3304557, datarelatorio = data_relatorio, iniSE = 201001, 
                      cid10 = "A920", dataini = "sinpri", delaymethod = "bayesian")
  
save(ale.den, ale.chik, file = nomeRData)

# salvando alerta RData no servidor  ----
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# criando tabela historico_alerta
restab.den <- tabela_historico_intra(ale.den, iniSE = data_relatorio - 100)
summary(restab.den)

restab.chik <- tabela_historico_intra(ale.chik, iniSE = data_relatorio - 100)
summary(restab.chik)

write_alertaRio(restab.den)
write_alertaRio(restab.chik)


# Fechando o banco de dados ------------------------------
dbDisconnect(con)


