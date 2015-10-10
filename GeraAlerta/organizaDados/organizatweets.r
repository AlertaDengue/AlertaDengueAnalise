#Organização dos dados do tweet RJ
#===================================
#Concatena os dados mais recentes com a serie historica. Sao precisos 3 dados de entrada:
#- serie historica em semanas (a mais atualizada que tiver)
#- serie de tweets recem-recebidos, diarios

source("fun/data2SE.r")
source("fun/concatweet.r")

#Serie historica de tweets por semana (2010-2013)
dant<-read.csv("dados_limpos/tweets_week_2010-2013.csv")

#Serie de 2014 de tweets diarios
comando<-paste("fun/pega_tweets.py -i 2014-01-05 -f ",Sys.Date(),410480) # primeira SE de 2014 ate hoje
system(comando)
d<-read.csv("tweets_teste.csv",header=TRUE)[,c("data","X330455")]
names(d)[2]<-"rio"

message("ultimos tweets:")
print(tail(d,n=7))

# Acrescentar informacao de semana epidemiologica
d$SE<-data2SE(d$data,file="tabelas/SE.csv",format="%Y-%m-%d")   

#Concatenacao
# Concatenar as series diarias, preenchendo com NA, se necessario.
ult<-sum(d$SE==max(d$SE))
pri<-sum(d$SE==min(d$SE))

#Tweets/semana
dsem<-aggregate(d$rio,by=list(SE=d$SE),FUN=sum,na.rm=TRUE)
names(dsem)[2]<-"tweets"
if (ult<7) dsem<-dsem[-(dim(dsem)[1]),]
if (pri<7) dsem<-dsem[-1,]

twRJ <- rbind(dant[,2:3],dsem)

#plot(twRJ$SE,twRJ$tweets,ylab="tweets",xlab="semana",main="Serie temporal completa 2010-2014")

#Salvar

message("tweets salvos em dados_limpos/tweetsemanaRJ.csv")
write.table(twRJ,file="dados_limpos/tweetsemanaRJ.csv",sep=",",row.names=FALSE)


