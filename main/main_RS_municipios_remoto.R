#====================================================
## Alertas municipais do Estado do Rio Grande do Sul
#====================================================
# cidades: Porto Alegre (4314902)

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
estado = "Rio Grande do Sul"
uf = "RS"

# onde salvar boletim
out = "AlertaDengueAnalise/report/RS/Municipios"
dir_rel = "Relatorio/RS/Municipios"


# data do relatorio:---------------------
data_relatorio = 202148
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# ++++++++++++++++++++++++
# criar diretório para salvar o alerta:----
# ++++++++++++++++++++++++
if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas'))){dir.create(paste0('AlertaDengueAnalise/main/alertas'))}

if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas/municipal'))){dir.create(paste0('AlertaDengueAnalise/main/alertas/municipal'))}


# cidade -------------------------------
geo <- 4314902
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
#AlertTools::lastDBdate("sinan", cities = geo)

nomeRData <- paste0("ale-RS-",geo,"-",data_relatorio,".RData")

# pipeline -------------------------------
#flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, dataini = "sinpri", 
                           completetail = 0, narule = "arima")                          

save(ale.den, file = paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,'/municipal/',nomeRData))


# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
summary(restab.den[restab.den$SE == data_relatorio,])  # verificar se não tem numeros extremos de casos_est e casos_estmax

write_alerta(restab.den)


# mandando pro servidor
comando = paste("scp ",nomeRData,"infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")
system(comando)

# ----- Fechando o banco de dados
dbDisconnect(con)


