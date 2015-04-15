#Figuras
source("../fun/corrigecasos.r")
d <- read.csv(file="../dados_limpos/dadosAPS_201513.csv")

names(d)

# dados de tweet
st <- aggregate(d$casos,by=list(SE=d$SE),FUN=sum)
names(st)<-c("SE","casos")
st$SE<-as.numeric(as.character(st$SE))
tw <- aggregate(d$tweets,by=list(SE=d$SE),FUN=unique)
names(tw)<-c("SE","tweets")
tw$SE<-as.numeric(as.character(tw$SE))

par(mfrow=c(1,1))
plot(st$casos,type="l",main="",axes=FALSE,ylab="contagem",xlab="semana")
lines(tw$tweets,col=2)
axis(2)
axis(1)
legend(200,8000,c("tweets","casos"),lty=1,col=c(2,1))

# dados de clima

cl <- aggregate(d$tmin,by=list(SE=d$SE,estacao=d$estacao),FUN=unique)
names(cl)<-c("SE","estacao","tmin")
cl$SE<-as.numeric(as.character(cl$SE))

par(mfrow=c(1,1),mar=c(5,4,4,6))
plot(st$casos,type="l",main="",axes=FALSE,ylab="dengue",xlab="semana",ylim=c(0,9000))
lines(cl$tmin[cl$estacao=="santosdumont"]*300,col=2)
lines(cl$tmin[cl$estacao=="afonsos"]*300,col=3)
lines(cl$tmin[cl$estacao=="jacarepagua"]*300,col=4)
lines(cl$tmin[cl$estacao=="galeao"]*300,col=5)
axis(2)
axis(1)
legend(200,3000,c("casos na cidade","tmin-Santos Dumont","tmin-Afonsos"
                  ,"tmin-Jacarepagua","tmin-galeao"),lty=1,col=c(1,2,3,4,5),
       cex=0.7)
axis(4,at=c(4500,6000,7500,9000),labels=c(15,20,25,30))
mtext(text = "Temp min",side = 4,line = 2,at = 7000)


# dados de dengue por APS
listaAPS <- unique(d$APS)
plot(d$casos[d$APS=="AP1"],type="l",ylab="casos por APS",xlab="semana",ylim=range(d$casos))
for (i in 2:10) lines(d$casos[d$APS==listaAPS[i]],col=i)

d$casosm<-NA
for(i in 1:10) d$casosm[d$APS==listaAPS[i]] <-corrigecasos(d$casos[d$APS==listaAPS[i]])

# Rt dengue e casos
source("../fun/Rt.r")
# data.frame para colocar os resultados
SE<-d$SE[d$APS=="AP1"]
d2 <- expand.grid(SE=SE,APS=listaAPS)
d2<-merge(d2,d[,c("SE","APS","data","tweets","estacao","casosm","casos","tmin")],by=c("SE","APS"))
d2$Rtw <-NA  # Rt do tweet
d2$ptw1 <-NA # Prob(Rt tweet >1)
d2$Rtwlr <-NA # lim inf IC Rt tweet
d2$Rtwur <-NA  # lim sup IC Rt tweet

for(i in 1:10) d2[d2$APS==listaAPS[i],c("Rtw","ptw1","Rtwlr","Rtwur")] <- Rt.beta(d2$tweets[d2$APS==listaAPS[i]])
tail(d2)


d2$Rt <-NA
d2$pRt1 <-NA
d2$Rtlr <-NA
d2$Rtur <-NA

for(i in 1:10) d2[d2$APS==listaAPS[i],c("Rt","pRt1","Rtlr","Rtur")] <- 
  Rt.beta((d2$casosm[d2$APS==listaAPS[i]]))

# grafico Rt dengue AP1
par(mfrow=c(2,1),mar = c(1,5,1,2))
plot(d$casos[d$APS=="AP1"],type="l",ylab="casos na APS 1.0",xlab="",
     ylim=range(d$casos[d$APS=="AP1"]))

