# Gerador de Alerta - modelo claudia v1 
#========================================

source("fun/Rt.r")
source("fun/data2SE.r")
source("fun/corrigecasos.r")

# Abre os dados mais recentes
#dadosAPS <- paste("../",dadosAPS,sep="")
d<-read.csv(dadosAPS)
d<-subset(d,SE>=201001)

listaAPS<-unique(d$APS)

# Correcoes
# =====================================================================
# corrige casos pelo atraso de digitacao (usando modelo sobrevida lognormal)
#for(i in 1:10) d$casos_est[d$APS==listaAPS[i]] <-corrigecasos(d$casos[d$APS==listaAPS[i]]) (antigo)
for(i in 1:10) d$casos_est[d$APS==listaAPS[i]]<-corrigecasosIC(d$casos[d$APS==listaAPS[i]])[,5]
for(i in 1:10) d$casos_estmin[d$APS==listaAPS[i]]<-corrigecasosIC(d$casos[d$APS==listaAPS[i]])[,4]
for(i in 1:10) d$casos_estmax[d$APS==listaAPS[i]]<-corrigecasosIC(d$casos[d$APS==listaAPS[i]])[,6]

totcrude <- aggregate(d$casos,by=list(d$SE),sum)
totest<-aggregate(d$casos_est,by=list(d$SE),sum)
totmin<-aggregate(d$casos_estmin,by=list(d$SE),sum)
totmax<-aggregate(d$casos_estmax,by=list(d$SE),sum)
tot<-cbind(totcrude,totest$x,totmin$x,totmax$x)

names(tot)<-c("SE","casos","casos.estimados","ICmin","ICmax")

message("correcao da incidencia pelo atraso de notificacao")
options(scipen=10)
print(tail(tot))

# preencher alguns dados faltantes de clima com a media das outras estacoes (se possivel)
#m = which(is.na(d$tmin))
#for (i in m) d$tmin[i]<-(mean(d$tmin[d$SE==d$SE[i]],na.rm=TRUE))

#--------------------------
#Alerta por APS em 4 niveis
#--------------------------

#**Verde (atividade baixa)** 
#- se temperatura < 22 graus por 3 semanas 
#- se atividade de tweet for normal (nao aumentada)
#- ausencia de transmissao sustentada
#- se incidencia < 100:100.000

#**Amarelo (Alerta)**
#- se temperatura > 22C por mais de 3 semanas
#- se atividade de tweet aumentar

#**Laranja (Transmissao sustentada)**
#- se numero reprodutivo >1, por 3 semanas

#**Vermelho (atividade alta)**
#- se incidencia > 100:100.000

# data.frame para colocar os resultados
SE<-d$SE[d$APS=="AP1"]
d2 <- expand.grid(SE=SE,APS=listaAPS)
d2<-merge(d2,d[,c("SE","APS","data","tweets","estacao","casos","casos_est","casos_estmin","casos_estmax","tmin")],by=c("SE","APS"))

# agregar dados de populacao (cuidado, desorganiza tudo!)
pop<-read.csv(file="tabelas/populacao2010porAPS_RJ.csv")
d2<-merge(d2,pop)
d2<-d2[order(d2$APS,d2$SE),]


#"Alerta de Temperatura minima semanal > 22 graus por 3 semanas"
#Temperatura > Tcrit
detcli <- function(temp,tempcrit=22,lag=3){
    t1<-as.numeric(temp>=tempcrit)
    le <- length(t1)
    ac <- t1[lag:le]
    for(i in 1:(lag-1)) ac <- ac+t1[(lag-i):(le-i)]
    c(rep(NA,(lag-1)),ac)
}

d2$alertaCli <- NA
for(i in 1:10) d2$alertaCli[which(d2$APS==listaAPS[i])] <-detcli(d2$tmin[d2$APS==listaAPS[i]])

# Rtw = crescimento significativo de tweet na ultima semana (repete os valores para todas as APS)
d2$Rtw <-NA  # Rt do tweet
d2$ptw1 <-NA # Prob(Rt tweet >1)
d2$Rtwlr <-NA # lim inf IC Rt tweet
d2$Rtwur <-NA  # lim sup IC Rt tweet


for(i in 1:10) d2[d2$APS==listaAPS[i],c("Rtw","ptw1","Rtwlr","Rtwur")] <- Rt.beta(d2$tweets[d2$APS==listaAPS[i]])

# funcao que calcula o indicador pr(Rt >1) >pcrit (default pcrit=0.95, lag=3)  # serve tanto para Rt de tweet como para casos

Rtgreat1 <- function(p1,pcrit=0.8,lag=0){
    t1<-as.numeric(p1>pcrit)
    le <- length(t1)
    if (lag==0) ac<-t1[1:le]
    if (lag>0) {
          ini <- lag # ini <- (lag+1)
          ac <- t1[ini:le]
          for(i in 1:(ini-1)) ac <- ac+t1[(ini-i):(le-i)]
          ac<-c(rep(NA,(ini-1)),ac)
          }
    ac
}


