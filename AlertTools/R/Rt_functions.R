# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo de Rt
# Claudia Codeco 2015
# -----------------------------------------------------------



#calcRt -----------------------------------------------------------------------
#'@description Calculates the effective reproductive number from the growth rate 
#'of cases. The expressions proposed by Wallinga and Lipsitch (2007) are implemented.   
#'Moreover, a expression specifically derived for dengue is also available (add reference).
#'@title Calculates the effective reproductive number.
#'@param y time series of cases.
#'@param gtdist generation time distribution. Functions implemented: "delta", "normal",
#' and "dengue".  
#'@param meangt if gtdist = "delta" it is the exact period between primary and 
#'secondary infections). If gtdist = "normal", it is the mean generation time.
#'@param sdgt if gtdist = "normal", it is the standard deviation of the generation time 
#'distribution.
#'@param CI Model used to compute the confidence interval. Possible choices: "beta", 
#'"gamma", or "none"  
#'@return data.frame with 
#'@examples
#'res = getCases(city = c(330455), withdivision = TRUE) # Rio de Janeiro
#'res$Rt<-calcRt(res$casos, gtdist="original",meangt=3)
#'res$Rtd<-calcRt(res$casos, gtdist="delta",meangt=3)
#'res$Rtn<-calcRt(res$casos, gtdist="normal",meangt=3,sdgt = 1)
#'tail(res)
#'plot(tail(res$Rt,n=100),type="l",xlab = "weeks", ylab = "Rt",ylim=c(0,3))
#'lines(tail(res$Rtd,n=100),col=2)
#'lines(tail(res$Rtn,n=100),col=3)
#'legend(45,3,c("original","delta","normal"),lty=1,col=1:3,cex=0.7)

calcRt<-function(y, gtdist, meangt, sdgt, CI="none"){  
  le <- length(y)
  if (le < 2*meangt) warning("you need a time series                           
                             with at least 2 generation intervals to estimate Rt")
  
  Rt <- NA
  
  if (gtdist == "original"){
    ac <- y[meangt:le]
    for(i in 1:(meangt-1)) ac <- ac+y[(meangt-i):(le-i)]    
    mle<-length(ac)
    Rt[(meangt+1):le]<-ac[2:mle]/ac[1:(mle-1)]    
  }
  
  if (gtdist == "normal") ga <- rev(dnorm(x = 1:le, mean = meangt, sd = sdgt))
  if (gtdist == "delta")  {
    ga <- rep(0, le)
    ga [le - meangt] <- 1
  }
  
  if (gtdist == "normal" | gtdist == "delta"){
    for (t in ceiling(2*meangt):le){
      num = y[t]
      deno = sum(y[1:t] * ga[(le-t+1):le]) # equation 4.1 in Wallinga and Lipsitch 2007
      Rt[t]<-num/deno
    }
  }
  # Falta calcular o IC do Rt
  Rt
}



