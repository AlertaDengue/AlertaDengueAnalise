# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo do alerta 
# Claudia Codeco 2015
# -----------------------------------------------------------



#greenyellow --------------------------------------------------------------------
#'@title Define conditions to issue an alert of 2 levels Green/Yellow.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.
#'@param obj dataset from the mergedata function.
#'@param gy criteria to change from green to yellow 
#'@param yg criteria to change from yellow to green
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw <- getTweet(city = c(330455), lastday = "2014-03-10")
#'clima <- getWU(stations = 'SBRJ', var="tmin", finalday = "2014-03-10")
#'d<- mergedata(tweet = tw, climate = clima)
#'critgy <- c("tmin > 22 | tweet > 10", 3)
#'crityg <- c("tmin <= 22 & tweet <= 10", 3)
#'alerta <- greenyellow(d, gy = critgy, yg = crityg)
#'names(alerta)
#'head(alerta$indices)

greenyellow <- function(obj, gy, yg){
      le <- dim(obj)[1] 
      # accumulating condition function
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      # data.frame to store results
      indices <- data.frame(gytrue = rep(NA,le), ngytrue = rep(NA,le),
                            ygtrue = rep(NA,le), nygtrue = rep(NA,le))
            
      # calculating each condition (week and accumulated)  
      indices$gytrue <- as.numeric(eval(parse(text = cgy[1])))
      indices$ngytrue <- accumcond(indices$gytrue, as.numeric(cgy[2]))
      indices$ygtrue <- as.numeric(eval(parse(text = cyg[1])))
      indices$nygtrue <- accumcond(indices$ygtrue, as.numeric(cyg[2]))
      
      # setting the level
      indices$level <- 1
      indices$level[indices$ngytrue == as.numeric(cgy[2])] <-2
      indices$level[indices$nygtrue == as.numeric(cyg[2])] <- 1
      return(list(data=obj, indices=indices, rules=paste(gy,",",yg), n = 2))      
}



#plot.alert --------------------------------------------------------------------
#'@title Plot the time series of warnings.
#'@description 
#'@param obj object created by the greenyellow or green2red functions.
#'@param var to be ploted in the graph, usually cases when available.  
#'@param cores colors corresponding to the levels 1, 2, 3, 4.
#'@return a plot
#'@examples
#'tw <- getTweet(city = c(330455), lastday = "2014-03-10")
#'clima <- getWU(stations = 'SBRJ', var="tmin", finalday = "2014-03-10")
#'d<- mergedata(tweet = tw, climate = clima)
#'critgy <- c("tmin > 22 | tweet > 10", 3)
#'crityg <- c("tmin <= 22 & tweet <= 10", 3)
#'alerta <- greenyellow(d, gy = critgy, yg = crityg)
#'plot.alerta(alerta, "tmin")



plot.alerta<-function(d, var, cores = c("#0D6B0D","#C8D20F","orange","red")){
      
      stopifnot(names(d) == c("data", "indices", "rules","n"))
      stopifnot(var %in% names(d$data))
      stopifnot(n %in% c(2,4))
      
      par(mai=c(0,0,0,0),mar=c(4,4,1,1))
      x <- 1:length(obj$SE)
      ticks <- seq(1, length(d$data$SE), length.out = 8)
      
      if (d$n == 2){
            plot(x, d$data[,var], xlab = "SE", ylab = var, type="l", axes=FALSE)
            axis(2)
            axis(1, at = ticks, labels = d$data$SE[ticks], las=3)
            for (i in 1:2) {
                  onde <- which(d$indices$level==i) 
                  if (length(onde))
                        segments(x[onde],0,x[onde],(d$data[onde,var]),col=cores[i],lwd=3)
            }
            
            }
}
      
      
            

#setOrange --------------------------------------------------------------------
#'@title Raise orange alert if sustained transmission is detected.
#'@description "Orange" is defined by effective reproductive number greater than 1. 
#'Rt must be computed before using this function.
#'@param obj object created by the Rt function.
#'@param pvalue probability of wrongly rejecting the hypothesis Rt > 1   
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'res <- getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'resd <- aggrbylocality(d = res, locality="AP1") # Rio de Janeiro
#'resfit <- adjustIncidence(se = res$SE, y = res$casos)
#'rtnorm<-Rt(obj = resfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'ora = setOrange(obj = rtnorm, pvalue = 0.9, lag= 3) 
#'head(ora)
#'x = 1:length(ora$SE)
#'plot(x, ora$Rt, type="l", xlab= "weeks", ylab = "Rt")
#'lines(x, ora$upr, lty = 3)
#'lines(x, ora$lwr, lty = 3)
#'abline(h = 1, col =2)
#'points(x[ora$oweek==1], ora$Rt[ora$oweek==1], col="orange", pch=16)

setOrange <- function(obj, pvalue = 0.9, lag=3){
  
  if(!("p1" %in% names(obj))) stop("obj must be created by an Rt function")
  
  obj$oweek <- as.numeric(obj$p1 > pvalue)
  
  # lag weeks accumulated condition
  le <- dim(obj)[1]
  ac <- obj$oweek[lag:le]
  for(i in 1:(lag-1)) ac <- ac+obj$oweek[(lag-i):(le-i)]
  obj$oacc <- c(rep(NA,(lag-1)),ac)
  
  return(obj)
}


