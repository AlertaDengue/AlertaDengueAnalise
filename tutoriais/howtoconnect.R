library("RPostgreSQL")

## Esse arquivo ensina a:

# 1. Acessar o banco de dados do projeto
# 2. Criar um objeto data.frame a partir da consulta ao banco de dados

#----------------------------------------
# 1. Acessar o banco de dados do projeto
#----------------------------------------

dbname <- "dengue"
user <- "dengueadmin"
password <- ""
host <- "localhost"

con <- dbConnect(dbDriver("PostgreSQL"), user=user,
                 password=password, dbname=dbname)

# Listar as tabelas disponiveis
dbListTables(con) # lista de tabelas (elas estao em diferentes schemas)


# As tabelas estão dentro de schemas.  Listando as variaveis nas tabelas do schema "Municipio" 
dbListFields(con, c("Municipio","Notificacao")) # dados de dengue
dbListFields(con, c("Municipio","Bairro"))
dbListFields(con, c("Municipio","Historico_alerta"))
dbListFields(con, c("Municipio","Tweet"))
dbListFields(con, c("Municipio","alerta_mrj"))
dbListFields(con, c("Municipio","Localidade")) # APS do Rio de Janeiro

# 
dbListFields(con, c("Municipio","Estacao_cemaden")) # metadados das estacoes
dbListFields(con, c("Municipio","Clima_cemaden")) # variaveis meteorologicas

# dados do weatherunderground
dbListFields(con, c("Municipio","Estacao_wu")) # metadados 
dbListFields(con, c("Municipio","Clima_wu")) # variaveis meteorologicas

dbListFields(con, c("Dengue_global","regional_saude")) # variaveis meteorologicas
dbListFields(con, c("Dengue_global","Municipio")) # 
dbListFields(con, c("Dengue_global","parameters")) # 

tt <- dbReadTable(con, c("Municipio","Localidade"))
summary(tt)


# Exemplos de consultas:
# -----------------------

# baixar a tabela toda
wu <- dbReadTable(con, c("Municipio","Clima_wu"))
str(wu)

est <- dbReadTable(con, c("Municipio","Estacao_wu"))
str(est)

d <- dbReadTable(con, c("Municipio","alerta_mrj"))
range(d$data)


d <- dbReadTable(con, c("Municipio","alerta_mrj"))
range(d$data)
table(d$Rt)

# baixar a tabela de tweet filtrando para um municipio
comando <- "SELECT * FROM \"Municipio\".\"Tweet\" WHERE \"Municipio_geocodigo\" = 2304400"
d <- dbGetQuery(con, comando)
str(d)
head(d)


comando <- "SELECT geocodigo,nome,populacao,uf FROM \"Dengue_global\".\"Municipio\" "
pop <- dbGetQuery(con, comando)
save(pop, file = "pop.RData")

# primeiros 2 registros da tabela dengue global. estado
comando <- "SELECT * FROM \"Dengue_global\".\"estado\" LIMIT 2"
d <- dbGetQuery(con, comando)
str(d)

# tabela de parametros
comando <- "SELECT * FROM \"Dengue_global\".\"parameters\" WHERE municipio_geocodigo = 3506003" 
dbGetQuery(con, comando)

# baixar a tabela tweet filtrando para um municipio e apenas registros maiores que 10
comando <- "SELECT * FROM \"Municipio\".\"Tweet\" WHERE \"Municipio_geocodigo\" = 3304557 AND numero > 10"
tw <- dbGetQuery(con, comando)
str(tw)

# baixar a tabela tweet filtrando para um municipio e apenas registros maiores que 10
comando <- "SELECT nome, geocodigo FROM \"Dengue_global\".\"Municipio\" "
mun <- dbGetQuery(con, comando)

save(mun, file = "mun.RData")

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


# dados da tabela Estacao wu para a estacao SBRJ

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBRJ'")
dSBRJ <- dbGetQuery(con, sqlquery)


# dados da tabela da estacao wu para a estacao SBJR , primeiros 10 registros

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBJR' limit 10")

