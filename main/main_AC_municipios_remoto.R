#====================================================
## Alertas municipais do Estado do Acre
#====================================================
# cidades: Rio Branco (1200401)

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC  

# Cabeçalho ------------------------------
#setwd("~/")
setwd("~/infodengue/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# parametros especificos -----------------
estado = "Acre"
uf = "AC"

# onde salvar boletim
out = "AlertaDengueAnalise/report/AC/Municipios"
dir_rel = "Relatorio/AC/Municipios"


# data do relatorio:---------------------
data_relatorio = 202144
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# ++++++++++++++++++++++++
# criar diretório para salvar o alerta:----
# ++++++++++++++++++++++++
if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas'))){dir.create(paste0('AlertaDengueAnalise/main/alertas'))}

if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas/',data_relatorio))){dir.create(paste0('AlertaDengueAnalise/main/alertas/',data_relatorio))}

if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,"municipal"))){dir.create(paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,"municipal"))}


# cidade -------------------------------
geo <- 1200401
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
#AlertTools::lastDBdate("sinan", cities = geo)

nomeRData <- paste0("ale-AC-",geo,"-",data_relatorio,".RData")

# pipeline -------------------------------
#flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, dataini = "sinpri", 
                           completetail = 0, narule = "arima")                          

save(ale.den, file = paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,'/municipal/',nomeRData))

ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "bayesian", 
                            finalday = dia_relatorio, dataini = "sinpri", 
                            completetail = 0, narule = "arima")                          

save(ale.den,ale.chik, file = paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,'/municipal/',nomeRData))

# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
summary(restab.den[restab.den$SE == data_relatorio,])  # verificar se não tem numeros extremos de casos_est e casos_estmax

restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)

write_alerta(restab.den)
write_alerta(restab.chik)

# mandando pro servidor
comando = paste("scp ",nomeRData,"infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")
system(comando)

# ----- Fechando o banco de dados
dbDisconnect(con)