# Rt(tweet) > 1 se Pr>0.9 
for(i in 1:10) d2$twgreat1[d2$APS==listaAPS[i]] <-Rtgreat1(d2$ptw1[d2$APS==listaAPS[i]],pcrit=0.85,lag=0)

# alertaRtweet = acumulado de Rt>1 por 3 vezes
for(i in 1:10) d2$alertaRtweet[d2$APS==listaAPS[i]] <-Rtgreat1(d2$ptw1[d2$APS==listaAPS[i]],pcrit=0.85,lag=3)

# calculo do Rt de dengue**

d2$Rt <-NA
d2$pRt1 <-NA
d2$Rtlr <-NA
d2$Rtur <-NA

for(i in 1:10) d2[d2$APS==listaAPS[i],c("Rt","pRt1","Rtlr","Rtur")] <- 
  Rt.beta((d2$casos_est[d2$APS==listaAPS[i]]))

missing <- is.na(tail(d2$Rt)[6]) # TRUE se dado de sinan da ultima semana esta faltando

if(missing==TRUE){  # se nao tem Rt (pq nao tem casos), usar Rtw (do tweet), assume mapeamento direto, pode ser melhorado
  d2$Rt[is.na(d2$Rt)]<-d2$Rtw[is.na(d2$Rt)]
  d2$pRt1[is.na(d2$pRt1)]<-d2$ptw1[is.na(d2$pRt1)]
  d2$Rtlr[is.na(d2$Rtlr)]<-d2$Rtwlr[is.na(d2$Rtlr)]
  d2$Rtur[is.na(d2$Rtur)]<-d2$Rtwur[is.na(d2$Rtur)]
}

#  imputa os P(Rt) faltantes com p(Rtw) #eliminei a variavel pRti para simplificar. Toda a imputacao
# ´e feita diretamente na variavel pRT
#d2$pRti <- d2$pRt1
#d2$pRti[is.na(d2$pRt1)]<-d2$ptw1[is.na(d2$pRt1)]
#d2$Rti <- d2$Rt1
#d2$Rti[is.na(d2$Rt)]<-d2$Rtw[is.na(d2$Rt)]

# Rt(dengue) > 1 se Pr>0.9 
for(i in 1:10) d2$Rtgreat1[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRt[d2$APS==listaAPS[i]],pcrit=0.85,lag=0)

# alertaRt = acumulado de Rt>1 por 3 vezes
for(i in 1:10) d2$alertaRt[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRt[d2$APS==listaAPS[i]],pcrit=0.85,lag=3)



# Casos:
# onde houver dados faltantes, completar calculando o valor esperado considerando a tendencia de variacao das ultimas 3 semanas.
# Isso é, calcula a média de variacao (Rt) das ultimas 3 semanas e multiplica pelo valor observado de casos. 

fillCasos <- function(casos, Rt){
  casos_est <- casos
  for (j in 5:length(casos_est)){
    if(is.na(casos_est[j])) casos_est[j]<-casos_est[(j-1)]*mean(Rt[(j-1):(j-3)],na.rm=TRUE)
    
  }
  #n <- which(is.na(casos_est))
  #if(length(n)>0) casos_est[n]<-casos[(n-1)]*mean(Rt[(n-2)],na.rm=TRUE)
  casos_est
  }

for(i in 1:10) d2$casos_est[d2$APS==listaAPS[i]]<-fillCasos((d2$casos_est[d2$APS==listaAPS[i]]),
                                                            d2$Rt[d2$APS==listaAPS[i]])

d2$inc <- d2$casos_est/d2$Pop2010*100000
d2$alertaCasos <- as.numeric(d2$inc>100)


#Resultado
#---------

#**Legenda:**
# - SE : semana epidemiologica
# - data: data de inicio da SE
# - APS: area programatica da saude
# - tmin: media das temperaturas minimas da semana
# - casos_est: numero de casos estimados na semana (3)
# - inc: casos por 100.000 habitantes
# - alertaClima = 1, se temperatura > 22C por mais de 3 semanas
# - alertaTweet = 1, se Tweet com tendencia de aumento 
# - alertaTransmissao = 1, se casos com tendencia de aumento
# - alertaCasos = 1, se Incidencia > 100 por 100 mil

 
le = length(d2$tmin[d2$APS==listaAPS[1]])



