########################################################################
### Funcoes auxiliadoras para formatacao dados de clima do Alerta dengue


#================
# Funcao data2SE
#================

# Determina Semana Epidemiologica associada a uma data. 
# USO: data2SE("03-04-2013",format="%d-%m-%Y")
# data2SE(c("03-04-2013","07-01-2014"),format="%d-%m-%Y")

data2SE<-function(data,file="SE.csv",format="%d/%m/%Y"){
  SE=rep(NA,length(data))      
  arq<-read.csv(file)
  arq$Inicio<-as.Date(arq$Inicio,format="%d/%m/%Y")
  arq$Termino<-as.Date(arq$Termino,format="%d/%m/%Y")
  dia<-as.Date(as.character(data),format=format)
  for (i in 1:length(data)) {
      week <- arq$SE[dia[i] >= arq$Inicio & dia[i] <= arq$Termino]
      ano <-  arq$Ano[dia[i] >= arq$Inicio & dia[i] <= arq$Termino] 
      se = ano*100+week
      SE[i]<-ifelse(length(SE)==0,NA,se)      
      }
  SE
}



