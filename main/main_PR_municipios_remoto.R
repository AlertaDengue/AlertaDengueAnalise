#====================================================
## Alertas municipais do Estado do Parana
#====================================================
# cidades: Foz Iguacu (4108304), Londrina (4113700), Maringá (4115200), 
# Paranagua (4118204)

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
estado = "Paraná"
uf = "PR"
#shape="AlertaDengueAnalise/report/SP/shape/35MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 
# onde salvar boletim
#out = "AlertaDengueAnalise/report/PR/Municipios"
#dir_rel = "Relatorio/SP/Municipios"

data_relatorio = 202051
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# cidade -------------------------------
geo <- 4108304
#geo <- as.numeric(mn)  # from infodengue.R
# checking the last date
AlertTools::lastDBdate("sinan", cid10 = "A90", cities = geo)

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "bayesian", 
                           finalday = dia_relatorio, narule = "arima", 
                           completetail = 0)

nome = paste0("alertasRData/alePR-",geo,"-",data_relatorio,".RData")
save(ale.den, file = nome)

# escrevendo os dados no banco
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
write_alerta(restab.den)

load(paste0("../",nome))
ale.den.mun <- ale.den
     
# Puxar o objeto do estado para inserir
system("ssh infodengue@info.dengue.mat.br 'cd alertasRData && ls'")
system("scp infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/alePR*.RData .")

load("alePR202051.RData")
ale.den[as.character(geo)] <- ale.den.mun[1]
save(ale.den, file = "alePR202051.RData")
system("scp alePR202051.RData infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")


# ----- Fechando o banco de dados
dbDisconnect(con)


