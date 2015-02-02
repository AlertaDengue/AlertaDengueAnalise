############################################################
## Funcao para corrigir casos devido a atraso de notificacao
############################################################

#  A ideia e'fazer alguma forma de backcalculation. Por enquanto, a 
# mais trivial. Uma analise exploratoria dos dados sugere que a probabilidade de um caso 
# notificado ser digitado na primeira, segunda, terceira, etc, semana apos a notificacao é
# pdig.

corrigecasos<-function(casos){
  le = length(casos)
  p = rep(1,le)
  pdig = rev(c(0.317,0.531,0.652,0.7379,0.795,0.836,0.8669,0.888,0.903,0.915,0.925,0.935,0.943,0.951,0.958,0.965,0.972,0.978,0.9822))
  p[(le-length(pdig)+1):le]<-pdig
  casos/p
}
