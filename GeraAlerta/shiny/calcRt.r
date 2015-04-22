# Gerador de Alerta - modelo claudia v1 
#========================================
require("EpiEstim")
# so teste: unica APS e elimina ultima entrada por NA
require("R0")
require("surveillance")


source("../fun/Rt.r")
source("../fun/data2SE.r")
source("../fun/corrigecasos.r")

calcdfRt <- function() {
# Abre os dados mais recentes
#dadosAPS <- paste("../",dadosAPS,sep="")
#d<-read.csv(dadosAPS)
dadosAPS <- "./dadosAPS_201514.csv"
d<-read.csv(dadosAPS)

d<-subset(d,SE>=201001)

listaAPS<-unique(d$APS)

# Correcoes
# =====================================================================
# corrige casos pelo atraso de digitacao (usando modelo sobrevida lognormal)
for(i in 1:10) d$casosm[d$APS==listaAPS[i]] <-corrigecasos(d$casos[d$APS==listaAPS[i]])

tot<-aggregate(d$casosm,by=list(d$SE),sum)
names(tot)<-c("SE","casosestimados")
message("correcao da incidencia pelo atraso de notificacao")
#print(tail(tot))

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
d2<-merge(d2,d[,c("SE","APS","data","tweets","estacao","casos","casosm","tmin")],by=c("SE","APS"))

# agregar dados de populacao (cuidado, desorganiza tudo!)
pop<-read.csv(file="./populacao2010porAPS_RJ.csv")
d2<-merge(d2,pop)
d2<-d2[order(d2$APS,d2$SE),]

message("d2")
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

message("Rtw")
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

for(i in 1:10) d2[d2$APS==listaAPS[i],c("Rt","pRt1","Rtlr","Rtur")] <- Rt.beta((d2$casosm[d2$APS==listaAPS[i]]))

#  imputa os P(Rt) faltantes com p(Rtw)
d2$pRti <- d2$pRt1
d2$pRti[is.na(d2$pRt1)]<-d2$ptw1[is.na(d2$pRt1)]
#d2$Rti <- d2$Rt1
#d2$Rti[is.na(d2$Rt)]<-d2$Rtw[is.na(d2$Rt)]


# Rt(dengue) > 1 se Pr>0.9 
for(i in 1:10) d2$Rtgreat1[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRti[d2$APS==listaAPS[i]],pcrit=0.85,lag=0)

# alertaRt = acumulado de Rt>1 por 3 vezes
for(i in 1:10) d2$alertaRt[d2$APS==listaAPS[i]] <-Rtgreat1(d2$pRti[d2$APS==listaAPS[i]],pcrit=0.85,lag=3)

message("Rt dengue")
# daniel:

#grafico Rt
#require(ggplot2)
#gRt <- ggplot(subset(d2, as.numeric(APS)<5), aes(x=SE, y=Rt))
#gRt <- gRt + geom_ribbon(aes(ymin=Rtlr, ymax=Rtur), colour="gray") +  geom_line() + facet_grid(APS ~ .)

nAPS <- length(listaAPS)

dfRt <- data.frame(d2[,c("SE", "Rt", "Rtlr", "Rtur", "APS", "casosm")], method="alert", time=NA)

message("started dfRt")
for (i in 1:10) {
    d3 <- d2$casosm[d2$APS==listaAPS[i]]
    d3len <- length(d3)
    dfRt[dfRt$APS==listaAPS[i], "time"] <- 1:d3len
}

#print(tail(dfRt))

for (i in c(1:3,6:7, nAPS)) {
#i<-1
    d3 <- d2$casosm[d2$APS==listaAPS[i]]
    d3len <- length(d3)
    tstart <- 3:(d3len-6)
    tend <- (3+6):d3len
    er <- EstimateR(d3, T.Start=tstart, T.End=tend, method="ParametricSI",
             Mean.SI = 3, Std.SI=1,
#      	         SI.Distr=Flu2009$SI.Distr,
          	  plot=FALSE, leg.pos=xy.coords(1,3))
message("ER")
     listSE <- d2$SE[d2$APS==listaAPS[i]]
     derRt <- data.frame(time = tend, SE=listSE[tend], Rt=er$R["Mean(R)"], 
     Rtlr=er$R["Quantile.0.025(R)"],
     Rtur = er$R["Quantile.0.975(R)"], APS=listaAPS[i], casosm= d3[tend], method="EpiEstim")

     mGT<-generation.time("gamma", c(3, 1))
#     TD <- est.R0.TD(d3, mGT, nsim=1000)
#TD  
d3pop <- d2$Pop2010[d2$APS==listaAPS[i]]
     rangeTD <- c(1, d3len)
message("before est.R")
     TDall <- estimate.R(round(d3), mGT, begin=rangeTD[1], end=rangeTD[2], methods=c( "TD"), pop.size=d3pop[1], nsim=100)
  # TDall <- est.R0.TD(d3, mGT, begin=rangeTD[1], end=rangeTD[2], nsim=1000)
message("TDall")
#     TD.weekly <- smooth.Rt(TD, 7)
     dTD <- data.frame(time = 1:d3len, SE= listSE, 
                       Rt = TDall$estimates$TD$R, 
                       Rtlr = TDall$estimates$TD$conf.int[1], 
                       Rtur = TDall$estimates$TD$conf.int[2],                        
                       APS = listaAPS[i], casosm = d3, method="TD")
     colnames(dTD) <- c("time", "SE", "Rt", "Rtlr", "Rtur", "APS", "casosm", "method")
     colnames(derRt) <- c("time", "SE", "Rt", "Rtlr", "Rtur", "APS", "casosm", "method")	
#print("colnames")
     dfRt <- rbind(dfRt, dTD, derRt) 
#print("done with dfRt")
}

#g <- ggplot(subset(dfRt,APS==listaAPS[1]), aes(x=SE, y=Rt))
#g <- g+ geom_ribbon(aes(ymin = Rtlr, ymax=Rtur)) + geom_line() + facet_grid(method ~ .)

#plot(TD.weekly)


return(dfRt)
}