def.cor<-function(d2v){
# d2v = dados de uma ap
      # 1 = verde, 2=amarelo, 3 =laranja, 4 = vermelho
      les = dim(d2v)[1]
      d2v$cor <-1
      d2v$cor[intersect(6:les,which(d2v$alertaCli<3 & d2v$alertaRtweet<3 & d2v$alertaRt<3 & d2v$alertaCasos==0))]<-1
      d2v$cor[intersect(6:les,which(d2v$alertaCli>=3 | d2v$alertaRtweet>=3))]<-2
      d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+1)]<-2 # inercia para desligar
      d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+2)]<-2 # inercia para desligar
      d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+3)]<-2 # inercia para desligar
      d2v$cor[intersect(6:les,which(d2v$alertaRt>=3))]<-3
      #d2v$cor[intersect(6:les,which(d2v$alertaRt>=3)+1)]<-3 # inercia para desligar
      for (t in 1:6) d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$Rt>=1))]<-3 # manter laranja de Rt>1
      d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$alertaRt>=1))]<-3
      d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$alertaRt>=1)+1)]<-3
    #  for (t in 1:6) d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$Rt>=1)+1)]<-3 # manter laranja de Rt>1
     # for (t in 1:6) d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$Rt>=1)+2)]<-3 # manter laranja de Rt>1
      #d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+2),which(d2v$Rt>1))]<-3
      #d2v$cor[intersect(6:les,which(d2v$alertaRt>=3)+2)]<-3 # inercia para desligar     
          #d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+1),which(d2v$alertaRt>=1))]<-3
      #d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+2),which(d2v$alertaRt>=1))]<-3      
      #d2v$cor[intersect(intersect(6:les,which(d2v$cor==3)+3),which(d2v$alertaRt>=1))]<-3      
      
     # d2v$cor[intersect(intersect(6:les,which(d2v$alertaRt>=3)+6),which(d2v$alertaRt>=1))]<-3 
      d2v$cor[intersect(6:les,which(d2v$alertaCasos==1))]<-4
      d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+1)]<-4  # inercia para desligar
      d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+2)]<-4   # inercia para desligar
      d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+3)]<-4
      d2v
}

def.cor<-function(d2v){
  # d2v = dados de uma ap
  # 1 = verde, 2=amarelo, 3 =laranja, 4 = vermelho
  les = dim(d2v)[1]
  d2v$cor <-NA
  d2v$cor[intersect(6:les,which(d2v$alertaCli<3 & d2v$alertaRtweet<4 & d2v$alertaRt<3 & d2v$alertaCasos==0))]<-1
  d2v$cor[intersect(6:les,which(d2v$alertaCli>=3 | d2v$alertaRtweet>=3))]<-2
  d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+1)]<-2 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+2)]<-2 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaCli>=3| d2v$alertaRtweet>=3)+3)]<-2 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaRt>=3))]<-3
  d2v$cor[intersect(6:les,which(d2v$alertaRt>=3)+1)]<-3 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaRt>=3)+2)]<-3 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaRt>=3)+3)]<-3 # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaCasos==1))]<-4
  d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+1)]<-4  # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+2)]<-4   # inercia para desligar
  d2v$cor[intersect(6:les,which(d2v$alertaCasos==1)+3)]<-4
  d2v
}

d2$cor<-NA
for(i in 1:10) d2[d2$APS==listaAPS[i],]<-def.cor(d2[d2$APS==listaAPS[i],])

# codificacao para o relatorio
d2$alertaTweet <- ifelse(d2$alertaRtweet>=3,1,0)
d2$alertaClima <- ifelse(d2$alertaCli>=3,1,0)
d2$alertaTransmissao <- ifelse(d2$alertaRt>=3,1,0)
d2$nivel<-"nulo"
d2$nivel[d2$cor==1]<-"verde"
d2$nivel[d2$cor==2]<-"amarelo"
d2$nivel[d2$cor==3]<-"laranja"
d2$nivel[d2$cor==4]<-"vermelho"

# Alguns graficos
#par(mfrow=c(1,1),mar=c(4,4,2,2))
#plot.alerta2(listaAPS[3])

#png("alerta.png",res=200,width = 22,height = 15,units="cm")
#  layout(matrix(1:10,nrow = 2),widths = rep(lcm(4),5),heights = rep(lcm(7),2))
#  for(i in 1:10) plot.alerta2(listaAPS[i])
#dev.off()

# graficos extras
#plot(d2$Rtw[(2870-20):2870],type="l",ylim=c(0,2),ylab="Rt(tweets)",xlab="últimas semanas")
#lines(d2$Rtwlr[(2870-20):2870],type="l",lty=2)
#lines(d2$Rtwur[(2870-20):2870],type="l",lty=2)
#abline(h=1,col=2)

options(digits = 2)
for(i in 1:10) {
  message(paste ("Estado do Alerta de ",listaAPS[i]))
  print(tail(d2[d2$APS==listaAPS[i],c(1:4,6:9,10,19,20,25,27,31)],n=4))
  #print(tail(d2[d2$APS==listaAPS[i],],n=4))
  
}
        
outputfile = paste("alerta/alertaAPS_",max(d2$SE),".csv",sep="")
message("alerta salvo em ",outputfile)

dd<-d2[,c(1:4,6:9,10,19,20,25,27,31)]
write.table(d2[,c(1:4,6:9,10,19,20,25,27,31)],file=outputfile,row.names=FALSE,sep=",")

nalerta <- outputfile
knit(input="geraAlerta/relatorio.rmd",quiet=TRUE,envir=new.env())

message("relatorio.md gerado. Abri-lo no RStudio e rodar PREVIEW PDF")
message("fim")
