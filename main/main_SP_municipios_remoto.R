#====================================================
## Alertas municipais do Estado de São Paulo
#====================================================
# cidades: SJ Rio Preto (3549805), Bauru (3506003), Sorocaba (3552205)


# SJRio Preto: dengue e chik
# Sorocaba: dengue e chik 
# Bauru: dengue

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC  

# Cabeçalho ------------------------------
#setwd("~/")
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/pipeline")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)
# parametros especificos -----------------
estado = "São Paulo"
uf = "SP"

data_relatorio = 202207
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# ++++++++++++++++++++++++
# criar diretório para salvar o alerta:----
# ++++++++++++++++++++++++
if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas'))){dir.create(paste0('AlertaDengueAnalise/main/alertas'))}

if(!dir.exists(paste0('AlertaDengueAnalise/main/alertas/municipal'))){dir.create(paste0('AlertaDengueAnalise/main/alertas/municipal'))}


# cidade -------------------------------
geo <- 3552205
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
#AlertTools::lastDBdate("sinan", cid10 = "A90", cities = geo)


nomeRData <- paste0("ale-SP-",geo,"-",data_relatorio,".RData")

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, dataini = "sinpri", 
                           narule = "arima", completetail = 0)

save(ale.den, file = paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,'/municipal/',nomeRData))

if (geo %in% c(3549805, 3552205)) {
  ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "bayesian", 
                              finalday = dia_relatorio, narule = "arima",
                              dataini = "sinpri", completetail = 0)
  save(ale.den, ale.chik, file = paste0('AlertaDengueAnalise/main/alertas/',data_relatorio,'/municipal/',nomeRData))
  }

# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 10)
restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)

summary(restab.den)
summary(restab.chik)

write_alerta(restab.den)
write_alerta(restab.chik, writetofile = TRUE)

# salvando objetos -------------------------
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# ----- Fechando o banco de dados
dbDisconnect(con)


