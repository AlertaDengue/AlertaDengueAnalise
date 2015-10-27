# PROJETO ALERTA DENGUE -------------------------------------
# FUNCOES PARA ORGANIZAR SERIES
#TEMPORAIS A PARTIR DOS DADOS BRUTOS CLAUDIA CODECO - 2015

# GetWU --------------------------------------------------------
#'@description Create weekly time series from meteorological station data in server
#'@title Get Climate Data
#'@param stations vector with the stations codes (4 digits) OR the city's geocode.
#'@param var climate variables (default var="all": all variables available )
#'@param finalday last day. Default is the last available. 
#'@return data.frame with the weekly data (cidade estacao data tmin tmed tmax umin umed umax pressaomin pressaomed pressaomax)
#'@examples
#'res = getWU(stations = c('SBRJ','SBJR','SBAF','SBGL'))
#'head(res)
#'res = getWU(stations = c(330455))
#'head(res)
#'res = getWU(stations = 'SBRJ', var="tmin", finalday = "2013-10-10")

getWU <- function(stations, var = "all", finalday = Sys.Date(), datasource = "data/WUdata.rda") {
    
    stopifnot(all(nchar(stations) == 6) || all(nchar(stations) == 4)) # incluir teste de existencia da cidade
  
    # Test data -------------------------------------------
    if (datasource == "data/WUdata.rda") load(datasource)
    
    # if cities are given as argument
    if (all(nchar(stations) == 6)) { 
        if (datasource == "data/WUdata.rda") sta = unique(WUdata$estacao[WUdata$cidade%in%stations]) 
        message("the stations belong to the following cities:")
        print(sta)
    } 
    # if stations are given as argument
    if (all(nchar(stations) == 4)) {  
        if (datasource == "data/WUdata.rda") {
          cities = unique(WUdata$cidade[WUdata$estacao%in%stations])
          sta = stations
        }
        message("the following stations were found:")
        print(sta)
    }
    
    # getting the climate data (all from each sta)------------------------------
    
    if (datasource == "data/WUdata.rda") {
      if (all(nchar(stations) == 6)) d <- WUdata
      else d <- subset(WUdata, estacao %in% stations)
    }
    
    # trimming data -----------------------------------------------------------
    d <- subset(d, as.Date(d$data, format = "%Y-%m-%d") <= finalday)
    
    # Atribuir SE e agregar por semana-----------------------------------------
    d$SE <- data2SE(d$data, format = "%Y-%m-%d")
    n = dim(d)[2] - 1
    df <- aggregate(d[, 4:n], by = list(cidade = d$cidade, SE = d$SE, estacao = d$estacao), 
                    FUN = mean, na.rm = TRUE)
    
    if (var != "all") df <- subset(df, select = c("cidade","SE","estacao",var))
    df
}
 
# GetTweet --------------------------------------------------------------
#'@description Create weekly time series from tweeter data from server. The 
#'source of this data is the Observatorio da Dengue (UFMG).
#'@title Get Tweeter Data
#'@param city city's geocode.
#'@param finalday last day. Default is the last available.
#'@param datasource server or "data/tw.rda" if using test dataset. 
#'@return data.frame with weekly counts of people tweeting on dengue.
#'@examples
#'res = getTweet(city = c(330455)) # Rio de Janeiro
#'tail(res)
#'res = getTweet(city = c(330455), lastday = "2014-03-01") # Rio de Janeiro
#'tail(res)


getTweet <- function(city, lastday = Sys.Date(), datasource = "data/tw.rda") {
  
  stopifnot(all(nchar(city) == 6)) # incluir teste de existencia da cidade  
  if (datasource == "data/tw.rda") {
    load(datasource)
  } else if (datasource == "db"){
    c1 <- paste("select data_dia, numero from \"Municipio\".\"Tweet\" where 
                \"Municipio_geocodigo\" between ", city,"0", sep = "", " ", "and", " ",city,"9")
    tw <- dbGetQuery(con,c1)
    names(tw)<-c("data","tweet")
  }
  
  tw <- subset(tw, as.Date(data, format = "%Y-%m-%d") <= lastday)
  
  # Atribuir SE e agregar por semana-----------------------------------------
  tw$SE <- data2SE(tw$data, format = "%Y-%m-%d")
  twf <- aggregate(tw[,2], by = list(SE = tw$SE), FUN = sum, na.rm = TRUE)
  names(twf)[2] <- "tweet"
  N = dim(twf)[1]
  twf <- cbind(localidade = rep(city, N), twf)
  twf
}


