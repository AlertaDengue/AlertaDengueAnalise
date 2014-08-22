# Funcao Acuracia 
# Considere duas variaveis categoricas, uma verdadeira, a outra estimada. 
# Calcula a sensibilidade,especificidade e acuracia da variavel estimada 
# em indicar a verdadeira. Para ser usado na validacao de indicador de alerta.

# USO: acuracia(real=alertareal, est=alertapredito)

acuracia <- function(real,est){
  tab<-table(real=real,est=est)
  TP = tab[2,2]  # true positive
  TN = tab[1,1]  # true negative
  FP = tab[1,2]  # false positive
  FN = tab[2,1]  # false negative
  Tot = sum(tab) # total
  acuracia = (TP+TN)/Tot 
  sens=TP/(TP+FN)
  esp = TN/(TN+FP)
  res=list(tab=tab,acc=acuracia,sens=sens,esp=esp)
  rbind(acc=res$acc,sens=res$sens,esp=res$esp)
} 
