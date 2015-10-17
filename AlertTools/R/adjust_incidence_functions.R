# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de correcao dos dados de notificacao
# Claudia Codeco 2015
# -----------------------------------------------------------


# adjustIncidence ---------------------------------------------------------------------
#'@description Often, there is a delay between symptom onset and notification. This function 
#'adjust the time series of reported cases adding the cases that will be reported in the future.
#'A function describing the proportion known as a function of time passed is required.  
#'@title Adjust incidence data correcting for the notification delay.
#'@param y time series of cases to be adjusted.
#'@param dist function describing the proportion reported as a function of time passed. 
#'Currently only the accumulated lognormal function is implemented .
#'@param meanlog mean of the lognormal function.
#'@param meanlog sdev of the lognormal function.
#'@param prop alternatively, a vector with the proportion typed per week (not implemented yet).
#'@return data.frame with p (proportion reported), lambda ( expected numbero f cases not yet reported),
#'inc (expected true number of cases to be reported) incICmin and incICmax (95percent confidence interval for the true incidence)
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'head(res)
#'resfit<-adjustIncidence(se = res$SE, y = res$casos)
#'tail(resfit)
#'plot(tail(resfit$casos,n=30),type="l",ylab="cases",xlab="weeks")
#'lines(tail(resfit$tcasesmed,n=30),col=2)
#'lines(tail(resfit$tcasesmin,n=30),col=2,lty=3)
#'lines(tail(resfit$tcasesmax,n=30),col=2,lty=3)
#'legend(12,20,c("notified cases","+ to be notified cases"),lty=1, col=c(1,2),cex=0.7)

adjustIncidence<-function(se, y, dist="lognormal", meanlog = 2.5016, sdlog=1.1013, prop){
  le = length(y) # cases
  lse = length(se) # weeks
  if (lse != le) warning("se and y sizes differ")
  
  # checking the difference between last se and last update.  
  maxse = max(se)
  p = rep(1,le)
  
  d<-data.frame(SE = se, casos = y)
  
  if (dist == "lognormal") pdig = rev(plnorm((1:20)*7, meanlog, sdlog)) # prop typed per week
  p[(le - length(pdig) + 1):le] <- pdig
  d$p <- p
  lambda <- (d$casos/d$p) - d$casos   
  corr <- function(lamb,n=500) sort(rpois(n,lambda=lamb))[c(02,50,97)] # calcula 95% IC e mediana estimada da parte estocastica 
  
  d$tcasesICmin <- NA
  d$tcasesmed <- NA
  d$tcasesICmax <- NA
  
  for(i in 1:length(d$casos)) d[i,4:6] <- corr(lamb = lambda[i]) + d$casos[i]
  
  d
}
