# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de correcao dos dados de notificacao
# Claudia Codeco 2015
# -----------------------------------------------------------


# adjustIncidence ---------------------------------------------------------------------
#'@description Often, there is a delay between symptom onset and notification. This function 
#'adjust the time series of reported cases by adding the cases that will be reported in the future.
#'It requires knowing the probability of notification per week passed. This function assumes a stationary
#'notification process, there is, no influence of covariates or any temporal inhomogeneity.   
#'@title Adjust incidence data correcting for the notification delay.
#'@param obj data.frame with crude weekly cases (not adjusted). This data.frame comes from the getCases
#' function (if withdivision = FALSE), of getCases followed by casesinlocality (if dataframe is available
#' per bairro)  
#'@param pdig vector of probability of been typed in the database up to 1, 2, 3, n, weeks after symptoms onset.
#'The length of the vector corresponds to the maximum delay. After day, it is assumed that p = 1. The default
#'was obtained from Rio de Janeiro. 
#'@return data.frame with pdig (proportion reported), median and 95percent confidence interval for the 
#'predicted cases-to-be-notified)
#'@examples
#'res = getCases(city = c(330455), withdivision = FALSE) # Rio de Janeiro
#'head(res)
#'resfit<-adjustIncidence(obj=res)
#'tail(resfit)
#'plot(tail(resfit$casos,n=30),type="l",ylab="cases",xlab="weeks")
#'lines(tail(resfit$tcasesmed,n=30),col=2)
#'lines(tail(resfit$tcasesmin,n=30),col=2,lty=3)
#'lines(tail(resfit$tcasesmax,n=30),col=2,lty=3)
#'legend(12,20,c("notified cases","+ to be notified cases"),lty=1, col=c(1,2),cex=0.7)

adjustIncidence<-function(obj, pdig = plnorm((1:20)*7, 2.5016, 1.1013)){
  le = length(obj$casos) 
  lse = length(obj$SE) 
  
  # creating the proportion vector
  lp <- length(pdig)
  
  if(le > lp) {obj$pdig <- c(rep(1, times = (le - lp)), rev(pdig))
  } else if (le == lp) {obj$pdig <- rev(pdig)
  } else obj$pdig <- rev(pdig)[1:le]
  
  lambda <- (obj$casos/obj$pdig) - obj$casos   
  corr <- function(lamb,n=500) sort(rpois(n,lambda=lamb))[c(02,50,97)] # calcula 95% IC e mediana estimada da parte estocastica 
  
  obj$tcasesICmin <- NA
  obj$tcasesmed <- NA
  obj$tcasesICmax <- NA
  
  for(i in 1:length(obj$casos)) obj[i,c("tcasesICmin","tcasesmed","tcasesICmax")] <- corr(lamb = lambda[i]) + obj$casos[i]
  
  obj
}

