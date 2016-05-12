# PROJETO ALERTA DENGUE -------------------------------------
# FUNCOES PARA ORGANIZAR SERIES
#TEMPORAIS A PARTIR DOS DADOS BRUTOS CLAUDIA CODECO - 2015

# GetWU --------------------------------------------------------
#'@description Create weekly time series from meteorological station data in server
#'@title Get Climate Data
#'@param stations station code (4 digits).
#'@param vars climate variables (default var="all": all variables available )
#'@param finalday last day. Default is the last available. Format = %Y-%m-%d. 
#'@param datasource Use "data/WUdata.rda" to use test dataset. #' Use the connection to the Postgresql server if using project data. See also DenguedbConnect
#' to open the database connection. 
#'@return data.frame with the weekly data (cidade estacao data temp_min tmed tmax umin umed umax pressaomin pressaomed pressaomax)
#'@examples
#'res = getWU(station = 'SBRJ', vars="temp_min", finalday = "2014-10-10", datasource= con)
#'tail(res)

getWU <- function(stations, vars = "temp_min", finalday = Sys.Date(), datasource) {
      
      if (!all(nchar(stations) == 4)) stop("'stations' should be a vector of 4 digit station names")
      nsta = length(stations)
      
      # loading Test data -------------------------------------------
      if (class(datasource) == "character") {
            load(datasource)
            cities = unique(WUdata$cidade[WUdata$Estacao_wu_estacao_id%in%stations])
            message(paste("stations belong to city(es):", cities))
            d <- subset(WUdata, Estacao_wu_estacao_id %in% stations)
            d <- subset(d, as.Date(d$data, format = "%Y-%m-%d") <= finalday)
                  
      } else if (class(datasource) == "PostgreSQLConnection") {
            # creating the sql query for the stations
            sql1 = paste("'", stations[1], sep = "")
            nsta = length(stations)
            if (nsta > 1) for (i in 2:nsta) sql1 = paste(sql1, stations[i], sep = "','")
            sql1 <- paste(sql1, "'", sep = "")
            # sql query for the date
            sql2 = paste("'", finalday, "'", sep = "")
            
            sql <- paste("SELECT * from \"Municipio\".\"Clima_wu\" WHERE 
                        \"Estacao_wu_estacao_id\"
                        IN  (", sql1, ") AND data_dia <= ",sql2)
            d <- dbGetQuery(datasource,sql)
      }
      
      names(d)[which(names(d)== "Estacao_wu_estacao_id")]<-"estacao"
      
      # Atribuir SE e agregar por semana-----------------------------------------
      d$SE <- data2SE(d$data, format = "%Y-%m-%d")
      
      sem <- seqSE(from = min(d$SE), to = max(d$SE))$SE
      df <- expand.grid(SE=sem, estacao = unique(d$estacao))
      N <- length(df$SE)
      
      for (i in vars){
            df[, i] <- NA
            for (t in 1:N){
                  subconj <- subset(d, (SE == df$SE[t] & estacao == df$estacao[t]))
                  df[t, i] <- mean(subconj[,i])
            }
      }
      df
}

# GetTweet --------------------------------------------------------------
#'@description Create weekly time series from tweeter data from server. The 
#'source of this data is the Observatorio da Dengue (UFMG).
#'@title Get Tweeter Data
#'@param city city's geocode.
#'@param finalday last day. Default is the last available.
#'@param datasource server or "data/tw.rda" if using test dataset. 
#' Use the connection to the Postgresql server if using project data. See also DenguedbConnect
#' to open the database connection. 
#'@return data.frame with weekly counts of people tweeting on dengue. The function returns NA for weeks 
#'before the implementation of the Observatorio, and returns 0 or positive numbers, afterwards.
#'@examples
#'res = getTweet(city = c(330455), lastday = "2014-03-01", datasource = con)
#'res = getTweet(city = 4100301, datasource = con) 
#'tail(res)

getTweet <- function(city, lastday = Sys.Date(), datasource) {
      
      if(nchar(city) == 6) city <- sevendigitgeocode(city)   
      if (class(datasource) == "character") {
            load(datasource)
            
      } else if (class(datasource) == "PostgreSQLConnection"){
            c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" = ", city)
            tw <- dbGetQuery(datasource,c1)
            if (dim(tw)[1]>0) 
            names(tw) <- c("data_dia","tweet")
      }
      if (sum(tw$tweet)==0) message(paste("cidade",city,"nunca tweetou sobre dengue"))
      # output com data de 201001 ate lastday
      sem <- seqSE(from = 201001, to = data2SE(lastday,format="%Y-%m-%d"))$SE
      tw.agregado <- data.frame(SE = sem, tweet = NA)
      
      if (dim(tw)[1]>0){
            #      tw <- subset(tw, as.Date(data_dia, format = "%Y-%m-%d") <= lastday)
            # transformar data em SE -----------------------------------------
            tw$SE <- data2SE(tw$data_dia, format = "%Y-%m-%d")
            for (i in 1:dim(tw)[1]) {
                  twse <- tw$SE[i] 
                  tw.agregado$tweet[tw.agregado$SE==twse] <- sum(tw$tweet[i])
            }
            tw.agregado$cidade <- city
      }
            
      tw.agregado
}


