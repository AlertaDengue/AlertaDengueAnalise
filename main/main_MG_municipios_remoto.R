#====================================================
## Alertas municipais do Estado de Minas Gerais
#====================================================
# cidades: Belo Horizonte (3106200), Uberaba (3170107), 
# Uberlandia(3170206), Governador Valadares (3127701),
# Paracatu (3147006)


# so dengue 

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC  

# Cabeçalho ------------------------------
#setwd("~/")
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# parametros especificos -----------------
estado = "Minas Gerais"
uf = "MG"
#shape="AlertaDengueAnalise/report/SP/shape/35MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 
# onde salvar boletim
#out = "AlertaDengueAnalise/report/PR/Municipios"
#dir_rel = "Relatorio/SP/Municipios"

data_relatorio = 202051
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# cidade -------------------------------
#cidades <- getCidades(uf = estado)#[,"municipio_geocodigo"]

geos <- c(3106200, 3170107, 3170206, 3127701, 3147006)
#geo <- 4108304
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
AlertTools::lastDBdate("sinan", cid10 = "A92.0", cities = geos[4])

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)


ale.den <- pipe_infodengue(geos, cid10 = "A90", nowcasting = "bayesian", 
                             finalday = dia_relatorio, narule = "arima", 
                             completetail = 0)

ale.chik <- pipe_infodengue(geos[1:4], cid10 = "A92.0", nowcasting = "bayesian", 
                             finalday = dia_relatorio, narule = "arima", 
                             completetail = 0)

#ale.zika <- pipe_infodengue(geos, cid10 = "A92.8", nowcasting = "bayesian", 
#                             finalday = dia_relatorio, narule = "arima", 
#                             completetail = 0)
  
nome = paste0("alertasRData/aleMG-mns-",data_relatorio,".RData")

save(ale.den, ale.chik, file = nome)

# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
#restab.zika <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
write_alerta(restab.den)
write_alerta(restab.chik)
#write_alerta(restab.zika)

load(paste0("../",nome))
ale.den.mun <- ale.den
ale.chik.mun <- ale.chik     
# Puxar o objeto do estado para inserir
system("ssh infodengue@info.dengue.mat.br 'cd alertasRData && ls'")
system("scp infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/aleMG*.RData .")

load("aleMG202051.RData")
for (i in 1:5) ale.den[as.character(geos[1])] <- ale.den.mun[as.character(geos[1])]
for (i in 1:4) ale.chik[as.character(geos[1])] <- ale.chik.mun[as.character(geos[1])]
save(ale.den, ale.chik, file = "aleMG202051.RData")
system("scp aleMG202051.RData infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")


# ----- Fechando o banco de dados
dbDisconnect(con)


