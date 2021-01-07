#====================================================
## Alertas municipais do Estado do Rio Grande do Sul
#====================================================
# cidades: Porto Alegre (4314902)

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC  

# Cabeçalho ------------------------------
#setwd("~/")
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")

source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 

con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# parametros especificos -----------------
estado = "Rio Grande do Sul"
uf = "RS"
#shape="AlertaDengueAnalise/report/RS/shape/35MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 

# onde salvar boletim
out = "AlertaDengueAnalise/report/RS/Municipios"
dir_rel = "Relatorio/RS/Municipios"


# data do relatorio:---------------------
data_relatorio = 202050
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# cidade -------------------------------
geo <- 4314902
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
AlertTools::lastDBdate("sinan", cities = geo)

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, completetail = 0,
                           narule = "arima")                          

nome = paste0("alertasRData/aleRS-",geo,"-",data_relatorio,".RData")
save(ale.den, file = nome)


# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
write_alerta(restab.den)


# mandando pro servidor
system("ssh infodengue@info.dengue.mat.br 'cd alertasRData && ls'")
comando = paste0("scp ",nome," infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")
system(comando)

# ----- Fechando o banco de dados
dbDisconnect(con)


