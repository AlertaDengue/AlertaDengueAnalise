# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo do alerta 
# Claudia Codeco 2015
# -----------------------------------------------------------


#twoalert --------------------------------------------------------------------
#'@title Define conditions to issue a 2 level alert Green/Yellow.
#'@description This function is meant to be used when case data is absent. 
#'In this scenario, only two levels exist: Yellow if environmental conditions 
#'required for positive mosquito population growth are detected, or if social activity
#'increases. Green otherwise. But clearly, the user can define any rule. 
#'@param obj dataset from the mergedata function containing at least SE, and the 
#'variables used for alert calculation.
#'@param cy criteria to set the yellow alarm, written as a vector with three elements.
#'The first is the condition (see the example), the second is the number of times the
#'condition must be tru to issue the yellow alert, and the third, the number of weeks
#'false to turn off the alert (green).
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw <- getTweet(city = c(330455))
#'clima <- getWU(stations = 'SBRJ', var="tmin")
#'d<- mergedata(tweet = tw, climate = clima)
#'crity <- c("tmin > 22", 3, 3)
#'alerta <- twoalert(d, cy = crity)
#'head(alerta$indices)
#'plot.alerta(alerta, var="tmin")

twoalert <- function(obj, cy){
      le <- dim(obj)[1] 
      # accumulating condition function
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      # data.frame to store results
      indices <- data.frame(ytrue = rep(NA,le), nytrue = rep(NA,le))
                            
      # calculating each condition (week and accumulated)  

      indices$ytrue <- with(obj, as.numeric(eval(parse(text = cy[1]))))
      indices$nytrue <- with(obj, accumcond(indices$ytrue, as.numeric(cy[2])))
            
      # setting the level
      indices$level <- 1
      indices$level[indices$nytrue == as.numeric(cy[2])] <-2
      for(i in 1:cy[3]){  # delay to turn off
            indices$level[which(indices$nytrue == as.numeric(cy[3])) + i] <-2      
      }
      
      return(list(data=obj, indices=indices, rules=paste(cy), n = 2))      
}


#fouralert ---------------------------------------------------------------------
#'@title Define conditions to issue a 4 level alert Green-Yellow-Orange-Red.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param obj dataset from the mergedata function.
#'@param cy conditions for yellow. 
#'@param co conditions for orange.
#'@param cr conditions for red.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw <- getTweet(city = c(330455))
#'clima <- getWU(stations = 'SBRJ', var="tmin")
#'cas = getCases(city = c(330455), withdivision = FALSE)
#'casfit<-adjustIncidence(obj=cas)
#'casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'d<- mergedata(cases = casr, tweet = tw, climate = clima)
#'crity <- c("tmin > 22", 3, 3)
#'crito <- c("p1 > 0.9", 3, 0)
#'critr <- c("inc > 100", 3, 0)
#'alerta <- fouralert(d, cy = crity, co = crito, cr = critr, pop=1000000)
#'plot.alerta(alerta, "casos")

fouralert <- function(obj, cy, co, cr, pop){
      le <- dim(obj)[1]
      
      # calculate incidence
      if("tcasesmed" %in% names(obj)){
            obj$inc <- obj$tcasesmed / pop * 100000      
      } else{
            obj$inc <- obj$casos / pop * 100000      
      }
      
      # accumulating condition function
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      
      # data.frame to store results
      indices <- data.frame(cytrue = rep(NA,le), nytrue = rep(NA,le),
                            cotrue = rep(NA,le), notrue = rep(NA,le),
                            crtrue = rep(NA,le), nrtrue = rep(NA,le)
                            )
      
      # calculating each condition (week and accumulated)  
      
      assertcondition <- function(dd, cond){
            condtrue <- with(dd, as.numeric(eval(parse(text = cond[1]))))
            ncondtrue <- with(dd, accumcond(condtrue, as.numeric(cond[2])))
            cbind(condtrue, ncondtrue)
      }
      
      indices[,c("cytrue", "nytrue")] <- assertcondition(obj , cy)
      indices[,c("cotrue", "notrue")] <- assertcondition(obj , co)
      indices[,c("crtrue", "nrtrue")] <- assertcondition(obj, cr)
            
      # setting the level
      indices$level <- 1
      indices$level[indices$nytrue == as.numeric(cy[2])] <-2
      indices$level[indices$notrue == as.numeric(co[2])] <-3
      indices$level[indices$nrtrue == as.numeric(cr[2])] <-4

      # delay turnoff
      delayturnoff <- function(cond, level, d=indices){
            delay = as.numeric(as.character(cond[3]))
            if(delay > 0){
                  cand <- c()
                  for(i in 1:delay){
                        cand <- c(cand, which(d$level==level) + i)
                  }
                  for (j in cand){
                        d$level[j] <- max(d$level[j], level)
                  }
            }
            d
      } 
      indices <- delayturnoff(cond=cr,level=4)
      indices <- delayturnoff(cond=co,level=3)
      indices <- delayturnoff(cond=cy,level=2)
      

      return(list(data=obj, indices=indices, rules=paste("cy", ";", "co", ";",
                                                         "cr"),n = 4))      
}