# GetCases --------------------------------------------------------------
#'@description Create weekly time series from case data from server. The source is the SINAN. 
#'@title Get Case Data and aggregate per week and area
#'@param city city's geocode.
#'@param finalday last day. Default is the last available.
#'@param disease default is "dengue".
#'@param datasource "db" if using the project database or "data/sinan.rda" if using local test data. 
#'@return data.frame with the data aggregated per week according to disease onset date.
#'@examples
#'dC0 = getCases(city = c(330455), lastday ="2014-03-10", datasource = "data/sinan.rda") 
#'dC0 = getCases(city = 4101200, datasource = con) 
#'head(dC0)

getCases <- function(city, lastday = Sys.Date(), disease = "dengue", datasource) {
      
      if(nchar(city) == 6) city <- sevendigitgeocode(city)   
      
      # reading the data
      if (class(datasource) == "character") {
            load(datasource)
            dd <- subset(sinan, DT_DIGITA <= lastday)
            dd$SEM_NOT <- as.numeric(as.character(dd$SEM_NOT))
      } else if (class(datasource) == "PostgreSQLConnection"){
            sql1 <- paste("'", lastday, "'", sep = "")
            sql <- paste("SELECT * from \"Municipio\".\"Notificacao\" WHERE dt_digita <= ",sql1, " AND municipio_geocodigo =", city)
            dd <- dbGetQuery(datasource,sql)
            if (dim(dd)[1]==0) {
                  message(paste("geocodigo",city,"nunca teve casos. Está correto?..."))
                  } else {
                  dd$SEM_NOT <- data2SE(dd$dt_notific, format = "%Y-%m-%d")
            }
            

      } else { # one or more dbf files
            nf = length(datasource)
            dd <- read.dbf(datasource[1])[,c("ID_MUNICIP","DT_NOTIFIC","SEM_NOT",
                                             "NU_ANO","DT_SIN_PRI","DT_DIGITA",
                                             "SEM_PRI","NM_BAIRRO")]
            dd <- subset(dd, ID_MUNICIP=city)
            if (nf > 1){
                  for (i in 2:nf) {
                        di <- read.dbf(datasource[i])[,c("ID_MUNICIP","DT_NOTIFIC","SEM_NOT",
                                                         "NU_ANO","DT_SIN_PRI","DT_DIGITA",
                                                         "SEM_PRI","NM_BAIRRO")]
                  dd <- rbind(dd, subset(di, ID_MUNICIP==city))
                  dd$SEM_NOT <- as.numeric(as.character(dd$SEM_NOT))
                  } 
            }
      }
      
      
      sem <- seqSE(from = 201001, to = data2SE(lastday,format="%Y-%m-%d"))$SE
      nsem <- length(sem)
      
      st <- data.frame(SE = sem, casos = 0)
      for(i in 1:nsem) st$casos[i] <- sum(dd$SEM_NOT == st$SE[i])

      st$localidade <- 0
      st$cidade <- city
            
      nome = NA
      pop = NA
      if (class(datasource) == "PostgreSQLConnection"){
            # pegando nome da cidade e populacao
            sql2 <- paste("SELECT nome,populacao from \"Dengue_global\".\"Municipio\" WHERE geocodigo =", city) 
            varglobais <- dbGetQuery(datasource,sql2)
            nome <- varglobais$nome
            pop <- varglobais$populacao      
      }
      st$nome <- nome 
      st$pop <- pop

        
      st  
}


