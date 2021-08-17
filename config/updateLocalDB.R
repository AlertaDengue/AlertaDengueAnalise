###########################################
# Update local SQLite  - Infodengue local
###########################################

# Importante. Assume-se que ja existe um 
# SQLite local com dados do Infodengue. Usar essa função
# para atualizar o banco local.

# Requer acesso ao banco remoto
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC


library(DBI)
library(assertthat)
library(tidyverse)




# con = connection to remote database
# anos = years of the data that will be substituted. We will delete the local data
# for these years and replace with remote data.

update_local_db <- function(pw, mycon){
  
  con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                   user = "dengue", host = "localhost", 
                   password = pw)
  
  today <- Sys.Date()
  
  # -----------------------------
  message("updating Tweet...")
  lagtw <- 180 # dias a serem substituidos (ultimos 180 dias)
  # dbListFields(mycon, "Tweet")
  tw.date <- dbGetQuery(mycon, 'SELECT MAX(data_dia) FROM "Tweet"')
  message(paste("last tweet date was", as.Date(tw.date[[1]], origin = "1970-01-01")))
  
  # deleting last tweets
  dbExecute(mycon, paste0("DELETE FROM 'Tweet' where data_dia > ", 
                           as.numeric(today - lagtw)))
  # getting the new ones
  twnovo <-  dbGetQuery(con, paste0("SELECT * FROM \"Municipio\".\"Tweet\" where 
                                   data_dia > '", today - lagtw,"'"))
  # appending them
  dbWriteTable(mycon, name = "Tweet", twnovo, append = TRUE)
  newtw.date <- dbGetQuery(mycon, 'SELECT MAX(data_dia) FROM "Tweet"')  
  message(paste("tweet updated to", as.Date(newtw.date[[1]], origin = "1970-01-01")))
  rm(twnovo)
  
  # -----------------------------
  message("updating WU...")
  lagwu <- 180 # dias a serem substituidos (ultimos 180 dias)
  # dbListFields(mycon, "Tweet")
  wu.date <- dbGetQuery(mycon,
                        'SELECT MAX(data_dia) FROM wu')
  
  message(paste("last wu date was", 
                as.Date(wu.date[[1]], 
                        origin = "1970-01-01")))
  
  # deleting last wus
  dbExecute(mycon, 
            paste0("DELETE FROM wu where data_dia > ", 
                   as.numeric(today - lagwu)))
  # getting the new ones
  wunovo <-  dbGetQuery(con,
             paste0("SELECT * FROM \"Municipio\".\"Tweet\" where data_dia > '",
                    today - lagwu,"'"))
  
  # appending them
  dbWriteTable(mycon, name = "wu", wunovo, append = TRUE)
  
  newwu.date <- dbGetQuery(mycon, 
                           'SELECT MAX(data_dia) FROM wu')
  
  message(paste("wu updated to", as.Date(newwu.date[[1]], origin = "1970-01-01")))
  rm(wunovo)
  
  
  # -----------------------------
  message("updating Notifications...")
  lagnot <- 365 # dias a serem substituidos (ultimos 365 dias)
  # dbListFields(mycon, "Tweet")
  not.date <- dbGetQuery(mycon,
                        'SELECT MAX(dt_notific) FROM "Notificacao"')
  
  message(paste("last notification date was", 
                as.Date(not.date[[1]], 
                        origin = "1970-01-01")))
  
  # deleting last notifications
  dbExecute(mycon, 
            paste0("DELETE FROM 'Notificacao' where dt_notific > ", 
                   as.numeric(today - lagnot)))
  # getting the new ones
  notnovo <-  dbGetQuery(con,
                        paste0("SELECT dt_notific, se_notif, dt_sin_pri, 
                        ano_notif, dt_digita, municipio_geocodigo, cid10_codigo 
                               FROM \"Municipio\".\"Notificacao\" where dt_notific > '",
                               today - lagnot,"'"))
  dbDisconnect(con)
  # appending them
  dbWriteTable(mycon, name = "Notificacao", notnovo, append = TRUE)
  
  newnot.date <- dbGetQuery(mycon, 
                           'SELECT MAX(dt_notific) FROM "Notificacao"')
  
  message(paste("notificacao updated to", as.Date(newnot.date[[1]], origin = "1970-01-01")))
  rm(novo)
  
  dbDisconnect(mycon)

  message("local database updated. Now you are ready to run the pipeline")  
  }


