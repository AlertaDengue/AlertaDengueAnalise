# Função que identifica ponto de corte de variavel continua que maximiza a acuracia da deteccao do alerta
  
#Retorna o cutoff da variavel continua que maximiza a acuracia. Posteriormente adaptar para outro criterio.
# Usa funcoes da biblioteca ROCR

require("ROCR")

define.cutoff <- function(cont,categ){
  # nao pode ter NA. Define cutoff que maximiza acuracia
  pred <- prediction(predictions = cont, labels = categ)
  perf <- performance(pred, "acc")
  maxacc <- max(perf@y.values[[1]])
  par(mfrow=c(2,2),mar=c(3,3,1,1))
  plot(perf,main="acc")
  cutoff <- perf@x.values[[1]][which(perf@y.values[[1]] == maxacc[1])]
  abline(v = cutoff)
  # plotando outros indices de performance
  plot(performance(pred, "sens"),main="sens")
  abline(v = cutoff)
  plot(performance(pred, "spec"),main="spec")
  abline(v = cutoff)
  plot(performance(pred, "ppv"),main="ppv")
  abline(v = cutoff)      
  res=cutoff
