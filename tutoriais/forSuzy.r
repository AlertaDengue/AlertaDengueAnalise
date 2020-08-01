# extracao de dados para o estudo com o grupo da Suzy

library(AlertTools)

con<-DenguedbConnect(pass = pw)

# Notification data from geocod Municipality:
geocod<-3304557

query.txt <- paste0("SELECT * from 
                    \"Municipio\".\"Notificacao\"
                    WHERE municipio_geocodigo = ", geocod)
df <- dbGetQuery(con, query.txt)

# Filter duplicate data and missing values:
target.cols <- c('nu_notific','dt_digita', 'municipio_geocodigo')
df.mun.clean <- df[!duplicated(df[, target.cols]) & !is.na(df$dt_digita),
                           c('cid10_codigo','dt_sin_pri' ,'dt_notific', 'dt_digita')]

# Filter by years:
df.mun <- df.mun.clean[df.mun.clean$dt_notific >= '2012-01-01' & 
                                   df.mun.clean$dt_notific <= '2019-12-31', ]

table(df.mun$cid10_codigo)
df.mun$cid10_codigo[df.mun$cid10_codigo=="A920"] <- "A92.0"

library(tidyverse)

df.mun <- df.mun %>%
  filter(cid10_codigo %in% c("A90","A92.0","A928"))

# Twitter data
query.txt <- paste0("SELECT * from 
                    \"Municipio\".\"Tweet\"
                    WHERE \"Municipio_geocodigo\" = ", geocod, "AND data_dia <='2020-01-01'")
tw <- dbGetQuery(con, query.txt)[c("data_dia","numero")]

tail(tw)

range(df.mun$dt_notific)
range(tw$data_dia)
# Save object:
save(df.mun, tw, file='dengue-chik-zika-Rio-2012-2019.RData')