#plot.alert --------------------------------------------------------------------
#'@title Plot the time series of warnings.
#'@description Function to plot the output of 
#'@param obj object created by the twoalert and fouralert functions.
#'@param var to be ploted in the graph, usually cases when available.  
#'@param cores colors corresponding to the levels 1, 2, 3, 4.
#'@return a plot
#'@examples
#'tw <- getTweet(city = c(330455), lastday = "2014-03-10")
#'clima <- getWU(stations = 'SBRJ', var="tmin", finalday = "2014-03-10")
#'d<- mergedata(tweet = tw, climate = clima)
#'critgy <- c("tmin > 22 | tweet > 10", 3)
#'crityg <- c("tmin <= 22 & tweet <= 10", 3)
#'alerta <- twoalert(d, gy = critgy, yg = crityg)
#'plot.alerta(alerta, "tmin")



plot.alerta<-function(obj, var, cores = c("#0D6B0D","#C8D20F","orange","red")){
      
      stopifnot(names(obj) == c("data", "indices", "rules","n"))
      stopifnot(var %in% names(obj$data))
            
      par(mai=c(0,0,0,0),mar=c(4,4,1,1))
      x <- 1:length(obj$data$SE)
      ticks <- seq(1, length(obj$data$SE), length.out = 8)
      
      if (obj$n == 2 | obj$n == 4){
            plot(x, obj$data[,var], xlab = "SE", ylab = var, type="l", axes=FALSE)
            axis(2)
            axis(1, at = ticks, labels = obj$data$SE[ticks], las=3)
            for (i in 1:obj$n) {
                  onde <- which(obj$indices$level==i) 
                  if (length(onde))
                        segments(x[onde],0,x[onde],(obj$data[onde,var]),col=cores[i],lwd=3)
            }
            
            }
}
      
      
            

#isOrange --------------------------------------------------------------------
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
#'resfit <- adjustIncidence(obj = res)
#'rtnorm<-Rt(obj = res, count = "casos", gtdist="normal", meangt=3, sdgt = 1)
#'ora = isOrange(obj = rtnorm, pvalue = 0.9, lag= 3) 
#'head(ora)
#'x = 1:length(ora$SE)
#'plot(x, ora$Rt, type="l", xlab= "weeks", ylab = "Rt")
#'lines(x, ora$upr, lty = 3)
#'lines(x, ora$lwr, lty = 3)
#'abline(h = 1, col =2)
#'points(x[ora$oweek==1], ora$Rt[ora$oweek==1], col="orange", pch=16)

isOrange <- function(obj, pvalue = 0.9, lag=3){
  
  if(!("p1" %in% names(obj))) stop("obj must be created by an Rt function")
  
  obj$oweek <- as.numeric(obj$p1 > pvalue)
  
  # lag weeks accumulated condition
  le <- dim(obj)[1]
  ac <- obj$oweek[lag:le]
  for(i in 1:(lag-1)) ac <- ac+obj$oweek[(lag-i):(le-i)]
  obj$oacc <- c(rep(NA,(lag-1)),ac)
  
  return(obj)
}


#isRed --------------------------------------------------------------------
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
#'resd = casesinlocality(res, "AP1") # Rio de Janeiro
#'resfit<-adjustIncidence(resd)
#'red = isRed(resfit, pop = 30000, ccrit = 10, lag=3)
#'x = 1:length(red$SE)
#'plot(x, red$inc, type="l", xlab= "weeks", ylab = "incidence")
#'abline(h = 10, col =2)
#'points(x[red$rweek==1], red$inc[red$rweek==1], col="red", pch=16)

isRed <- function(obj, pop, ccrit=100, lag=3){
  
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