x = c(1:length(d2$Rt[d2$APS=="AP1"]),length(d2$Rt[d2$APS=="AP1"]):1 )
y = c(d2$Rtlr[d2$APS=="AP1"], rev(d2$Rtur[d2$APS=="AP1"]))
plot(d2$Rt[d2$APS=="AP1"],type="l",ylab="Rt",xlab="semana",ylim=c(0.5,1.5))
#lines(d2$Rtlr[d2$APS=="AP1"],col="grey")
#lines(d2$Rtur[d2$APS=="AP1"],col="grey")
polygon(x,y,col="grey",border="grey")
lines(d2$Rt[d2$APS=="AP1"])
abline(h=1,col=2)
epi <- which(d2$Rtlr[d2$APS=="AP1"]>1)
points(epi,rep(1,length(epi)),pch=16,col=2)


# grafico verde
pop<-read.csv(file="../tabelas/populacao2010porAPS_RJ.csv")
d2<-merge(d2,pop)
d2<-d2[order(d2$APS,d2$SE),]


detcli <- function(temp,tempcrit=22,lag=3){
  t1<-as.numeric(temp>=tempcrit)
  le <- length(t1)
  ac <- t1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+t1[(lag-i):(le-i)]
  c(rep(NA,(lag-1)),ac)
}

d2$alertaCli <- NA
for(i in 1:10) d2$alertaCli[which(d2$APS==listaAPS[i])] <-detcli(d2$tmin[d2$APS==listaAPS[i]])

Rtgreat1 <- function(p1,pcrit=0.8,lag=0){
  t1<-as.numeric(p1>pcrit)
  ac<-t1
  if (lag>0) {
    le <- length(t1)
    ini <- (lag+1)
    ac <- t1[ini:le]
    for(i in 1:(ini-1)) ac <- ac+t1[(ini-i):(le-i)]
    ac<-c(rep(NA,(ini-1)),ac)
  }
  ac
}
for(i in 1:10) d2$twgreat1[d2$APS==listaAPS[i]] <-Rtgreat1(d2$ptw1[d2$APS==listaAPS[i]],pcrit=0.90,lag=0)
for(i in 1:10) d2$alertaRtweet[d2$APS==listaAPS[i]] <-Rtgreat1(d2$ptw1[d2$APS==listaAPS[i]],pcrit=0.90,lag=3)
# Rt(dengue) > 1 se Pr>0.8 
for(i in 1:10) d2$Rtgreat1[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRt[d2$APS==listaAPS[i]],pcrit=0.90,lag=0)
# alertaRt = acumulado de Rt>1 por 3 vezes
for(i in 1:10) d2$alertaRt[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRt[d2$APS==listaAPS[i]],pcrit=0.90,lag=3)


d2$inc <- d2$casosm/d2$Pop2010*100000
d2$alertaCasos <- as.numeric(d2$inc>100)


le = length(d2$tmin[d2$APS==listaAPS[1]])

par(mfrow=c(1,1))
# verde
les = dim(d2)[1]
d2$cor <-NA
d2$cor[intersect(6:les,which(d2$alertaCli<3 & d2$alertaRtweet<3 & d2$alertaRt<3 & d2$alertaCasos==0))]<-1
plot(d2$casos[d2$APS=="AP1"],type="l",axes=FALSE,ylab="",xlab="")
abline(v=which(d2$cor==1),col="green",lwd=2)
lines(d2$casos[d2$APS=="AP1"])

# amarelo
d2$cor[intersect(6:les,which(d2$alertaCli>=3 | d2$alertaRtweet>=3))]<-2
d2$cor[intersect(6:les,which(d2$alertaCli>=3| d2$alertaRtweet>=3)+1)]<-2 # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaCli>=3| d2$alertaRtweet>=3)+2)]<-2 # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaCli>=3| d2$alertaRtweet>=3)+3)]<-2 # inercia para desligar
plot(d2$casos[d2$APS=="AP1"],type="l",axes=FALSE,ylab="",xlab="")
abline(v=which(d2$cor==2),col="yellow",lwd=2)
lines(d2$casos[d2$APS=="AP1"])

