# Funcao Rt

#Retorna Rt, usando tempo de geracao tg=3 


Rt<-function(d,tg=3){  # tg = tempo de geracao
  le <- length(d)
  ac <- d[tg:le]
  for(i in 1:(tg-1)) ac <- ac+d[(tg-i):(le-i)]  
  Rt<-NA
  mle<-length(ac)
  Rt[(tg+1):le]<-ac[2:mle]/ac[1:(mle-1)]
  Rt
}
