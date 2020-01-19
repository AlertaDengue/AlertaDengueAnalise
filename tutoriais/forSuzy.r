# extracao de dados para o estudo com o grupo da Suzy

library(AlertTools)

con<-DenguedbConnect()

# Notification data from geocod Municipality:
geocodigos <- getCidades(uf="Rio de Janeiro")
geocod<-geocodigos$municipio_geocodigo[geocodigos$nome=="Resende"]

query.txt <- paste0("SELECT * from 
                    \"Municipio\".\"Notificacao\"
                    WHERE municipio_geocodigo = ", geocod)
df <- dbGetQuery(con, query.txt)

# Filter duplicate data and missing values:
target.cols <- c('nu_notific','dt_digita', 'municipio_geocodigo')
df.mun.clean <- df[!duplicated(df[, target.cols]) & !is.na(df$dt_digita),
                           c('municipio_geocodigo', 'dt_notific', 'dt_digita')]

# Filter by years:
df.mun <- df.mun.clean[df.mun.clean$dt_notific >= '2012-01-01' & 
                                   df.mun.clean$dt_notific <= '2016-12-31', ]

# Twitter data
query.txt <- paste0("SELECT * from 
                    \"Municipio\".\"Tweet\"
                    WHERE \"Municipio_geocodigo\" = ", geocod, "AND data_dia <='2017-01-01'")
tw <- dbGetQuery(con, query.txt)[c("Municipio_geocodigo","data_dia","numero")]

tail(tw)

range(df.mun$dt_notific)
range(tw$data_dia)
# Save object:
save(df.mun, tw, file='dengue-resende-2012-2016.RData')

