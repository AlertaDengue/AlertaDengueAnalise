# Organiza dados do SINAN para o Alerta dengue
#====================================================
#A serie temporal 2010-13 ja esta pronta. Esse script agrega com a serie de 2014 em diante

#require(foreign)

###Dados do SINAN 2014 e 2015
#--------------------

d14 <- read.dbf(novosinan2014)[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA",
                          "SEM_PRI","NM_BAIRRO")]
d15 <- read.dbf(novosinan2015)[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA",
                                  "SEM_PRI","NM_BAIRRO")]
d<-rbind(d14,d15)
#print(tail(d,n=7))
d$atraso<-as.numeric(d$DT_DIGITA-d$DT_SIN_PRI)

###Criar variavel APS
# -----------------
baps<-read.csv("tabelas/bairro2AP.csv")
d2<-merge(d,baps,by.x="NM_BAIRRO",by.y="bairro")

# identificar os casos nos quais nao foram identificados a APS.
d3<-merge(d,baps,by.x="NM_BAIRRO",by.y="bairro",all.x=TRUE,sort=FALSE)
nad3 <- d3[which(is.na(d3$APS)),] 
nad3$SEM_NOT <- as.numeric(as.character(nad3$SEM_NOT))

message("casos perdidos por não geolocalização no MRJ na ultima semana: ",tail(tapply(nad3$SEM_NOT,nad3$SEM_NOT,length),1))
if(tail(tapply(nad3$SEM_NOT,nad3$SEM_NOT,length),1)>0) print(nad3[nad3$SEM_NOT==max(nad3$SEM_NOT),])

#Numero de registros sem AP (falha no mapeamento bairro -> APS), em quase todas as vezes deve-se a 
# localizacao fora do Rio de Janeiro
# falha=(dim(d)[1]-dim(d2)[1])/dim(d)[1]*100
#message("% de registros sem geolocalizacao no RJ desde 2014: ",falha," %")
rm(d3,nad3)

###Serie temporal de casos no municipio
# ---------------------------------------------------
st14 <- aggregate(d$SEM_NOT,by=list(d$SEM_NOT),FUN=length)
names(st14)<-c("SE","casos")
st14$SE<-as.numeric(as.character(st14$SE))
message("serie temporal da cidade:")
print(tail(st14))

### Atraso de digitacao - A fazer 
#at14 <- aggregate(d$atraso,by=list(d$SEM_NOT),FUN=median)
#names(at14)<-c("SE","medianatraso")
#st14$SE<-as.numeric(as.character(st14$SE))
#message("serie temporal da cidade:")
#print(tail(st14))


###Cria Serie temporal de casos por APS 
# ----------------------------------------------
listaAPS<-unique(baps$APS)

# primeiro s´o 2014 em diante
sem <- unique(d$SEM_NOT)
st14.ap <- expand.grid(SE=sem,APS=listaAPS)
st14.ap$casos <- NA
for(i in 1:dim(st14.ap)[1]) st14.ap$casos[i]<-length(d2$SEM_NOT[d2$SEM_NOT %in% st14.ap$SE[i] 
                                                                & d2$APS %in% st14.ap$APS[i]])
st14.ap$SE<-as.numeric(as.character(st14.ap$SE))

# Juntando com dados de anos anteriores
load("dados_brutos/sinan/casos2010-2013.Rdata")
st10.13$SE<-as.numeric(as.character(st10.13$SE))
st10.13.aps$SE<-as.numeric(as.character(st10.13.aps$semana)) # ok

st<-rbind(st10.13,st14)
st.ap<-rbind(st10.13.aps[,c(4,3,2)],st14.ap) 

st<-st[order(st$SE),]
st.ap <-st.ap[order(st.ap$APS,st.ap$SE),]
st <- subset(st,SE>=201001)
st.ap <- subset(st.ap,SE>=201001)


#Serie temporal de casos na cidade**
#plot(st$casos,type='l',ylab="casos",xlab="",axes=FALSE)
#axis(2)
#axis(1,at=seq(1,length(st$SE),by=6*4),label=st$SE[seq(1,length(st$SE),by=6*4)],las=2,cex.axis=0.7)

#Serie temporal de casos por APS**
#plot(st.ap$casos[st.ap$APS==listaAPS[1]],type="l",ylim=1.5*range(st.ap$casos),xlab="",ylab="casos",axes=FALSE)
#for (j in 2:10) lines(st.ap$casos[st.ap$APS==listaAPS[j]],col=j)
#axis(2)
#sem <- sort(unique(st.ap$SE))
#axis(1,at=seq(1,length(sem),by=6*4),label=sem[seq(1,length(sem),by=6*4)],las=2,cex.axis=0.7)
#legend(0,1.5*max(st.ap$casos),listaAPS,lty=1,col=1:10,cex=0.6)


#Salvando**
message("arquivo casos salvo: dadoslimpos/sinansemanaAP_RJ.csv")
write.table(st.ap,file="dados_limpos/sinansemanaAP_RJ.csv",sep=",",row.names=FALSE)
write.table(st,file="dados_limpos/sinansemana_RJ.csv",sep=",",row.names=FALSE)

