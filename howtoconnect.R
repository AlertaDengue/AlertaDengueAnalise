library("RPostgreSQL", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.0")


## Esse arquivo ensina a:

# 1. Acessar o banco de dados do projeto
# 2. Criar um objeto data.frame a partir da consulta ao banco de dados

#----------------------------------------
# 1. Acessar o banco de dados do projeto
#----------------------------------------

dbname <- "dengue"
user <- "dengueadmin"
password <- "aldengue"
host <- "localhost"

con <- dbConnect(dbDriver("PostgreSQL"), user=user,
                 password=password, dbname=dbname)

# Listar as tabelas disponiveis
dbListTables(con) # lista de tabelas (elas estao em diferentes schemas)


# As tabelas estão dentro de schemas.  Listando as variaveis nas tabelas do schema "Municipio" 
dbListFields(con, c("Municipio","Notificacao"))
dbListFields(con, c("Municipio","Bairro"))
dbListFields(con, c("Municipio","Historico_alerta"))
dbListFields(con, c("Municipio","Tweet"))
dbListFields(con, c("Municipio","alerta_mrj"))
dbListFields(con, c("Municipio","Localidade")) # APS do Rio de Janeiro

# 
dbListFields(con, c("Municipio","Estacao_cemaden")) 
dbListFields(con, c("Municipio","Clima_cemaden")) 

dbListFields(con, c("Municipio","Estacao_wu")) 
dbListFields(con, c("Municipio","Clima_wu")) 

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_cemaden\" AS e 
  INNER JOIN \"Municipio\".\"Clima_cemaden\" AS c 
  ON e.codestacao = c.\"Estacao_cemaden_codestacao\" WHERE e.municipio =", "'RIO DE JANEIRO'")
  
dd <- dbGetQuery(con, sqlquery)

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBRJ'")

sbrj <- dbGetQuery(con, sqlquery)

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBGL'")

sbgl <- dbGetQuery(con, sqlquery)

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBJR'")

sbjr <- dbGetQuery(con, sqlquery)

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBAF'")

sbaf <- dbGetQuery(con, sqlquery)

tempwu <- rbind(sbrj,sbgl,sbjr, sbaf)
save(tempwu, file="tempwu-rio.csv",row.names=F)



# Acessando a tabela "Municipio" dentro do "DengueGlobal" 
dbListFields(con, c("Dengue_global","Municipio"))
dbListFields(con, c("Dengue_global","regional_saude"))

# ------------------------------------------------------
# 2. Criar um objeto data.frame a partir da consulta ao banco de dados
# ------------------------------------------------------

# 2a. Pegando a tabela inteira (não aconselho porque são todos os muncipios)
     # Exemplo com a tabela de tweet

tw <- dbReadTable(con, c("Municipio","Tweet"))
str(tw)

      # Exemplo com a tabela alerta_mrj
tw <- dbReadTable(con, c("Municipio","alerta_mrj"))
str(tw)
dim(tw)

#Selecionando pelo valor de uma das variaveis, é preciso usar SQL
c1 <- paste("SELECT * from \"Municipio\".\"Historico_alerta\" WHERE 
                \"municipio_geocodigo\" =", 3304557)
d <- dbGetQuery(con,c1)
dd<-subset(d, uf=="São Paulo")[,c("geocodigo","nome","populacao","uf")]

c1 <- paste("SELECT * from \"Municipio\".\"alerta_mrj\"")
d <- dbGetQuery(con,c1)


#Selecionando todas as cidades de sao paulo
c1 <- paste("SELECT * from \"Dengue_global\".\"Municipio\" WHERE 
                geocodigo > 3000000")
d <- dbGetQuery(con,c1)

# municipio
c1 <- paste("SELECT * from \"Municipio\".\"Tweet\" WHERE 
               \"Municipio_geocodigo\" = 3304557")

d <- dbGetQuery(con,c1)
names(d)

# locs
poligs <- dbReadTable(con, c("Municipio","Localidade"))
str(poligs)
dim(tw)


# 2b. Selecionando pelo valor de uma das variaveis, é preciso usar SQL
c1 <- paste("SELECT * from \"Municipio\".\"Tweet\" WHERE 
                \"Municipio_geocodigo\" =", 4118204 )
d <- dbGetQuery(con,c1)
head(d)
plot(d$numero)
#sql <- "DELETE from \"Municipio\".\"Historico_alerta\" where casos_est=0"
dbGetQuery(con, sql)

#getTweet <- function(city, lastday = Sys.Date(), datasource = "data/tw.rda") {
c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" between ", city,"0", sep = "", " ", "and", " ",city,"9")
tw <- dbGetQuery(con,c1)
names(tw)<-c("data","tweet")
tw <- subset(tw, as.Date(data, format = "%Y-%m-%d") <= lastday)
 
 
## tirando os dados do parana de 2016
dbListFields(con, c("Municipio","Notificacao"))
sql <- "SELECT * from \"Municipio\".\"Notificacao\" WHERE  municipio_geocodigo > 3200000 AND ano_notif=2106"
dd <- dbGetQuery(con, sql)

#sql <- "DELETE from \"Municipio\".\"Notificacao\" WHERE  municipio_geocodigo > 4100000 AND ano_notif=2016"
#dbGetQuery(con, sql)


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
  
  # ====================
  # criando tabela teste
  # ====================
  
  dbWriteTable(con, "teste", dC0, overwrite=TRUE, row.names=FALSE)  
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
  
  sql <- "SELECT * from \"Dengue_global\".regional_saude WHERE  municipio_geocodigo >= 4100000"
  dd <- dbGetQuery(con, sql)
  
  #sql <- "DELETE from \"Dengue_global\".regional_saude WHERE  municipio_geocodigo = 3117836"
  #dbGetQuery(con, sql)
  
  
  newdata <- read.csv("../../EPR_municipios_regional_saude1.csv")
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
  
  