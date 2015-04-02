# funcao para criar tabela de semana epidemiologica

library(lubridate)

ini<-as.Date("04/01/2015",format="%d/%m/%Y") 
dd<-seq(0,727,by=7)
inis <- ini+dd
fins <- inis+6
init <- as.character(inis,format="%d/%m/%Y")
fimt<- as.character(fins,format="%d/%m/%Y")

se <- data.frame(ano=year(inis),sem=rep(1:52,2),ini=init,fim=fimt)
write.csv(se,file="SE2015-16.csv",row.names=FALSE,quote=FALSE)
