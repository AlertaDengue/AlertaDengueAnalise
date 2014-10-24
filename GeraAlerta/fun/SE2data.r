########################################################################
### Funcoes auxiliadoras para formatacao dados de clima do Alerta dengue


#================
# Funcao SE2data
#================

# Determina data associada à semana epidemiologica. 
# USO: SE2data(201401)
# SE2data(c(201401,201402))

SE2data<-function(SE,file="SE.csv"){
  arq<-read.csv(file)
  arq$Inicio<-as.Date(arq$Inicio,format="%d/%m/%Y")
  arq$Termino<-as.Date(arq$Termino,format="%d/%m/%Y")
  
  SEano <- trunc(SE/100)
  SEsem <- SE - SEano*100 
  
  
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



