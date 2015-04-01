# Organiza dados de temperatura do Alerta dengue 
#===============================================

# Tem duas funcoes implementadas, de coleta do OpenWeather ou do WundergroundWeather

source("fun/data2SE.r")

fonte = "Wunder"

if (fonte == "OpenWeather"){
  #Abre dados OpenWeather (autor: Oswaldo), so tem galeao  
  d<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")
  d$estacao <- "galeao"
  #Incluir variavel semana epidemiologica
  d$SE<-data2SE(d$data,file="tabelas/SE.csv",format="%Y-%m-%d")
  #Acumular por SE e estacao
  df<-aggregate(d[,3:10],by=list(estacao=d$estacao,SE=d$SE),FUN=mean,na.rm=TRUE)
  message("ultimos dados de clima")
  print(tail(df,n=7))  
}


if(fonte == "Wunder"){
  #Abre dados weather underground (autor: Flavio)
  
  # Captura os dados para o mongo
  dom = Sys.Date()-1  # ultimo domingo
  dom1 = dom-50
  system(paste("fun/clima.py -i", dom1,"-f ",dom, "-c SBRJ"))
  system(paste("fun/clima.py -i", dom1," -f",dom, " -c SBJR"))
  system(paste("fun/clima.py -i", dom1," -f",dom, " -c SBAF"))
  system(paste("fun/clima.py -i", dom1," -f",dom, " -c SBGL"))
  
  # organiza os dados
  gal<-callmongoclima("galeao") 
  message("ultimos dados de clima do galeao")
  print(tail(gal,n=7))
  std <- callmongoclima("santosdumont")
  message("ultimos dados de clima do santos dumont")
  print(tail(std,n=7))
  afo <- callmongoclima("afonsos")
  message("ultimos dados de clima do c afonsos")
  print(tail(afo,n=7))
  jac <- callmongoclima("jacarepagua")
  message("ultimos dados de clima do a. jacarepagua")
  print(tail(jac,n=7))
  d<- rbind(gal,std,afo,jac)
  rm(gal,std,afo,jac)
  # Atribuir SE
  d$SE<-data2SE(d$data,file="tabelas/SE.csv",format="%Y-%m-%d")
  
  # Agregar por semana
  n = dim(d)[2]-1
  df<-aggregate(d[,2:n],by=list(SE=d$SE,estacao=d$estacao),FUN=mean,na.rm=TRUE)
}


# Atribuir aas APSs

listaAPS<-c("AP1","AP2.1","AP2.2","AP3.1","AP3.2","AP3.3","AP4","AP5.1","AP5.2","AP5.3")
if(fonte == "Wunder"){
  dAP<-cbind(APS="AP1",df[df$estacao=="santosdumont",])
  dAP<-rbind(dAP,cbind(APS="AP2.1",df[df$estacao=="santosdumont",]))
  dAP<-rbind(dAP,cbind(APS="AP2.2",df[df$estacao=="santosdumont",]))
  dAP<-rbind(dAP,cbind(APS="AP3.1",df[df$estacao=="galeao",]))
  dAP<-rbind(dAP,cbind(APS="AP3.2",df[df$estacao=="galeao",]))
  dAP<-rbind(dAP,cbind(APS="AP3.3",df[df$estacao=="galeao",]))
  dAP<-rbind(dAP,cbind(APS="AP4",df[df$estacao=="jacarepagua",]))
  dAP<-rbind(dAP,cbind(APS="AP5.1",df[df$estacao=="afonsos",]))
  dAP<-rbind(dAP,cbind(APS="AP5.2",df[df$estacao=="afonsos",]))
  dAP<-rbind(dAP,cbind(APS="AP5.3",df[df$estacao=="afonsos",]))  
}


#Salvar:
  
message("clima salvo em /dados_limpos/climasemanaRJ.csv")

write.table(dAP,file="dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
