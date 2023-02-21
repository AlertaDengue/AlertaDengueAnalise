# demo: nowcasting using AlertTools 

# installing AlertTools
install_github("AlertaDengue/AlertTools", dependencies = TRUE)

#------- Pacotes usados pelo AlertTools
pkgs <- c("foreign", "tidyverse", "forecast", "RPostgreSQL", "xtable",
          "zoo","assertthat","DBI",
          "futile.logger","lubridate", "grid","INLA",
          "cgwtools","fs","miceadds", "AlertTools")

lapply(pkgs, library, character.only = TRUE ,quietly = T)

# USE: 
# connection
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengueadmin", host = "159.69.25.201", port ="15432",
                 password = pw)

# setting nowcast date
now.date <- as.Date("2019-10-30")
now.se <- data2SE(now.date, format = "%Y-%m-%d")   # semana epidemiologica

# get data for a city, 1 year of data.
dados <- getdelaydata(cities=4100905, nyears=1, cid10="A90", 
lastday = now.date, datasource=con)  

dbDisconnect(con)

# nowcasting
res <-bayesnowcasting(dados, nowSE = now.se)