sbjr <- dbGetQuery(con, sqlquery)

# Dados de chikungunya do municipio 3304557
sqlquery = "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = 3304557 AND cid10_codigo = \'A920\'"
d <- dbGetQuery(con, sqlquery)

# Dados de notificacao do municipio 
sqlquery = "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = 3304557 AND ano_notif = 2019
AND cid10_codigo = \'A90\' AND se_notif > 34"
d <- dbGetQuery(con, sqlquery)
summary(d)

# Dados de notificacao por doenca  
sqlquery = "SELECT * FROM \"Municipio\".\"Notificacao\" WHERE cid10_codigo = \'A92.8\'"
d <- dbGetQuery(con, sqlquery)
table(d$municipio_geocodigo)

####### Outros comandos

 
dbListFields(con, c("Dengue_global","Municipio"))
dbListFields(con, c("Dengue_global","regional_saude"))

d <- dbReadTable(con, c("Dengue_global",""))
str(d)

sqlquery = "SELECT * FROM \"Dengue_global\".\"regional_saude\" WHERE municipio_geocodigo = 3200136"
dr <- dbGetQuery(con, sqlquery)
dr

sqlquery = "SELECT * FROM \"Dengue_global\".\"regional_saude\" "
d <- dbGetQuery(con, sqlquery)
head(d)

# ------------------------------------------------------
# 2. Criar um objeto data.frame a partir da consulta ao banco de dados
# ------------------------------------------------------
cid10="A90"
sql1 <- paste("'", Sys.Date(), "'", sep = "")
sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE dt_digita <= ",sql1, " AND municipio_geocodigo = ", 3302205, 
             " AND cid10_codigo = \'", cid10,"\'", sep="")

d <- dbGetQuery(con, sql)
table(d$ano_notif)
sum(is.na(d$dt_digita))

sql <- paste("SELECT dt_notific,bairro_nome,bairro_bairro_id from \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = ", 3304557, 
             " AND cid10_codigo = \'", cid10,"\'", sep="")
d <- dbGetQuery(con, sql)
table(d$ano_notif)

sql <- paste("SELECT ano_notif,COUNT(*) from \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = ", 3302205, 
             " AND cid10_codigo = \'", cid10,"\' GROUP BY ano_notif", sep="")
d
# 2a. Pegando a tabela inteira (não aconselho porque são todos os muncipios)
     # Exemplo com a tabela de tweet

tw <- dbReadTable(con, c("Municipio","Tweet"))
str(tw)

tw <- dbReadTable(con, c("Municipio","Clima_demaden"))
str(tw)


      # Exemplo com a tabela alerta_mrj
tw <- dbReadTable(con, c("Municipio","alerta_mrj"))
str(tw)
dim(tw)

#Selecionando pelo valor de uma das variaveis, é preciso usar SQL
c1 <- "SELECT * from \"Municipio\".\"Historico_alerta\" WHERE 
                \"municipio_geocodigo\" = 3304507 "
d <- dbGetQuery(con,c1)


c1 <- "SELECT * from \"Municipio\".\"Historico_alerta\" WHERE 
                \"SE\" is NULL"
d <- dbGetQuery(con,c1)

c1 <- "SELECT * from \"Municipio\".\"Historico_alerta\""
d <- dbGetQuery(con,c1)


c1 <- paste("SELECT * from \"Municipio\".\"alerta_mrj\"")
d <- dbGetQuery(con,c1)


#Selecionando todas as cidades de sao paulo
c1 <- paste("SELECT * from \"Dengue_global\".\"Municipio\" WHERE 
                geocodigo > 3000000")
d <- dbGetQuery(con,c1)

# municipio
c1 <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE 
               \"municipio_geocodigo\" = 4100301")

c1 <- paste("SELECT * from \"Municipio\".\"Historico_alerta\" WHERE 
               \"municipio_geocodigo\" = 4113700")

