d<- read.csv(file="pop.csv")
head(d)
class(d$pop)


b <- read.csv(file="bairro2AP.csv")
names(b)[2]<-"BAIRRO"
head(b)

bd <-merge(d,b,all.d=TRUE)
head(bd)
class(bd$pop)

popap<-aggregate(bd$pop,by=list(bd$APS),FUN=sum)
names(popap)<-c("APS","Pop2010")

write.csv(popap,file="populacao2010porAPS_RJ.csv",row.names=FALSE)