#setRed --------------------------------------------------------------------
#'@title Raise red alert if incidence reaches above a threshold. 
#'@description "Red" indicates high dengue incidence, defined by a threshold provided 
#'by the user. The WHO recommends 300 per 100.000. 
#'@param obj case count dataset generated by the getcase (ajusted or not).
#'@param pop population of the area.
#'@param adjust TRUE if adjusting incidence is required. FALSE if not.   
#'@param ccrit incidence threshold (per 100.000).
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'res = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'resd = aggrbylocality(d = res, locality="AP1") # Rio de Janeiro
#'resfit<-adjustIncidence(se = resd$SE, y = resd$casos)
#'red = setRed(obj = resfit, pop = 30000, ccrit = 10, lag=3)
#'tail(red)
#'x = 1:length(red$SE)
#'plot(x, red$inc, type="l", xlab= "weeks", ylab = "incidence")
#'abline(h = 10, col =2)
#'points(x[red$rweek==1], red$inc[red$rweek==1], col="red", pch=16)

setRed <- function(obj, pop, ccrit=100, lag=3){
  
  if("tcasesICmin" %in% names(obj)) {}
  else stop("please carry out the incidence adjustment first.")
      
  inc <- obj$tcasesICmin / pop * 100000
  i1 <- inc > ccrit
  # 3 weeks accumulated condition
  le <- length(i1)
  ac <- i1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+i1[(lag-i):(le-i)]
  
  obj$inc <- inc
  obj$rweek <- as.numeric(i1)
  obj$racc <- c(rep(NA,(lag-1)),ac)
  
  return(obj)
  }



#classify ------------------------------------------------------------
#'@title Classifies the disease time series into transmission levels.
#'@description This function receives the time series inputs (cases, tweets, 
#'climate) and return levels of alert (1 (low) to 4 (high)). It will run the
#' set color functions and them combine them hierarchically.    
#'@param yellow object from setyellow function.
#'@param orange object from setorange function.
#'@param red object from setred function.
#'@return data.frame with
#'@examples
#' #This is the whole sequence of the alert. Getting data:
#'res <- getCases(city = c(330455), withdivision = TRUE) # get case data from Rio de Janeiro
#'resd <- aggrbylocality(d = res, locality="AP1") # case data from a locality in Rio de Janeiro
#'tweet <- getTweet(city = c(330455)) # Rio de Janeiro # get tweeter data
#'clima <- getWU(stations = 'SBRJ', var = "tmin") # get locality's tmin from local meteorological station
#' #Adjust incidence
#'adjcase <- adjustIncidence(se = resd$SE, y = resd$casos)
#' # Calculate Rt
#'rtnorm<-Rt(obj = resfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#' #Calculate each level
#'yellowalert <- setYellow(temp = clima$tmin, se = clima$SE, tempcrit = 22)
#'orangealert <- setOrange(obj = rtnorm, pvalue = 0.9, lag= 3) 
#'redalert <- setRed(obj = resfit, pop = 30000, ccrit = 100, lag=3)
#' # green - yellow levels only 
#'resu <- classify(yel = yellowalert) # with only green-yellow levels
#'tail(resu)
#'x = 1:length(resu$temp)
#'plot(x,resu$temp, type="l", xlab= "weeks", ylab = "temp")
#'points(x[resu$level==2], resu$temp[resu$level==2], col="yellow",pch=16)
#' # all four levels
#'resu <- classify(yel = yellowalert, ora = orangealert, red = redalert, inerciaon=1, inerciaoff=c(NA,1,1,1)) 
#'x = 1:length(resu$casos)
#'plot(x,resu$casos, type="l", xlab= "weeks", ylab = "casos")
#'points(x[resu$level==2], resu$casos[resu$level==2], col="yellow",pch=16)
#'points(x[resu$level==3], resu$casos[resu$level==3], col="orange",pch=16)
#'points(x[resu$level==4], resu$casos[resu$level==4], col="red",pch=16)


classify <- function(yel, ora=c(), red=c(), inerciaon=3, inerciaoff = c(NA,3,3,3)){
  
  obj <- yel
  # defining the number of levels from the input
  if (is.null(obj)) stop("calculate setYellow")
  
  ncol <- 2
  
  obj$level <- NA
  les = dim(obj)[1]
  obj$level[intersect(6:les,which(obj$yacc < inerciaon))] <-  1 # first color (green)
  obj$level[intersect(6:les,which(obj$yacc >= inerciaon))] <-  2 # second color (yellow)
  for (i in 1:inerciaoff[2]) obj$level[intersect(6:les,which(yel$yacc>=3)+i)] <- 2
  
  if (is.null(yel) == FALSE & is.null(ora) == FALSE & is.null(red) == FALSE){ # add orange and red
    obj <- merge(obj, ora, by="SE", by.all = TRUE)
    red <- subset(red, select=-casos)
    obj <- merge(obj, red, by="SE", by.all = TRUE)
    ncol <- 4
    obj$level[intersect(6:les,which(ora$oacc >= inerciaon))] <- 3 
    for (i in 1:inerciaoff[3]) obj$level[intersect(6:les,which(ora$oacc>=3)+i)] <- 3
    
    obj$level[intersect(6:les,which(red$racc >= inerciaon))] <- 4
    for (i in 1:inerciaoff[4]) obj$level[intersect(6:les,which(red$racc>=3)+i)] <- 4  
  }
    
  if(ncol == 2) message("Alert with 2 levels (green - yellow)")
  else message("Alert with 4 levels (all colors)")
    
  
  obj
}

