######################################
# SQLite Infodengue local
######################################

library(DBI)
library(RPostgreSQL)


#----------------------------------------
# 1. Acessar o banco de dados do projeto
#----------------------------------------
## requer autorização ##
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC

conInfo <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

dbListTables(conInfo)
#---------------------------------------
# 2. Criar banco de dados local
#---------------------------------------

#mycon <- dbConnect(RSQLite::SQLite(), "mydengue.sqlite") # criar um novo
mycon <- dbConnect(RSQLite::SQLite(), 
                   "../../AlertaDengueAnalise/mydengue.sqlite") # abrir um existente
dbListTables(mycon)

###################################################
## baixar as tabelas necessarias para o pipeline
###################################################

# ++++++++++++++++++++++++++++++++++++++++++++++++
# Tabelas estáticas (nao precisa atualizar)
# ++++++++++++++++++++++++++++++++++++++++++++++++

# regionais de saude
reg <- dbReadTable(conInfo, c("Dengue_global","regional"))
# macrorregionais de saude
macreg <- dbReadTable(conInfo, c("Dengue_global","macroregional"))
# estados
comando <- "SELECT nome, regiao, uf, geocodigo FROM 
\"Dengue_global\".\"estado\""
estado <- dbGetQuery(conInfo, comando)
# municipios
comando <- "SELECT geocodigo, nome, uf, populacao, id_regional FROM 
\"Dengue_global\".\"Municipio\""
mun <- dbGetQuery(conInfo, comando)
# Bairros rio de janeiro
comando <- "SELECT * FROM \"Municipio\".\"Bairro\""
bai <- dbGetQuery(conInfo, comando)
# Localidades do rio de janeiro
comando <- "SELECT * FROM \"Municipio\".\"Localidade\""
loc <- dbGetQuery(conInfo, comando)



dbWriteTable(mycon, name = "regional", reg)
dbWriteTable(mycon, name = "macroregional", macreg)
dbWriteTable(mycon, name = "estado", estado)
dbWriteTable(mycon, name = "Municipio", mun)
dbWriteTable(mycon, name = "Bairro", bai)
dbWriteTable(mycon, name = "Localidade", loc)

# ++++++++++++++++++++++++++++++++++++++++++++++++
# Tabelas que precisam ser atualizadas sempre (aqui é o dump inicial)
# ++++++++++++++++++++++++++++++++++++++++++++++++

parameters <- dbReadTable(conInfo, c("Dengue_global","parameters"))
dbWriteTable(con, name = "parameters", parameters)

wu <- dbReadTable(conInfo, c("Municipio","Clima_wu"))
dbWriteTable(mycon, name = "wu", wu)
rm(wu)

tw <-  dbReadTable(conInfo, c("Municipio","Tweet"))
dbWriteTable(mycon, name = "Tweet", tw)
rm(tw)


comando2011 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita, se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif < 2012"
not2011 <-  dbGetQuery(conInfo, comando2011)
dbWriteTable(mycon, name = "Notificacao", not2011)
rm(not2011)

comando2012 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2012"
not2012 <-  dbGetQuery(conInfo, comando2012)
dbWriteTable(mycon, name = "Notificacao", not2012, append = TRUE)
rm(not2012)

comando2013 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2013"
not2013 <-  dbGetQuery(conInfo, comando2013)
dbWriteTable(mycon, name = "Notificacao", not2013, append = TRUE)
rm(not2013)

comando2014 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2014"
not2014 <-  dbGetQuery(conInfo, comando2014)
dbWriteTable(mycon, name = "Notificacao", not2014, append = TRUE)
rm(not2014)

comando2015 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2015"
not2015 <-  dbGetQuery(conInfo, comando2015)
dbWriteTable(mycon, name = "Notificacao", not2015, append = TRUE)
rm(not2015)

comando2016 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2016"
not2016 <-  dbGetQuery(conInfo, comando2016)
dbWriteTable(mycon, name = "Notificacao", not2016, append = TRUE)
rm(not2016)

comando2017 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2017"
not2017 <-  dbGetQuery(conInfo, comando2017)
dbWriteTable(mycon, name = "Notificacao", not2017, append = TRUE)
rm(not2017)

comando2018 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2018"
not2018 <-  dbGetQuery(conInfo, comando2018)
dbWriteTable(mycon, name = "Notificacao", not2018, append = TRUE)
rm(not2018)

comando2019 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2019"
not2019 <-  dbGetQuery(conInfo, comando2019)
dbWriteTable(mycon, name = "Notificacao", not2019, append = TRUE)
rm(not2019)

comando2020 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2020"
not2020 <-  dbGetQuery(conInfo, comando2020)
dbWriteTable(mycon, name = "Notificacao", not2020, append = TRUE)
rm(not2020)

comando2021 <- "SELECT dt_notific, se_notif, dt_sin_pri, ano_notif, dt_digita,se_sin_pri,
municipio_geocodigo, cid10_codigo FROM \"Municipio\".\"Notificacao\" where ano_notif = 2021"
not2021 <-  dbGetQuery(conInfo, comando2021)
dbWriteTable(mycon, name = "Notificacao", not2021, append = TRUE)
rm(not2021)


# tabela historico

# dengue
comandoD <- "SELECT * FROM \"Municipio\".\"Historico_alerta\""
histD <-  dbGetQuery(conInfo, comandoD)
dbWriteTable(mycon, name = "Historico_alerta", histD, append = TRUE)
rm(histD)

#chik
comandoC <- "SELECT * FROM \"Municipio\".\"Historico_alerta_chik\""
histC <-  dbGetQuery(conInfo, comandoC)
dbWriteTable(mycon, name = "Historico_alerta_chik", histC, append = TRUE)
rm(histC)

# zika
comandoZ <- "SELECT * FROM \"Municipio\".\"Historico_alerta_zika\""
histZ <-  dbGetQuery(conInfo, comandoZ)
dbWriteTable(mycon, name = "Historico_alerta_zika", histZ, append = TRUE)
rm(histZ)


# ---------------------
# tabela municipal rio 
# --------------------
comandoD <- "SELECT * FROM \"Municipio\".\"alerta_mrj\""
histD <-  dbGetQuery(conInfo, comandoD)
dbWriteTable(mycon, name = "alerta_mrj", histD, append = TRUE)
rm(histD)

comandoC <- "SELECT * FROM \"Municipio\".\"alerta_mrj_chik\""
histC <-  dbGetQuery(conInfo, comandoC)
dbWriteTable(mycon, name = "alerta_mrj_chik", histC, append = TRUE)
rm(histC)


dbDisconnect(conInfo)

## Checking 

#mycon <- dbConnect(RSQLite::SQLite(), "../../AlertaDengueAnalise/mydengue.sqlite")
dbListTables(mycon)
class(mycon)

dbDisconnect(mycon)


