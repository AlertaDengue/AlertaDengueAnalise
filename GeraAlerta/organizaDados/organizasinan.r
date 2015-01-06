# Organiza dados do SINAN para o Alerta dengue
#====================================================
#A serie temporal 2010-13 ja esta pronta. Esse script agrega com a serie de 2014 em diante

#require(foreign)

#Dados do SINAN 2014
#--------------------

#novosinan <- paste("../",novosinan,sep="")
d <- read.dbf(novosinan)[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI",
                          "SEM_PRI","NM_BAIRRO")]
print(tail(d,n=7))


#Criar variavel APS
baps<-read.csv("tabelas/bairro2AP.csv")
d2<-merge(d,baps,by.x="NM_BAIRRO",by.y="bairro")

#Numero de registros sem AP (falha no mapeamento bairro -> APS)
falha=dim(d)[1]-dim(d2)[1]
message("numero de registros com info de bairro: ",dim(d2)[1])
message("numero de registros sem info de bairro: ",falha)

#Serie temporal de casos no municipio todo em 2014
st14 <- aggregate(d$SEM_NOT,by=list(d$SEM_NOT),FUN=length)
names(st14)<-c("SE","casos")
st14$SE<-as.numeric(as.character(st14$SE))
message("serie temporal da cidade:")
print(tail(st14))


#Cria Serie temporal de casos por APS em 2014
listaAPS<-unique(baps$APS)
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