# getCasesinRio --------------------------------------------------------------
#'@description Get time series of cases per APS in Rio de Janeiro (special case) 
#'@title Get cases from an APS in Rio de Janeiro and aggregate them into weekly time series. 
#'@param APSid 0(APS1), 1 (APS2.1), 2 (APS2.2), 3(APS3.1), 4(APS3.2), 5(APS3.3), 6(APS4),
#', 7(APS5.1), 8(APS5.2), 9(APS5.3)  
#'@return data.frame with the data aggregated per health district and week
#'@examples
#'dC = getCasesinRio(APSid = 1, datasource = con) # Rio de Janeiro
#'tail(dC)

getCasesinRio <- function(APSid, lastday = Sys.Date(), disease = "dengue",
                          datasource) {
      
      sqldate <- paste("'", lastday, "'", sep = "")
      
      sqlquery = paste("SELECT n.dt_notific, n.ano_notif, se_notif, l.id, l.nome
      FROM  \"Municipio\".\"Notificacao\" AS n 
      INNER JOIN \"Municipio\".\"Bairro\" AS b 
      ON n.bairro_nome = b.nome 
      INNER JOIN \"Municipio\".\"Localidade\" AS l 
      ON b.\"Localidade_id\" = l.id
      WHERE n.municipio_geocodigo = 3304557 AND l.id = ",APSid, "AND dt_digita <= ",sqldate)
      
      d <- dbGetQuery(datasource,sqlquery)
      d$SEM_NOT <- d$ano_notif*100+d$se_notif 
      d$SEM_NOT <- data2SE(d$dt_notific, format = "%Y-%m-%d")
            
      #Cria Serie temporal de casos
      sem <- seqSE(from = min(d$SEM_NOT), to = max(d$SEM_NOT))$SE
      nsem <- length(sem)
      st <- data.frame(SE = sem, casos = 0)
      for(i in 1:nsem) st$casos[i] <- sum(d$SEM_NOT == st$SE[i])
      st$nome <- "Rio de Janeiro"
      # agrega informacao de populacao da APS
      
      pop = NA
      sql2 <- paste("SELECT nome,id,populacao from \"Municipio\".\"Localidade\" WHERE id =", APSid) 
      varglobais <- dbGetQuery(datasource,sql2)
      st$pop <- varglobais$populacao      
      st$localidade <- varglobais$nome
      st$localidadeid <- varglobais$id
      st  
}



# mergedata --------------------------------------------------------------
#'@description Merge cases, tweets and climate data for the alert  
#'@title Merge cases, tweets and climate data.
#'@param cases data.frame with aggregated cases by locality (or city)
#' and epidemiological week.
#'@param tweet data.frame with tweets aggregated per week
#'@param climate data.frame with climate data aggregated per week for the
#' station of interest.
#'@return data.frame with all data available 
#'@examples
#'cas = getCases(city = 4100310, datasource = con) 
#'tw = getTweet(city = 4100310, datasource = con)
#'clima = getWU(stations = 'SBRJ', var="temp_min", datasource=con)
#'tail(mergedata(cases = cas, tweet = tw, climate = clima))
#'head(mergedata(tweet = tw, climate = clima))
#'head(mergedata(cases = cas, climate = clima))
#'head(mergedata(tweet = tw, cases = cas))

mergedata <- function(cases = c(), tweet =c(), climate=c(), ini=200952){
      # checking the datasets
      if (!is.null(cases) & !all(table(cases$SE)==1)) 
            stop("merging require one line per SE in case dataset")
      if (!is.null(tweet) & !all(table(tweet$SE)==1)) 
            stop("merging require one line per SE in tweet dataset")
      if (!is.null(climate) & !all(table(climate$SE)==1))
            stop("merging require one line per SE in climate dataset. Mybe you have more than one station.")
      
      # merging
      if (is.null(cases)) {
            d <- merge(climate, tweet, by=c("SE"), all = TRUE)
            d$casos <- NA
      } else if (is.null(tweet)){
            d <- merge(cases, climate,  by=c("SE"), all = TRUE)     
      } else if (is.null(climate)) {
            d <- merge(cases, tweet[, c("SE","tweet")],  by=c("SE"), all = TRUE)
      }
      if (!(is.null(cases) | is.null(tweet) | is.null(climate))){
            d <- merge(cases, tweet[, c("SE","tweet")],  by=c("SE"), all = TRUE)
            d <- merge(d, climate,  by=c("SE"), all=TRUE)  
      }
      # removing beginning
      d <- subset(d, SE > ini)
      d
}


