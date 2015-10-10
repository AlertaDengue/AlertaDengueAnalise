# PROJETO ALERTA DENGUE -------------------------------------
# FUNCOES PARA ORGANIZAR SERIES
#TEMPORAIS A PARTIR DOS DADOS BRUTOS CLAUDIA CODECO - 2015

# GetWU --------------------------------------------------------
#'@description Create weekly time series from meteorological station data in server
#'@title Get Climate Data
#'@param stations vector with the stations codes (4 digits) OR the city's geocode.
#'@param var climate variables (default var="all": all variables available )
#'@return data.frame with the weekly data (cidade estacao data tmin tmed tmax umin umed umax pressaomin pressaomed pressaomax)
#'@examples
#'res = getWU(stations = c('SBRJ','SBJR','SBAF','SBGL'))
#'head(res)
#'res = getWU(stations = c(330455))
#'head(res)

getWU <- function(stations, var = "all",datasource = "test") {
    
    stopifnot(all(nchar(stations) == 6) || all(nchar(stations) == 4)) # incluir teste de existencia da cidade
  
    if (datasource == "test") load("data/WUdata.rda")
    
    # if cities are given as argument
    if (all(nchar(stations) == 6)) { 
        if (datasource == "test") sta = unique(WUdata$estacao[WUdata$cidade%in%stations]) 
        message("the following stations were found:")
        print(sta)
    } 
    # if stations are given as argument
    if (all(nchar(stations) == 4)) {  
        if (datasource == "test") {
          cities = unique(WUdata$cidade[WUdata$estacao%in%stations])
          sta = stations
        }
        message("the stations belong to the following cities:")
        print(sta)
    }
    
    # getting the climate data (all from each sta)------------------------------
    
    if (datasource == "test") d<-WUdata
    
    # Atribuir SE e agregar por semana-----------------------------------------
    d$SE <- data2SE(d$data, format = "%Y-%m-%d")
    n = dim(d)[2] - 1
    df <- aggregate(d[, 4:n], by = list(cidade = d$cidade, SE = d$SE, estacao = d$estacao), 
                    FUN = mean, na.rm = TRUE)
    df
}
 
# GetTweet --------------------------------------------------------------
#'@description Create weekly time series from tweeter data from server. The 
#'source of this data is the Observatorio da Dengue (UFMG).
#'@title Get Tweeter Data
#'@param city city's geocode.
#'@param datasource server or "test" if using test dataset. 
#'@return data.frame with weekly counts of people tweeting on dengue.
#'@examples
#'res = getTweet(city = c(330455)) # Rio de Janeiro
#'head(res)

getTweet <- function(city, datasource = "test") {
  
  stopifnot(all(nchar(city) == 6)) # incluir teste de existencia da cidade  
  
  if (datasource == "test") load("data/tw.rda")
  
  # Atribuir SE e agregar por semana-----------------------------------------
  tw$SE <- data2SE(tw$data, format = "%Y-%m-%d")
  twf <- aggregate(tw[,2], by = list(SE = tw$SE), FUN = sum, na.rm = TRUE)
  names(twf)[2] <- city
  twf
}


# GetCases --------------------------------------------------------------
#'@description Create weekly time series from case data from server. The source is the SINAN. 
#'@title Get Case Data
#'@param city city's geocode.
#'@param disease Default is "dengue".
#'@param withdivision Either FALSE if aggregation at the city level, or TRUE if at the neighborhood
#'level. These are the two possible aggregations.
#'@param datasource data server or "test" if using local test data. 
#'@return data.frame with the data aggregated per week according to disease onset date.
#'@examples
#'res = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'head(res)
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'head(res)

getCases <- function(city, withdivision = TRUE, disease = "dengue", datasource = "test") {
  
  stopifnot(all(nchar(city) == 6)) # incluir teste de existencia da cidade  
  
  if (datasource == "test") load("data/sinan.rda")
  
  if (withdivision){
    st <- aggregate(sinan$SEM_PRI,by=list(SE=sinan$SEM_PRI, BAIRRO=sinan$NM_BAIRRO),
                    FUN=length)
    names(st)[3]<-c("casos")
    st$SE<-as.numeric(as.character(st$SE))
  } else{
    st <- aggregate(sinan$SEM_PRI,by=list(sinan$SEM_PRI),FUN=length)
    names(st)<-c("SE","casos")
    st$SE<-as.numeric(as.character(st$SE))
  }
  st  
}


