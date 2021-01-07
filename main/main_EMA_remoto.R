# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
# 3 arboviroses


# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)
# parametros especificos -----------------
estado = "Maranhão"
sig = "MA"
#shape="AlertaDengueAnalise/report/MA/shape/21MUE250GC_SIR.shp"
#shapeID="CD_GEOCMU" 
# onde salvar boletim
#out = "AlertaDengueAnalise/report/MA"
#dir_rel = "Relatorio/MA/Estado"


# data do relatorio:---------------------
data_relatorio = 202040
#lastDBdate("tweet", 2111300)
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
#pars <- read.parameters(cidades)


# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", 
                            finalday = dia_relatorio,narule = "arima", 
                           completetail = 0) 

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "none", 
                             finalday = dia_relatorio,narule = "arima", 
                            completetail = 0)

ale.zika <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "none", 
                            finalday = dia_relatorio,narule = "arima", 
                            completetail = 0)

# ----------------------------
message("rodar alerta de São Luis:")

geoSaoLuis <- 2111300   # Sao Luis
ale.den.2111300 <- pipe_infodengue(geoSaoLuis, cid10 = "A90", nowcasting = "bayesian", finalday = dia_relatorio, completetail = 0)
ale.chik.2111300 <- pipe_infodengue(geoSaoLuis, cid10 = "A92.0", nowcasting = "bayesian", finalday = dia_relatorio, completetail = 0)
ale.zika.2111300 <- pipe_infodengue(geoSaoLuis, cid10 = "A92.8", nowcasting = "bayesian", finalday = dia_relatorio, completetail = 0)


save(ale.den, ale.chik, ale.zika, file = paste0("aleMA-",data_relatorio,".RData"))


message("alertas criados, agora atualizar tabela historico alerta:")
message("escrevendo alerta dengue no banco de dados...")
restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
write_alerta(restab.den)

message("escrevendo alerta chik no banco de dados...")
restab.den <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
write_alerta(restab.chik)

message("escrevendo alerta zika no banco de dados...")
restab.den <- tabela_historico(ale.zika, iniSE = data_relatorio - 100)
write_alerta(restab.zika)

message("done")


# Boletim Arbo ----------------------------------
if(write_report) {
  flog.info("writing boletim Arbo Sao Luis...", name = alog)
  bolcap <- configRelatorioMunicipal(alert = ale.SL.den, alechik = ale.SL.chik, alezika = ale.SL.zika, tipo = "simples", 
                                      varcli = "umid_max", estado = estado, siglaUF = sig, data = new_data_relatorio, 
                                      dir.out = SL.out, geraPDF = TRUE)
  
  publicarAlerta(ale = ale.SL.den, pdf = bolcap, dir = "Relatorio/MA/Municipios/SaoLuis")
}

# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em Setembro de 2020
# optou-se por apresentar analise por regional ampliada de saude: Norte, Sul e Leste
# poucas estacoes meteorologicas validas no Norte e Leste, suas por regional ampliada de saude
# Aw em todos (umid apenas)



