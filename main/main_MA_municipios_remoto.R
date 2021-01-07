# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================
# municipios com mais de 100.000 pessoas

#geocodigo                nome populacao       uf
#1   2112209               Timon    166295 Maranhão
#2   2100055          Açailândia    110543 Maranhão
#3   2101202             Bacabal    103020 Maranhão
#4   2103000              Caxias    161926 Maranhão
#5   2103307                Codó    120548 Maranhão
#6   2105302          Imperatriz    253873 Maranhão
#7   2107506      Paço do Lumiar    119915 Maranhão
#8   2111201 São José de Ribamar    176008 Maranhão
#9   2111300            São Luís   1082935 Maranhão

# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
#  arboviroses: dengue e chik (zika tem poucos casos)
rm(list = ls()) # apagar a memoria

# Cabeçalho ------------------------------
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")
source("AlertaDengueAnalise/config/config_global_2020.R") #configuracao 
#con <- DenguedbConnect(pass = pw)  
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)
# parametros especificos -----------------
estado = "Maranhão"
sig = "MA"

# data do relatorio:---------------------
data_relatorio = 202051
#lastDBdate("tweet", 2111300)
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades --------------------------------
geos <- c(2111300, 2111201, 2107506, 2105302, 2103307, 2103000, 
          2101202, 2100055, 2112209)

# Calcula alertas municipais ------------------ 

ale.den <- pipe_infodengue(geos, cid10 = "A90", nowcasting = "bayesian",
                             finalday = dia_relatorio, narule = "arima", 
                             completetail = 0)
  
ale.chik <- pipe_infodengue(geos, cid10 = "A92.0", nowcasting = "bayesian", 
                             finalday = dia_relatorio, narule = "arima", 
                             completetail = 0)

ale.zik <- pipe_infodengue(geos, cid10 = "A92.8", nowcasting = "bayesian", 
                           finalday = dia_relatorio, narule = "arima", 
                           completetail = 0)
 
save(ale.den, ale.chik, ale.zik, file = paste0("alertasRData/aleMA-mn",data_relatorio,".RData"))
  
  print(Sys.time()-tt)



message("escrevendo alerta dengue no banco de dados...")

  message(paste("escrevendo alerta ", i, " de", ngeos))
  restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)
  write_alerta(restab.den)
  
  restab.chik <- tabela_historico(ale.chik, iniSE = data_relatorio - 100)
  write_alerta(restab.chik)
  
  #restab.zik <- tabela_historico(ale.zik, iniSE = data_relatorio - 100)
  #write_alerta(restab.zik)
  print(Sys.time()-tt)

message("done")

# envio
ale.den.mun <- ale.den
ale.chik.mun <- ale.chik     
# Puxar o objeto do estado para inserir
system("ssh infodengue@info.dengue.mat.br 'cd alertasRData && ls'")
system("scp infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/aleMA*.RData .")

load("aleMA202051.RData")
for (i in 1:5) ale.den[as.character(geos[1])] <- ale.den.mun[as.character(geos[1])]
for (i in 1:4) ale.chik[as.character(geos[1])] <- ale.chik.mun[as.character(geos[1])]
save(ale.den, ale.chik, file = "aleMA202051.RData")
system("scp aleMA202051.RData infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/")


# ----- Fechando o banco de dados -----------
dbDisconnect(con)


########### Memoria da analise

#Iniciado em Setembro de 2020
# optou-se por apresentar analise por regional ampliada de saude: Norte, Sul e Leste
# poucas estacoes meteorologicas validas no Norte e Leste, suas por regional ampliada de saude
# Aw em todos (umid apenas)



