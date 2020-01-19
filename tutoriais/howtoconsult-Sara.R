library("AlertTools")
library(RPostgreSQL)
con=DenguedbConnect()

# Listar as tabelas disponiveis
dbListTables(con) # lista de tabelas (elas estao em diferentes schemas)


# As tabelas estão dentro de schemas.  Listando as variaveis nas tabelas do schema "Municipio" 
dbListFields(con, c("Municipio","Notificacao")) # dados de dengue
dbListFields(con, c("Municipio","Bairro"))
dbListFields(con, c("Municipio","Historico_alerta"))
dbListFields(con, c("Municipio","Tweet"))
dbListFields(con, c("Municipio","alerta_mrj"))
dbListFields(con, c("Municipio","Localidade")) # APS do Rio de Janeiro
dbListFields(con, c("Municipio","Historico_alerta_chik")) # APS do Rio de Janeiro

# 
dbListFields(con, c("Municipio","Estacao_cemaden")) # metadados das estacoes
dbListFields(con, c("Municipio","Clima_cemaden")) # variaveis meteorologicas

# dados do weatherunderground
dbListFields(con, c("Municipio","Estacao_wu")) # metadados 
dbListFields(con, c("Municipio","Clima_wu")) # variaveis meteorologicas

dbListFields(con, c("Dengue_global","regional_saude")) # variaveis meteorologicas
dbListFields(con, c("Dengue_global","Municipio")) # 
dbListFields(con, c("Dengue_global","parameters")) # 
# Exemplos de consultas:
# -----------------------

# baixar a tabela toda
tw <- dbReadTable(con, c("Municipio","alerta_mrj"))
tail(tw[order(tw$data),])


# baixar a tabela de tweet filtrando para um municipio
comando <- "SELECT * FROM \"Municipio\".\"Tweet\" WHERE \"Municipio_geocodigo\" = 2304400"
d <- dbGetQuery(con, comando)
str(d)
head(d)

# primeiros 2 registros da tabela dengue global. estado
comando <- "SELECT * FROM \"Dengue_global\".\"estado\" LIMIT 2"
d <- dbGetQuery(con, comando)
str(d)


# baixar a tabela tweet filtrando para um municipio e apenas registros maiores que 10
comando <- "SELECT * FROM \"Municipio\".\"Tweet\" WHERE \"Municipio_geocodigo\" = 3304557 AND numero > 10"
tw <- dbGetQuery(con, comando)
str(tw)

# dados de notificacao
dbListFields(con, c("Municipio","Notificacao")) # dados de dengue
comando <- "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE \"municipio_geocodigo\" = 2304400 AND ano_notif = 2016 AND cid10_codigo = 'A90'"
comando <- "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE \"municipio_geocodigo\" = 2304400 AND dt_digita = '2016-07-20'"

d <- dbGetQuery(con, comando)
str(d)
dim(d)


# Qual a estacao meteorologica e os limiars epidemicos da cidade ?
sqlquery = "SELECT * FROM \"Dengue_global\".\"regional_saude\" WHERE municipio_geocodigo < 2500000"
d <- dbGetQuery(con, sqlquery)
head(d)

# query linkando informacao de duas tabelas

sqlquery = "SELECT  DISTINCT(sensor)
FROM  \"Municipio\".\"Estacao_cemaden\" AS e 
INNER JOIN \"Municipio\".\"Clima_cemaden\" AS c 
ON e.codestacao = c.\"Estacao_cemaden_codestacao\" WHERE e.municipio = 'RIO DE JANEIRO' limit 10"

dd <- dbGetQuery(con, sqlquery)


sqlquery = "SELECT  *
FROM  \"Municipio\".\"Estacao_cemaden\" AS e 
INNER JOIN \"Municipio\".\"Clima_cemaden\" AS c 
ON e.codestacao = c.\"Estacao_cemaden_codestacao\" WHERE e.municipio = 'RIO DE JANEIRO' 
AND c.sensor = 'intensidade_precipicacao'"

cemaden.prec <- dbGetQuery(con, sqlquery)
head(cemaden.prec)


# dados da tabela Estacao wu para a estacao SBFZ

sqlquery = paste("SELECT  *
                 FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBFZ'")
wu <- dbGetQuery(con, sqlquery)

summary(wu)

# Dados de chikungunya do municipio 3304557
sqlquery = "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = 3304557 AND cid10_codigo = \'A920\'"
d <- dbGetQuery(con, sqlquery)

#####################

#### Analise dos dados

## Dados de uma cidade
geocodigo = 2304400
cas = getCases(city = geocodigo, datasource = con) 
tw = getTweet(city = geocodigo, datasource = con)
climatemp = getWU(stations = 'SBFZ', var="temp_min", datasource=con)
umid.min = getWU(stations = 'SBFZ', var="umid_min", datasource=con)
umid.med = getWU(stations = 'SBFZ', var="umid_med", datasource=con)
umid.max = getWU(stations = 'SBFZ', var="umid_max", datasource=con)

# juntando
d <- merge(cas[,c("SE","casos","pop")], tw[,c("SE","tweet")], by="SE")
head(d)
d<- merge(d,climatemp[,c("SE","temp_min")])
d<- merge(d,umid.min[,c("SE","umid_min")])
d<- merge(d,umid.med[,c("SE","umid_med")])
d<- merge(d,umid.max[,c("SE","umid_max")])

# calcula Rt
d<-Rt(d,count = "casos", gtdist = "normal", meangt = 3, sdgt=1)
head(d)
boxplot(d$umid_min~d$Rt > 1, notch = T)
boxplot(d$umid_med~d$Rt > 1, notch = T)
boxplot(d$umid_max~d$Rt > 1, notch = T)