# GetCases --------------------------------------------------------------
#'@description Create weekly time series from case data from server. The source is the SINAN. 
#'@title Get Case Data and aggregate per week and area
#'@param city city's geocode.
#'@param finalday last day. Default is the last available.
#'@param disease default is "dengue".
#'@param withdivision either FALSE if aggregation at the city level, or TRUE.
#'@param datasource data server or "data/sinan.rda" if using local test data. 
#'@return data.frame with the data aggregated per week according to disease onset date.
#'@examples
#'dC0 = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'head(dC0)
#'dC0 = getCases(city = c(330455), withdivision = FALSE) 
#'tail(dC0)
#'dC0 = getCases(city = c(330455), lastday ="2014-03-10", withdivision = FALSE) 
#'tail(dC0)

getCases <- function(city, lastday = Sys.Date(),  withdivision = TRUE, disease = "dengue", datasource = "data/sinan.rda") {
  
  stopifnot(all(nchar(city) == 6)) # incluir teste de existencia da cidade  
  
  if (datasource == "data/sinan.rda") load(datasource)
  
  dd <- subset(sinan, DT_DIGITA <= lastday)
  if (withdivision == FALSE){
    st <- aggregate(dd$SEM_PRI,by=list(dd$SEM_PRI),FUN=length)
    names(st)<-c("SE","casos")
    st$SE<-as.numeric(as.character(st$SE))
    st <- cbind(localidade = city, st)
  } else {
    st <- aggregate(dd$SEM_PRI,by=list(bairro=dd$NM_BAIRRO, SE=dd$SEM_PRI),
                    FUN=length)
    names(st)[3]<-c("casos")
    st$SE<-as.numeric(as.character(st$SE))  
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
#'dC0 = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'dC1 = casesinlocality(obj = dC0, locality = "AP1") 
#'head(dC1)
#' Gives an error message: dataframe contains no column BAIRRO. 
#'dC0 = getCases(city = c(330455), withdivision = FALSE) 
#'dC1 = casesinlocality(obj = dC0, locality = "AP1") # Rio de Janeiro
#'head(dC1)

casesinlocality <- function(obj, locality){
  
  if(!all(c("bairro", "SE", "casos") %in% names(obj))) stop("only use function caseinlocality 
                                                             with dataframe with columns bairro, SE, casos.
                                                             Use the output of getCases(withdivision=TRUE)")
  # trocar locs depois pelo acesso direto ao servidor
  load("data/locs.rda")
  bair <- subset(locs, APS == locality)
  
  if(dim(bair)[1]==0) warning("no case in this locality")
  # dataframe para guardar os resultados
  load("R/sysdata.rda")
  semanas <- SE$Ano * 100 + SE$SE
  semin <- which(semanas == min(obj$SE))
  semax <- which(semanas == max(obj$SE))
  st <- data.frame(localidade=locality, SE=semanas[semin:semax], casos = NA)
  
  # selecionando os registros dos bairros da localidade
  db <- obj[(obj$bairro %in% bair$bairro),]
    
  for(i in 1:dim(st)[1]) st$casos[i] <- sum(db$SE == st$SE[i])
    
  return(st)
}



# mergedata --------------------------------------------------------------
#'@description Merge cases, tweets and climate data for the alert  
#'@title Merge cases, tweets and climate data.
#'@param cases data.frame with aggregated cases by locality (or city) and epidemiological week.
#'@param tweet data.frame with tweets aggregated per week
#'@param climate data.frame with climate data aggregated per week for the station of interest.
#'@return data.frame with all data available 
#'@examples
#'cas = getCases(city = c(330455), lastday ="2014-03-10", withdivision = FALSE) 
#'tw = getTweet(city = c(330455), lastday = "2014-03-10")
#'clima = getWU(stations = 'SBRJ', var="tmin", finalday = "2014-03-10")
#'mergedata(cases = cas,tweet = tw, climate = clima)
#'mergedata(tweet = tw, climate = clima)
#'mergedata(cases = cas, climate = clima)
#'mergedata(tweet = tw, climate = clima)

mergedata <- function(cases = c(), tweet =c(), climate=c()){
  # checking the datasets
  if (!is.null(cases) & !all(table(cases$SE)==1)) stop("merging require one line per SE in case dataset")
  if (!is.null(tweet) & !all(table(tweet$SE)==1)) stop("merging require one line per SE in tweet dataset")
  if (!is.null(climate) & !all(table(climate$SE)==1)) stop("merging require one line per SE in climate dataset")
  
  # merging
  if (is.null(cases)) d <- merge(tweet, climate, by="SE", all = TRUE)
  if (is.null(tweet)) d <- merge(cases, climate,  by="SE", all = TRUE)
  if (is.null(climate)) d <- merge(cases, tweet,  by="SE", all = TRUE)
  if (!(is.null(cases) | is.null(tweet) | is.null(climate))){
    d <- merge(cases, tweet,  by="SE", all = TRUE)
    d <- merge(d, climate,  by="SE", all=TRUE)  
  }
  
  d
}

