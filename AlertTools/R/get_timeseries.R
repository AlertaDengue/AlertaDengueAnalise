# PROJETO ALERTA DENGUE -------------------------------------
# FUNCOES PARA ORGANIZAR SERIES
#TEMPORAIS A PARTIR DOS DADOS BRUTOS CLAUDIA CODECO - 2015

# GetWU --------------------------------------------------------
#'@description Create weekly time series from meteorological station data in server
#'@title Get Climate Data
#'@param stations vector with the stations codes (4 digits).
#'@param city vector with the cities codes (6 digits). Not implemented yet. 
#'@param vars climate variables (default var="all": all variables available )
#'@param finalday last day. Default is the last available. Format = Year-month-day. 
#'@param datasource Use "data/WUdata.rda" to use test dataset. #' Use the connection to the Postgresql server if using project data. See also DenguedbConnect
#' to open the database connection. 
#'@return data.frame with the weekly data (cidade estacao data temp_min tmed tmax umin umed umax pressaomin pressaomed pressaomax)
#'@examples
#'res = getWU(stations = c('SBRJ','SBJR','SBAF'), datasource="data/WUdata.rda")
#'res = getWU(stations = 'SBRJ', vars="temp_min", finalday = "2014-10-10", datasource= con)
#'tail(res)

getWU <- function(stations, vars = "temp_min", city=c(), finalday = Sys.Date(), datasource) {
      
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
#'@return data.frame with weekly counts of people tweeting on dengue.
#'@examples
#'res = getTweet(city = c(330455), lastday = "2014-03-01", datasource = con)
#'res = getTweet(city = c(330455), datasource = "data/tw.rda") 
#'tail(res)

getTweet <- function(city, lastday = Sys.Date(), datasource) {
      
      if(nchar(city) == 6) city <- sevendigitgeocode(city)   
      if (class(datasource) == "character") {
            load(datasource)
            
      } else if (class(datasource) == "PostgreSQLConnection"){
            c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" = ", city)
            tw <- dbGetQuery(datasource,c1)
            names(tw) <- c("data_dia","tweet")
      }
      
      tw <- subset(tw, as.Date(data_dia, format = "%Y-%m-%d") <= lastday)
      
      # Atribuir SE e agregar por semana-----------------------------------------
      tw$SE <- data2SE(tw$data_dia, format = "%Y-%m-%d")
      sem <- seqSE(from = min(tw$SE), to = max(tw$SE))$SE
      twf <- data.frame(SE = sem, tweet = NA)
      for (i in 1:dim(twf)[1]) twf$tweet[i] <- sum(tw$tweet[tw$SE==twf$SE[i]])  
      twf$cidade <- city
      twf
}


# GetCases --------------------------------------------------------------
#'@description Create weekly time series from case data from server. The source is the SINAN. 
#'@title Get Case Data and aggregate per week and area
#'@param city city's geocode.
#'@param finalday last day. Default is the last available.
#'@param disease default is "dengue".
#'@param withdivision either FALSE if aggregation at the city level. TRUE not working.
#'@param datasource "db" if using the project database or "data/sinan.rda" if using local test data. 
#'@return data.frame with the data aggregated per week according to disease onset date.
#'@examples
#'dC0 = getCases(city = c(330455), lastday ="2014-03-10", withdivision = FALSE, datasource = "data/sinan.rda") 
#'dC0 = getCases(city = 330455, withdivision = FALSE, datasource = con) 
#'head(dC0)

getCases <- function(city, lastday = Sys.Date(),  withdivision = FALSE, 
                     disease = "dengue", datasource) {
      
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
            if (dim(dd)[1]==0) stop("geocodigo retornou zero casos. Está correto?")
            
            dd$SEM_NOT <- data2SE(dd$dt_notific, format = "%Y-%m-%d")
            
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
      
      sem <- seqSE(from = min(dd$SEM_NOT), to = max(dd$SEM_NOT))$SE
      nsem <- length(sem)
      
      if (withdivision == FALSE){
            st <- data.frame(SE = sem, casos = 0)
            for(i in 1:nsem) st$casos[i] <- sum(dd$SEM_NOT == st$SE[i])
            st$localidade <- 0
            st$cidade <- city
      } else {
            stop("division = TRUE not working yet.")
            bairro = na.omit(unique(dd$NM_BAIRRO))
            st <- expand.grid(SE = sem, bairro = bairro)
            st$casos <- 0
            nst <- dim(st)[1]
            for(i in 1:nst) st$casos[i] <- sum(dd$SEM_NOT == st$SE[i] & dd$NM_BAIRRO == st$bairro[i])
            st$cidade <- city
      }  
      st  
}


# casesinlocality --------------------------------------------------------------
#'@description Get time series of cases generated by getCases withdivision=TRUE 
#'and aggregate it per health district. Requires a file containing the list of 
#'neighborhoods in the city and their corresponding health districts. 
#'@title Get disagreggated time series of cases and aggregate per health district 
#'@param obj data.frame created by getCases with withdivision = TRUE (per bairro) 
#'@param division data.frame with bairros and corresponding health districts. The neighborhood
#'names must match exactly the ones in the sinan. If "test" uses test data from Rio.  
#'@return data.frame with the data aggregated per health district and week
#'@examples
#'dC0 = getCases(city = c(330455), withdivision=TRUE,datasource = "data/sinan.rda") # Rio de Janeiro
#'dC1 = casesinlocality(obj = dC0, locality = "AP1") 
#'Gives an error message: dataframe contains no column BAIRRO. 
#'dC0 = getCases(city = c(330455), withdivision = FALSE,datasource = "data/sinan.rda") 
#'dC1 = casesinlocality(obj = dC0, locality = "AP1") # Rio de Janeiro

casesinlocality <- function(obj, locality){
      stop("the code for within city alert is not currently working.")
      
      if(!all(c("bairro", "SE", "casos") %in% names(obj))) stop("only use function caseinlocality 
                                                             with dataframe with columns bairro, SE, casos.
                                                             Use the output of getCases(withdivision=TRUE)")
      # trocar locs depois pelo acesso direto ao servidor
      load("data/locs.rda")
      bair <- subset(locs, APS == locality)
      cidade <- unique(obj$cidade, na.rm=TRUE)
      if(dim(bair)[1]==0) warning("no case in this locality")
      # dataframe para guardar os resultados
      load("R/sysdata.rda")
      semanas <- SE$Ano * 100 + SE$SE
      semin <- which(semanas == min(obj$SE))
      semax <- which(semanas == max(obj$SE))
      st <- data.frame(cidade = cidade, localidade=locality, 
                       SE=semanas[semin:semax], casos = NA)
      
      # selecionando os registros dos bairros da localidade
      db <- obj[(obj$bairro %in% bair$bairro),]
      
      for(i in 1:dim(st)[1]) st$casos[i] <- sum(db$SE == st$SE[i])
      
      return(st)
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
#'cas = getCases(city = c(330455), withdivision = FALSE, datasource = "data/sinan.rda") 
#'tw = getTweet(city = c(330455), datasource = "data/tw.rda")
#'clima = getWU(stations = 'SBRJ', var="temp_min", datasource="data/WUdata.rda")
#'head(mergedata(cases = cas, tweet = tw, climate = clima))
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


