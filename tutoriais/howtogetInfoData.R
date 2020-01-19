library("RPostgreSQL")


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

# query dados de clima

sqlquery = paste("SELECT  *
  FROM  \"Municipio\".\"Estacao_wu\" AS e 
  INNER JOIN \"Municipio\".\"Clima_wu\" AS c 
  ON e.estacao_id = c.\"Estacao_wu_estacao_id\" WHERE e.estacao_id =", "'SBRJ'")

sbrj <- dbGetQuery(con, sqlquery)

# dados de dengue

cid10="A90"
sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = ", 3302205, 
             " AND cid10_codigo = \'", cid10,"\'", sep="")

d <- dbGetQuery(con, sql)
table(d$ano_notif)

sql <- "SELECT * from \"Municipio\".alerta_mrj_chik"
dbGetQuery(con,sql)
