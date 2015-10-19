# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo de Rt
# Claudia Codeco 2015
# -----------------------------------------------------------



#Rtoriginal -----------------------------------------------------------------------
#'@description Calculates the effective reproductive number from the growth rate 
#'of cases. The The original formulation is simply the ratio between 3-weeks accumulated
#'cases at week (t+1) and the 3-weeks accumulated cases at week t. 
#'@title Computes the effective reproductive number using a Alerta's original formulation.
#'@param y time series of cases.
#'@param se time series of epidemiological weeks (not required).  
#'@param meangt the exact period between primary and secondary infections
#'@param CI Model used to compute the confidence interval. "beta" is the only choice.
#'@return data.frame with estimated Rt and confidence intervals
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#' # Rt original
#'rt<-Rtoriginal(y = res$casos, se = res$SE, meangt=3)
#'tail(rt)
#'plot(rt$Rt, type="l", xlab = "weeks", ylab = "Rt")
#'lines(rt$lwr,lty=3)
#'lines(rt$upr,lty=3)
#'abline(h = 1, col = 2)
#' # Rt delta and normal
#'rtdelta<-Rt(y = res$casos, se = res$SE, gtdist="delta", meangt=3)
#'rtnorm<-Rt(y = res$casos, se = res$SE, gtdist="normal", meangt=3, sdgt = 1)
#'lines(rtdelta$Rt, col = 3)
#'lines(rtdelta$lwr,lty = 3, col = 3)
#'lines(rtdelta$upr,lty = 3, col = 3)
#'lines(rtnorm$Rt, col = 4)
#'lines(rtnorm$lwr,lty = 3, col = 4)
#'lines(rtnorm$upr,lty = 3, col = 4)
#'legend(30,3,c("original","delta","normal"),lty=1, col = c(1,3,4), cex = 0.7)


Rtoriginal<-function(y, se = c(), meangt, CI = "beta", alpha = .95, a0 = 2 , b0 = 3){  
  le <- length(y)
  if (le < 2*meangt) warning("you need a time series                           
                             with size at least 2 generation intervals to estimate Rt")
  
  res <- data.frame (SE = se, cases = y, Rt = rep(NA, le), p1 = rep(NA, le), 
                     lwr = rep(NA, le), upr = rep(NA, le) )
    
    message("Rtoriginal is deprecated. Consider using Rtnormal or Rtdelta.")
    ac <- y[meangt:le]
    for(i in 1:(meangt-1)) ac <- ac+y[(meangt-i):(le-i)]    
    mle<-length(ac)
    #res$Rt[(meangt+1):le]<-ac[2:mle]/ac[1:(mle-1)]    
    
    # CI (using Luis Max funtion)
    K <- length(ac)
    jk1 <- ac[2:K] # J[k+1] 
    jk  <- ac[1:(K-1)]# J[k]  
    res$Rt[(meangt + 1):le] <- jk1/jk
    ## p1 = Pr(R>1) 
  if (CI == "beta"){
    for( k in 1: (le-meangt)){
      res$p1[k+meangt] <- 1 - pbeta(.5, shape1 = jk1[k], shape2 = jk[k])
      res[k+meangt, 5:6] <- ll(betaconf(alpha = alpha, x = jk1[k], 
                                    n = jk1[k] + jk[k], a = a0, b = b0 ))
      
  }
  }
    res
}


##################
#'@description Calculates the effective reproductive number from the growth rate 
#'of cases. Uses formula 4.2 in Wallinga and Lispitch (2007). Confidence interval assume
#'ratio between two Poissons (see Luis Max documentation). 
#'@title Computes the effective reproductive number using alternative 
#'distributions for the generation interval.
#'@param y time series of cases.
#'@param se time series of epidemiological weeks (not required).  
#'@param meangt if gtdist = "delta" it is the exact period between primary and 
#'secondary infections). If gtdist = "normal", it is the mean generation time.
#'@param sdgt if gtdist = "normal", it is the standard deviation of the generation time 
#'distribution.
#'@param CI Model used to compute the confidence interval. Possible choice: "beta". 
#'  
#'@return data.frame with estimated Rt and confidence intervals. 
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#' # Rt original
#'rt<-Rtoriginal(y = res$casos, se = res$SE, meangt=3)
#'tail(rt)
#'plot(rt$Rt, type="l", xlab = "weeks", ylab = "Rt")
#'lines(rt$lwr,lty=3)
#'lines(rt$upr,lty=3)
#'abline(h = 1, col = 2)
#' # Rt delta and normal
#'rtdelta<-Rt(y = res$casos, se = res$SE, gtdist="delta", meangt=3)
#'rtnorm<-Rt(y = res$casos, se = res$SE, gtdist="normal", meangt=3, sdgt = 1)
#'lines(rtdelta$Rt, col = 3)
#'lines(rtdelta$lwr,lty = 3, col = 3)
#'lines(rtdelta$upr,lty = 3, col = 3)
#'lines(rtnorm$Rt, col = 4)
#'lines(rtnorm$lwr,lty = 3, col = 4)
#'lines(rtnorm$upr,lty = 3, col = 4)
#'legend(30,3,c("original","delta","normal"),lty=1, col = c(1,3,4), cex = 0.7)

Rt<-function(y, se, gtdist, meangt, sdgt, CI = "beta", alpha = .95, a0 = 2 , b0 = 3){  
  le <- length(y)
  if (le < 2*meangt) warning("you need a time series                           
                             with size at least 2 generation intervals to estimate Rt")
  
  res <- data.frame (SE = se, cases = y, Rt = rep(NA, le), p1 = rep(NA, le), 
                     lwr = rep(NA, le), upr = rep(NA, le) )
  if (gtdist == "normal") ga <- rev(dnorm(x = 1:le, mean = meangt, sd = sdgt))
  if (gtdist == "delta")  {
    ga <- rep(0, le)
    ga [le - meangt] <- 1
  }
  
  for (t in ceiling(2*meangt):le){
    num = y[t]
    deno = sum(y[1:t] * ga[(le-t+1):le]) # equation 4.1 in Wallinga and Lipsitch 2007
    res$Rt[t]<-num/deno
    if (CI == "beta"){
       res$p1[t] <- 1 - pbeta(.5, shape1 = num, shape2 = deno)
       res[t, 5:6] <- ll(betaconf(alpha = alpha, x = num, 
                               n = num + deno, a = a0, b = b0 ))
    }
  }
  
  res
}


## obtain 100\lapha confidence/credibility intervals for the success probability \theta
betaconf <- function(alpha = .95, x, n, a = 1, b = 1, CP = "FALSE"){
  if(CP=="TRUE"){  
    lower <- 1 - qbeta((1-alpha)/2, n + x - 1, x)
    upper <- 1 - qbeta((1+alpha)/2, n - x, x + 1)
  }else{
    lower <- qbeta( (1-alpha)/2, a + x, b + n - x)
    upper <- qbeta(( 1+alpha)/2, a + x, b + n - x)  
  } 
  return(c(lower, upper))
  #CP stands for Clopper-Pearson
  #Default is 'Bayesian' with an uniform prior over p (a=b=1)
}


# R = theta/(1-theta)
ll <- function(x) x/(1-x)

