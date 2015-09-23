############################################################
## Funcao para corrigir casos devido a atraso de notificacao
############################################################

# A ideia e corrigir pelo atraso de digitacao. Analise preliminar (ver pasta analise)
# sugere que em 2013 e 2014, a curva de sobrevivencia de tempo ate digitar seguiu uma distr lognormal
# com parametros default da funcao corrigecasos.

corrigecasos<-function(casos,dist="lognormal",pars=list(meanlog = 2.5016,sdlog=1.1013)){
  le = length(casos)
  p = rep(1,le)
  
  if (dist=="lognormal") {
    pdig = rev(plnorm(seq(7,210,by=7),pars$meanlog,pars$sdlog))}
  p[(le-length(pdig)+1):le]<-pdig
  casos/p
}

# USO
#st$casosm<-corrigecasos(st$casos)
#tail(st)
#plot(st$casos[232:262],type="l")
#lines(st$casosm[232:262],col=2)

# versao 2 - com intervalo de predicao

corrigecasosIC<-function(casos,dist="lognormal",meanlog = 2.5016,sdlog=1.1013){
  le = length(casos)
  p = rep(1,le)
  
  d<-data.frame(casos=casos)
  
  if (dist=="lognormal") pdig = rev(plnorm((1:10)*7,meanlog,sdlog)) # prop digitado
  p[(le-length(pdig)+1):le]<-pdig
  d$p <- p
  d$lambda=(d$casos/p)-d$casos # lambda = apenas a parte nao conhecida e'estocastica (por isso desconto casos aq) 
  corr <- function(lamb,n=100) sort(rpois(n,lambda=lamb))[c(10,50,90)] # calcula 95% IC e mediana estimada da parte estocastica 
  
  d$casosICmin <- NA
  d$casosMedian <- NA
  d$casosICmax <- NA
  
  for(i in 1:length(casos)) d[i,4:6] <- corr(lamb=d$lambda[i])+d$casos[i]
  
  d
}

# USO
#casosm<-corrigecasosIC(st$casos)
#tail(casosm,n=10)
#plot(casosm$casos[250:262],type="l")
#lines(casosm$casosMedian[250:262],col=2)
#lines(casosm$casosICmin[250:262],col=3)
#lines(casosm$casosICmax[250:262],col=3)