# laranja
d2$cor[intersect(6:les,which(d2$alertaRt>=3))]<-3
d2$cor[intersect(6:les,which(d2$alertaRt>=3)+1)]<-3 # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaRt>=3)+2)]<-3 # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaRt>=3)+3)]<-3 # inercia para desligar
plot(d2$casos[d2$APS=="AP1"],type="l",axes=FALSE,ylab="",xlab="")
abline(v=which(d2$cor==3),col="orange",lwd=2)
lines(d2$casos[d2$APS=="AP1"])

# vermelho
d2$cor[intersect(6:les,which(d2$alertaCasos==1))]<-4
d2$cor[intersect(6:les,which(d2$alertaCasos==1)+1)]<-4  # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaCasos==1)+2)]<-4   # inercia para desligar
d2$cor[intersect(6:les,which(d2$alertaCasos==1)+3)]<-4
plot(d2$casos[d2$APS=="AP1"],type="l",axes=FALSE,ylab="",xlab="")
abline(v=which(d2$cor==4),col="red",lwd=2)
lines(d2$casos[d2$APS=="AP1"])

## situação atual

par(mar=c(5,4,3,1))
d3<-subset(d2,APS=="AP1")
plot(d3$Rtw[d3$SE>201500],type="l",ylim=c(0.5,1.5),ylab="Rt (tweet)",axes=FALSE,xlab="",lwd=3)
lines(d3$Rtwlr[d3$SE>201500],col="grey",lwd=3)
lines(d3$Rtwur[d3$SE>201500],col="grey",lwd=3)
abline(h=1,col=2)
axis(2)
axis(1,at=rev(seq(les,1,by=-1)),labels=d2$SE[rev(seq(les,1,by=-1))],las=2,cex=0.3)


par(mar=c(5,4,3,1))
d3<-subset(d2,APS=="AP5.1")
plot(d3$Rt[d3$SE>201500],type="l",ylim=c(0,3),ylab="Rt (dengue)",axes=FALSE,xlab="",main="AP5.1",lwd=3)
lines(d3$Rtlr[d3$SE>201500],col="grey",lwd=3)
lines(d3$Rtur[d3$SE>201500],col="grey",lwd=3)
abline(h=1,col=2)
axis(2)
axis(1,at=rev(seq(les,1,by=-1)),labels=d2$SE[rev(seq(les,1,by=-1))],las=2,cex=0.3)


par(mar=c(5,4,3,1))
d3<-subset(d2,APS=="AP4")
plot(d3$Rt[d3$SE>201500],type="l",ylim=c(0,3),ylab="Rt (dengue)",axes=FALSE,xlab="",main="AP4")
lines(d3$Rtlr[d3$SE>201500],col="grey")
lines(d3$Rtur[d3$SE>201500],col="grey")
abline(h=1,col=2)
axis(2)
axis(1,at=rev(seq(les,1,by=-1)),labels=d2$SE[rev(seq(les,1,by=-1))],las=2,cex=0.3)


par(mar=c(5,4,3,1))
d3<-subset(d2,APS=="AP5.2")
plot(d3$Rt[d3$SE>201500],type="l",ylim=c(0,3),ylab="Rt (dengue)",axes=FALSE,xlab="",main="AP5.2")
lines(d3$Rtlr[d3$SE>201500],col="grey")
lines(d3$Rtur[d3$SE>201500],col="grey")
abline(h=1,col=2)
axis(2)
axis(1,at=rev(seq(les,1,by=-1)),labels=d2$SE[rev(seq(les,1,by=-1))],las=2,cex=0.3)
