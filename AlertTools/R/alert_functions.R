# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo do alerta 
# Claudia Codeco 2015
# -----------------------------------------------------------

#setYellow --------------------------------------------------------------------
#'@title Define conditions to issue an alert of level "Attention"
#'@description Level is yellow if environmental conditions required for
#'positive mosquito population growth.
#'@param temp time series of temperature.
#'@param tempcrit critical temperature.
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'clima = getWU(stations = c(330455), var = "tmin")
#'clima = cbind(clima, setYellow(clima$tmin,22)) 
#'head(clima)

setYellow <- function(temp, tempcrit, lag=3){
  t1 <- as.numeric(temp > tempcrit)
  # 3 weeks accumulated condition
  le <- length(t1)
  ac <- t1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+t1[(lag-i):(le-i)]
  data.frame(yweek = t1, yacc = c(rep(NA,(lag-1)),ac))
}


#setOrange --------------------------------------------------------------------
#'@title Define transmission conditions and raise an alert of level "Transmission"
#'@description "Orange" is defined as reproductive number greater than 1
#'@param y time series of cases (already corrected for notification delay)
#'@param pvalue probability of wrongly rejecting the hypothesis Rt > 1   
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'resd = aggregateCases(d = res, locality="AP1") # Rio de Janeiro
#'resd <- cbind(resd, adjustIncidence(resd$casos))
#'head(resd)
#'ora = setOrange(y = resd$fit["inc"], pvalue = 0.9, lag= 3) 
#'head(ora)

setOrange <- function(y, pvalue, lag=3){
  Rt<-calcRt(y, gtdist="normal",meangt=3,sdgt = 1)
  
  t1 <- (Rt > 1) 
  # 3 weeks accumulated condition
  le <- length(t1)
  ac <- t1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+t1[(lag-i):(le-i)]
  data.frame(weekorange = t1, accorange = c(rep(NA,(lag-1)),ac))
}


#setRed --------------------------------------------------------------------
#'@title Define conditions to raise the red alert 
#'@description "Red" indicates high dengue incidence, abova a threshold.
#'@param y case count (ajusted or not).
#'@param se sequence of epidemiological weeks. Not required, just to include in the output.
#'@param pop population of the area.
#'@param adjust TRUE if adjusting incidence is required. FALSE it not.   
#'@param ccrit incidence threshold (per 100.000).
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'res = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'resd = aggrbylocality(d = res, locality="AP1") # Rio de Janeiro
#'red = setRed(se = resd$SE, y = resd$casos, adjust=TRUE, pop = 30000, ccrit = 100, lag=3)
#'tail(red)
#'plot(red$tcasesICmin, type="b", ylab = "incidence")

setRed <- function(y, se, pop, adjust = TRUE, ccrit=100, lag=3){
  
  if(adjust)
    casesm <- adjustIncidence(se = se, y = y)[["tcasesICmin"]]
    else
      casesm <- y
  
  inc <- casesm / pop * 100000
  i1 <- inc > ccrit
  # 3 weeks accumulated condition
  le <- length(i1)
  ac <- i1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+i1[(lag-i):(le-i)]
  
  res <- data.frame(cases = casesm, inc = inc, rweek = as.numeric(i1), racc = c(rep(NA,(lag-1)),ac))  
  if(!is.null(se)) res <- cbind(se, res)
  res
  }



#classifyTransmission ---------------------------------------------------------
#'@title Classifies the disease transmission into 4 levels.
#'@description This function does many things. First, it  
#'@param y time series of cases per locality.
#'@param temp time series of temperature.
#'@param tw time series of tweets.   
#'@param tempcrit critical temperature.
#'@param inccrit critical incidence, per 100.000.
#'@param pop population size   
#'@return data.frame with 
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'resd = aggregateCases(d = res, division = "test") # Rio de Janeiro
#'resd$fit<-adjustIncidence(resd$casos)
#'clima = getWU(stations = c(330455), var = "tmin")
#'tweet = getTweet(city = c(330455)) # Rio de Janeiro
#'resu <- classifyTransmission(y = resd[resd$reg=="AP2.1",], temp = clima, station="SBRJ",
#'                      tw = tweet, tempcrit = 22, inccrit = 100) 
#'tail(resu)



classifyTransmission <- function(y, temp, station, tw, tempcrit, inccrit, pop=552691){
  
  # Merging data
  temperatura <- temp[temp$estacao == station,]
  d <- merge(y, temperatura, by="SE", all.x=TRUE)
  # + tweets
  dd <- merge(d, tw, by="SE",all.x=TRUE)
  le <- dim(dd)[1]
  
  # Minimum temperature > Tcrit for 3 weeks
  
}