d <- dbGetQuery(con,c1)
plot(d$data_iniSE, d$casos)
mu = unique(d$municipio_geocodigo)
umu = d[d$SE==201736,]
View(umu[,c(3:6)])

# locs
poligs <- dbReadTable(con, c("Municipio","Localidade"))
str(poligs)
dim(tw)



# 2b. Selecionando pelo valor de uma das variaveis, é preciso usar SQL
c1 <- paste("SELECT * from \"Municipio\".\"Tweet\" WHERE 
                \"Municipio_geocodigo\" =", 118056 )
d <- dbGetQuery(con,c1)
head(d)
plot(d$numero)

sql <- "SELECT * from \"Municipio\".\"Historico_alerta\" where \"data_iniSE\" < '2009-12-31'"
dbGetQuery(con, sql)

#getTweet <- function(city, lastday = Sys.Date(), datasource = "data/tw.rda") {
c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" between ", city,"0", sep = "", " ", "and", " ",city,"9")
tw <- dbGetQuery(con,c1)
names(tw)<-c("data","tweet")
tw <- subset(tw, as.Date(data, format = "%Y-%m-%d") <= lastday)
 
 
## tirando os dados do parana de 2016
dbListFields(con, c("Municipio","Notificacao"))
sql <- "SELECT * from \"Municipio\".\"Notificacao\" WHERE  municipio_geocodigo > 3200000 AND municipio_geocodigo < 3300000 AND ano_notif=2106"
dd <- dbGetQuery(con, sql)

#sql <- "DELETE from \"Municipio\".\"Notificacao\" WHERE  municipio_geocodigo > 4100000 AND ano_notif=2016"
#dbGetQuery(con, sql)


## dados da regional do ES
dbListFields(con, c("Dengue_global","regional_saude"))
sql <- "SELECT * from \"Dengue_global\".\"regional_saude\" WHERE  municipio_geocodigo > 3200000 AND municipio_geocodigo < 3300000"
dbGetQuery(con, sql)

## dados da regional do ES
dbListFields(con, c("Dengue_global","regional_saude"))
sql <- "SELECT * from \"Dengue_global\".\"regional_saude\" WHERE  municipio_geocodigo > 3200000 AND municipio_geocodigo < 3300000"
dbGetQuery(con, sql)


