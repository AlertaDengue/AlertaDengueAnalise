# Junta todos os dados para analise 
#=====================================

source("fun/data2SE.r")

st.ap<-read.csv("dados_limpos/sinansemanaAP_RJ.csv") # prob
tw<-read.csv("dados_limpos/tweetsemanaRJ.csv")
tempAP <- read.csv("dados_limpos/climasemanaRJ.csv")

listaAPS<-unique(st.ap$APS)
# sinan + temperatura
Rt.ap<-merge(st.ap,tempAP,by=c(SE="SE",APS="APS"),all=TRUE)
# + tweets
yi<-merge(tw,Rt.ap[Rt.ap$APS==listaAPS[1],],by=c("SE"),all=TRUE)
yi$APS<-listaAPS[1]
for (i in 2:10) {
      y<- merge(tw,Rt.ap[Rt.ap$APS==listaAPS[i],],by=c("SE"),all=TRUE)
      y$APS<-listaAPS[i]
      yi<-rbind(yi,y)
      }
Rt.ap <- yi
rm(yi)

Rt.ap <- subset(Rt.ap,SE<=SEvez)
message("dados completos para analise")
print(tail(Rt.ap,n=7))

outputfile = paste("dados_limpos/dadosAPS_",max(Rt.ap$SE),".csv",sep="")
message("dados completos salvos em ",outputfile)

write.table(Rt.ap,file=outputfile,row.names=FALSE,sep=",")
 
