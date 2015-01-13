############################################################
## Funcao para corrigir casos devido a atraso de notificacao
############################################################

# A ideia e corrigir pelo atraso de digitacao. Analise preliminar (ver pasta analise)
# sugere que em 2013 e 2014, a curva de sobrevivencia de tempo ate digitar seguiu uma distr lognormal
# com parametros default da funcao corrigecasos.

corrigecasos<-function(casos,dist="lognormal",pars=list(meanlog = 2.5016397,sdlog = 1.101342)){
  le = length(casos)
  p = rep(1,le)
  #pdig = rev(c(0.317,0.531,0.652,0.7379,0.795,0.836,0.8669,0.888,0.903,0.915,0.925,0.935,0.943,0.951,0.958,0.965,0.972,0.978,0.9822))
  if (dist=="lognormal") pdig = rev(plnorm(seq(7,210,by=7),meanlog,sdlog))
  p[(le-length(pdig)+1):le]<-pdig
  casos/p
}

# USO
st$casosm<-corrigecasos(st$casos)
tail(st)
plot(st$casos[232:262],type="l")
lines(st$casosm[232:262],col=2)