## getWU <- function(stations, var = "all", finalday = Sys.Date(), datasource = "data/WUdata.rda") {
  # creating the sql query for the stations
  sql1 = paste("'", stations[1], sep = "")
  if (ns > 1) for (i in 2:ns) sql1 = paste(sql1, stations[i], sep = "','")
  sql1 <- paste(sql1, "'", sep = "")
  
  # sql query for the date
  sql2 = paste("'", finalday, "'", sep = "")
  
  sql <- paste("SELECT * from \"Municipio\".\"Clima_wu\" WHERE \"Estacao_wu_estacao_id\"
IN  (", sql1, ") AND data_dia <= ",sql2)
  d <- dbGetQuery(con,sql)
  if (!var[1]=="all") d <- d[,var]
            
## getCases(city, lastday = Sys.Date(),  withdivision = TRUE, disease = "dengue", datasource = "data/sinan.rda") {
  sql1 <- paste("'", finalday, "'", sep = "")
  sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE dt_digita <= ",sql1)
  sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE 
               municipio_geocodigo = 3302403")
  dd <- dbGetQuery(con,sql)
  
  sevendigitgeocode(410030)
  

  sql <- paste("SELECT nome,populacao,uf from \"Dengue_global\".\"Municipio\" WHERE geocodigo = 3302205")
  d <- dbGetQuery(con,sql)
  
  sql <- paste("DELETE from \"Dengue_global\".\"historico_alerta\" WHERE municipio_geocodigo > 3200000 AND municipio_geocodigo < 3300000")
  
  # ====================
  # criando tabela teste
  # ====================
  
  dados <- dbReadTable(con, c("Municipio","Historico_alerta"))
  dados <- dados %>% filter(municipio_geocodigo==4113205)
  dbWriteTable(con, "teste", dados, overwrite=TRUE, row.names=FALSE)  
  dbListTables(con) # lista de tabelas (elas estao em diferentes schemas)
  dbListFields(con, c("teste"))
  newdata = data.frame(SE=201547:201556,casos=rep(99,10),localidade=rep(99,10),cidade=rep(99,10))
  #sql = 'insert into "teste" ("SE", casos, localidade, cidade) values(0,0,"somewhere","there")'
  
  for (li in 1:dim(newdata)[1]){
        linha = as.character(newdata[li,])
        for (i in 2:dim(newdata)[2]) linha = paste(linha, as.character(newdata[li,i]),sep=",")
        
        sql = paste("insert into \"teste\" (\"SE\", casos, localidade, cidade) values(", linha ,")")
        dbGetQuery(con, sql)    
  }
    
  
  tab <- dbReadTable(con, c("teste"))
  tab
  
  # =================================================
  # inserindo os dados na nova tabela de regionais
  # =================================================
  dbListFields(con, c("Dengue_global","regional_saude"))
  tabr <- dbReadTable(con, c("Dengue_global","regional_saude"))
  
  sql <- "SELECT * from \"Dengue_global\".regional_saude WHERE  municipio_geocodigo >= 3500000 AND municipio_geocodigo < 3600000"
  dd <- dbGetQuery(con, sql)
  
  #sql <- "DELETE from \"Dengue_global\".regional_saude WHERE  municipio_geocodigo = 3117836"
  #dbGetQuery(con, sql)
  
  
  newdata <- read.csv("regionaisSP.csv")
  tail(newdata)
  
  inserelinha <- function(newd,li){
        el1 = as.character(newd[li,"municipio_geocodigo"])
        el2 = as.character(newd[li,"id_regional"])
        el3 = paste("'",as.character(newd[li,"codigo_estacao_wu"]),"'",sep="")
        el4 = paste("'",as.character(newd[li,"nome_regional"]),"'",sep="")
        linha = paste(el1,el2,el3,el4,sep=",")
        sql = paste("insert into \"Dengue_global\".\"regional_saude\" (municipio_geocodigo, id_regional, 
                     codigo_estacao_wu, nome_regional) values(", linha ,")")
        dbGetQuery(con, sql)    
  }
  
  inserelinha(newdata,1)
  
  for (i in 1:dim(newdata)[1]) inserelinha(newdata,i)

    
  tabr <- dbReadTable(con, c("Dengue_global","regional_saude"))
  
  #sql <- "DELETE from \"Dengue_global\".\"regional_saude\" where municipio_geocodigo > 4100000"
  #dbGetQuery(con, sql)
  
  # =======================
  # join
  # =======================
  
  sql = paste("SELECT nome_regional, uf, geocodigo
               FROM \"Dengue_global\".\"Municipio\" 
               INNER JOIN \"Dengue_global\".regional_saude
               ON municipio_geocodigo = geocodigo
               where uf = 'Rio de Janeiro'")

  dbGetQuery(con, sql)    
  
  sql = paste("SELECT * FROM \"Municipio\".\"Notificacao\" 
               INNER JOIN \"Municipio\".\"Localidade\"
               ON municipio_geocodigo = geocodigo
               where uf = 'Rio de Janeiro'")
  
  sqlquery = paste("SELECT   n.dt_notific, l.id, l.nome
  FROM  \"Municipio\".\"Notificacao\" AS n 
  INNER JOIN \"Municipio\".\"Bairro\" AS b 
  ON n.bairro_nome = b.nome 
  INNER JOIN \"Municipio\".\"Localidade\" AS l 
  ON b.\"Localidade_id\" = l.id
  WHERE l.id = 1")
  
  dd <- dbGetQuery(con, sqlquery)
  summary(dd)
  
  sqlquery = paste("SELECT l.id, l.nome, b.nome
  FROM  \"Municipio\".\"Bairro\" AS b 
  INNER JOIN \"Municipio\".\"Localidade\" AS l 
  ON b.nome = l.nome
  ")
  
  sqlquery = paste("SELECT *
  FROM  \"Municipio\".\"Bairro\"")

  
 sql = paste("SELECT nome_regional, uf, geocodigo, populacao
               FROM \"Dengue_global\".\"Municipio\" 
              INNER JOIN \"Dengue_global\".regional_saude
              ON municipio_geocodigo = geocodigo")
  
  dd<- dbGetQuery(con, sql)    
  write.csv(dd,file="regionaisPR.csv")
  # =====================
  # criar nova coluna na tabela Localidade para inserir nova divisao submunicipal
  
  dbListFields(con, c("Municipio","Localidade")) 
  
  sql <- paste("SELECT * from \"Municipio\".\"Localidade\"")
  dd <- dbGetQuery(con,sql)
  
  crianewcol <- "ALTER TABLE \"Municipio\".\"Localidade\" ADD COLUMN codigo_estacao_wu
character varying(5) DEFAULT NULL"
  
  dd <- dbGetQuery(con,crianewcol)
  
  # =========================
  # cria nova coluna nas tabelas de historico para inserir tweets
  dbListFields(con, c("Municipio","Historico_alerta"))
  #crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ADD COLUMN tweet numeric(5) DEFAULT NULL"
  #tab <- dbGetQuery(con,crianewcol)
  
  dbListFields(con, c("Municipio","Historico_alerta_chik"))
  #crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_chik\" ADD COLUMN tweet numeric(5) DEFAULT NULL"
  
  dbListFields(con, c("Municipio","Historico_alerta_zika"))
  #crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_zika\" ADD COLUMN tweet numeric(5) DEFAULT NULL"
  
  # para inserir pop, Rt, tempmin, umidmax na tabela de dengue
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ADD COLUMN \"Rt\" numeric(5) DEFAULT NULL"
  altercol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ALTER COLUMN \"Rt\" decimal() DEFAULT NULL"
  tab <- dbGetQuery(con,altercol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ADD COLUMN pop numeric(7) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ADD COLUMN tempmin numeric(4) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta\" ADD COLUMN umidmax numeric(4) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # dbListFields(con, c("Municipio","Historico_alerta"))
  
  
  # para inserir pop, Rt, tempmin, umidmax na tabela de dengue
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_chik\" ADD COLUMN \"Rt\" numeric(5) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_chik\" ADD COLUMN pop numeric(7) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_chik\" ADD COLUMN tempmin numeric(4) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_chik\" ADD COLUMN umidmax numeric(4) DEFAULT NULL"
  # tab <- dbGetQuery(con,crianewcol)
  # dbListFields(con, c("Municipio","Historico_alerta_chik"))
  # 
  # para inserir pop, Rt, tempmin, umidmax na tabela de zika
  crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_zika\" ADD COLUMN \"Rt\" numeric(5) DEFAULT NULL"
  tab <- dbGetQuery(con,crianewcol)
  crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_zika\" ADD COLUMN pop numeric(7) DEFAULT NULL"
  tab <- dbGetQuery(con,crianewcol)
  crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_zika\" ADD COLUMN tempmin numeric(4) DEFAULT NULL"
  tab <- dbGetQuery(con,crianewcol)
  crianewcol <- "ALTER TABLE \"Municipio\".\"Historico_alerta_zika\" ADD COLUMN umidmax numeric(4) DEFAULT NULL"
  tab <- dbGetQuery(con,crianewcol)
  dbListFields(con, c("Municipio","Historico_alerta_zika"))
  
  # ======================
  # cria nova coluna na tabela regional saude para inserir cid
  tabr <- dbReadTable(con, c("Dengue_global","regional_saude"))
  head(tabr)
  
  dbWriteTable(con, c("Dengue_global", "parameters"), value = tabr[,c("municipio_geocodigo","limiar_preseason",
                                                                      "limiar_posseason","limiar_epidemico",
                                                                      "varcli")])
  
  tab = dbReadTable(con, c("Dengue_global", "parameters"))
  #crianewcol <- "ALTER TABLE \"Dengue_global\".parameters ADD COLUMN clicrit numeric(5) DEFAULT NULL"
  #crianewcol <- "ALTER TABLE \"Dengue_global\".parameters ADD COLUMN cid10 character DEFAULT NULL"
  #crianewcol <- "ALTER TABLE \"Dengue_global\".parameters ADD COLUMN codmodelo VARCHAR DEFAULT NULL"
  #altercol <- "ALTER TABLE \"Dengue_global\".parameters ALTER COLUMN cid10 TYPE VARCHAR"
  #tab <- dbGetQuery(con,crianewcol)
  
  clit <- tabr$municipio_geocodigo[which(tabr$ucrit==87)]
  sqlcity = paste("'", clit[1], sep = "")
  nci = length(clit)
  for (i in 2:nci) sqlcity = paste(sqlcity, clit[i], sep = "','")
  sqlcity <- paste(sqlcity, "'", sep = "")
  
  #update_sql = paste("UPDATE \"Dengue_global\".parameters SET clicrit = 87 WHERE municipio_geocodigo IN(", sqlcity,")", sep="") 
  #update_sql = "UPDATE \"Dengue_global\".parameters SET cid10 = \'A90\'"
  #update_sql = "UPDATE \"Dengue_global\".parameters SET codmodelo = \'Aw\' WHERE varcli= 'umid_max'"
  
  #dbGetQuery(con,update_sql)
  comando <- "SELECT * FROM \"Dengue_global\".parameters WHERE municipio_geocodigo = 2304400"
  d <- dbGetQuery(con, comando)
   # =======================
  # inserir nova cidade na tabela localidade
  
  newdata = data.frame(
  nome = c("Norte","Oeste","Sul"),
  populacao = c(),
  geojson = c(),
  id = c(),
  codigo_estacao_wu = c()
  )
  
  inserelinha <- function(newd,li){
        el1 = as.character(newd[li,"municipio_geocodigo"])
        el2 = as.character(newd[li,"id_regional"])
        el3 = paste("'",as.character(newd[li,"codigo_estacao_wu"]),"'",sep="")
        el4 = paste("'",as.character(newd[li,"nome_regional"]),"'",sep="")
        linha = paste(el1,el2,el3,el4,sep=",")
        sql = paste("insert into \"Dengue_global\".\"regional_saude\" (municipio_geocodigo, id_regional, 
                     codigo_estacao_wu, nome_regional) values(", linha ,")")
        dbGetQuery(con, sql)    
  }
  
  inserelinha(newdata,1)
  
  for (i in 1:dim(newdata)[1]) inserelinha(newdata,i)
  
  #=====================================================
  ### 4b. Inserção do codigo das regionais na tabela regional
  
  # csv com os codigos para inserir 
  regcod <- read.csv("regionais-ceara.csv",encoding = "latin1", colClasses = c("numeric","numeric","character"))
  
  # inserindo 1 a 1
  #update_sql = paste("UPDATE \"Dengue_global\".regional_saude SET id_regional = 18 WHERE nome_regional = 'Iguatu'")
  #try(dbGetQuery(con, update_sql))
  
  
  # ========================================================
  ## Query para Suzy, Giovani
  # inner join notificacao com regional
  
  mun<-getCidades(regional = "Metropolitana I", uf="Rio de Janeiro",datasource=con)$municipio_geocodigo
  
  
  sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE  municipio_geocodigo in (3300456,3301702,
               3302007,3302270,3302502,3302858,3303203,3303500,3304144,3304557,3305109,3305554)")
  
  dd <- dbGetQuery(con,sql)
  ddd <- dd[,c("dt_notific","ano_notif","dt_sin_pri","dt_digita","municipio_geocodigo")]
  
  
  c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" between ", city,"0", sep = "", " ", "and", " ",city,"9")
  tw <- dbGetQuery(con,c1)
  names(tw)<-c("data","tweet")
  tw <- subset(tw, as.Date(data, format = "%Y-%m-%d") <= lastday)
  
  