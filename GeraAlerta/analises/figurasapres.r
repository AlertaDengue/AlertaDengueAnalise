#Figuras

d <- read.csv(file="../dados_limpos/dadosAPS_201443.csv")

names(d)

dd<-subset(d,APS=="AP1")
par(mfrow=c(2,1))
plot(dd$tweets,type="l",main="tweets",axes=FALSE,ylab="")
axis(2)
plot(dd$casos,type="l",main="casos",axes=FALSE,ylab="")
axis(2)
cor.test(dd$tweets,dd$casos)
