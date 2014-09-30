#### Gera indicadores de variaveis meteorologicas ####
#### Claudia Codeco Jan 2014 #########################

#library("chron")
library("lubridate")
library("date")


# clima.hora2dia ----------------------------------------------------------


######## Função clima.hora2dia
#USO: recebe dados de estacao meteorologica coletada de 10 em 10 minutos e retorna
# medidas diárias
# d = data.frame com os dados
# estacao = nome da estação (variavel d$Localizacao). 
# Os nomes das variaveis devem ser:
#[1] "DataDeMedicao"                    "Localizacao"                      "Temperatura_Valor"                "Temperatura_Flag"                
#[5] "Umidade_Relativa_Valor"           "Umidade_Relativa_Flag"            "Dir_Escalar_Vento_Valor"          "Dir_Escalar_Vento_Flag"          
#[9] "Vel_Escalar_Vento_Valor"          "Vel_Escalar_Vento_Flag"           "Pressao_Atmosferica_Valor"        "Pressao_Atmosferica_Flag"        
#[13] "Radiacao_Solar_Valor"             "Radiacao_Solar_Flag"              "Precipitacao_Pluviometrica_Valor" "Precipitacao_Pluviometrica_Flag" 

julianorigin <- as.Date("2010-01-01")  # definido o dia de referencia do calendario juliano

clima.hora2dia <-function(d,estacao="Centro",jor=julianorigin){

  loc <- estacao
  bd <- subset(d,d$Localizacao==loc)
  
  # transformando a variavel temporal
  bd$data <- as.Date(bd$DataDeMedicao)
  bd$mes <- months(bd$data)
  bd$ano <- year(bd$data)
  bd$diadomes <- mday(bd$data)  # de 1 a 31
  bd$diacorr <- yday(bd$data)   # 1 a 366
  bd$julian <- julian(as.Date(bd$DataDeMedicao),origin=jor)
  
    julian = seq(min(bd$julian),max(bd$julian))
        # banco de dados diario
    
    bddiario <- data.frame(data=I(unique(bd$data)),julian=julian,localizacao=loc)
        
    bddiario$tmin<-tapply(bd$Temperatura_Valor,bd$julian,min,na.rm=T)
    bddiario$tmax<-tapply(bd$Temperatura_Valor,bd$julian,max,na.rm=T)
    bddiario$tmed<-tapply(bd$Temperatura_Valor,bd$julian,mean,na.rm=T)
    bddiario$t18<-tapply(bd$Temperatura_Valor>=18,bd$julian,sum,na.rm=T)/(6*24)  # convertendo para fracao de dia com a temperatura >18C 
    bddiario$t24<-tapply(bd$Temperatura_Valor>=24,bd$julian,sum,na.rm=T)/(6*24)  # convertendo para fracao de dia com a temperatura >24C
    bddiario$t28<-tapply(bd$Temperatura_Valor>=28,bd$julian,sum,na.rm=T)/(6*24)  # convertendo para fracao de dia com a temperatura >28C
    bddiario$t32<-tapply(bd$Temperatura_Valor>=32,bd$julian,sum,na.rm=T)/(6*24)  # convertendo para fracao de dia com a temperatura >32C
    bddiario$medidastemp<-tapply(bd$Temperatura_Valor,bd$julian,length)/144      # 1 significa completo
    bddiario$mmchuva<-tapply(bd$Precipitacao_Pluviometrica_Valor,bd$julian,sum,na.rm=T)
    bddiario$horaschuva<-tapply(bd$Precipitacao_Pluviometrica_Valor>0,bd$julian,sum,na.rm=T)*10/60
    bddiario$medidaschuva<-tapply(bd$Precipitacao_Pluviometrica_Valor,bd$julian,length)/144      # 1 significa completo
    bddiario$umin <-tapply(bd$Umidade_Relativa_Valor,bd$julian,min,na.rm=T)
    bddiario$umed <-tapply(bd$Umidade_Relativa_Valor,bd$julian,mean,na.rm=T)
    
    bddiario
}

d<-read.table("Temperatura.txt",sep=";",header=TRUE)
table(d$Localizacao)
# AP5 Bangu, Campo Grande, , Guaratiba
# ap1 Centro
# ap2 Copa S Cristovao, Tijuca
# ap3 Iraja


dTijuca<-clima.hora2dia(d,estacao="Tijuca")
dCentro<-clima.hora2dia(d,estacao="Centro")
dBangu<-clima.hora2dia(d,estacao="Bangu")
dCGrande<-clima.hora2dia(d,estacao="Campo Grande")
dCopacabana<-clima.hora2dia(d,estacao="Copacabana")
dIraja<-clima.hora2dia(d,estacao="Iraja")
dPGuaratiba<-clima.hora2dia(d,estacao="Pedra de Guaratiba")
dSCrist<-clima.hora2dia(d,estacao="Sao Cristovao")
dfull <- rbind(dTijuca,dCentro,dBangu,dCGrande,dCopacabana,dIraja,dPGuaratiba,dSCrist)

write.table(dfull,file="temp_diaria.csv",row.names=F,sep=",")

# GraficosST --------------------------------------------------------------

# Tmin ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$tmin[dfull$loc=="Centro"],lty=1,ylab="Tmin",type='l',ylim=c(10,40),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,40,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$tmin[dfull$loc=="Tijuca"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$tmin[dfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$tmin[dfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(300,40,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$tmin[dfull$loc=="Iraja"],lty=1,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,40,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)
mtext("Temp min",at=1200,cex=1.4,col=6)
#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$tmin[dfull$loc=="Bangu"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$tmin[dfull$loc=="Campo Grande"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$tmin[dfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(300,40,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

# Tmed ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$tmed[dfull$loc=="Centro"],lty=1,ylab="Tmed",type='l',ylim=c(10,40),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,15,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$tmed[dfull$loc=="Tijuca"],lty=1,col=2,ylab="Tmed",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$tmed[dfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$tmed[dfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(300,15,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$tmed[dfull$loc=="Iraja"],lty=1,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,15,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)
mtext("Temp med",at=1200,cex=1.4,col=6)
#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$tmed[dfull$loc=="Bangu"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$tmed[dfull$loc=="Campo Grande"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$tmed[dfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(300,15,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

# Tmax ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$tmax[dfull$loc=="Centro"],lty=1,ylab="Tmax",type='l',ylim=c(10,45),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,15,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$tmax[dfull$loc=="Tijuca"],lty=1,col=2,ylab="Tmax",type='l',ylim=c(10,45),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$tmax[dfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$tmax[dfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(300,20,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$tmax[dfull$loc=="Iraja"],lty=1,ylab="tmax",type='l',ylim=c(10,45),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,15,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)
mtext("Temp max",at=1200,cex=1.4,col=6)
#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$tmax[dfull$loc=="Bangu"],lty=1,col=2,ylab="tmax",type='l',ylim=c(10,45),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$tmax[dfull$loc=="Campo Grande"],lty=1,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$tmax[dfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(300,20,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

# Umed ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$umed[dfull$loc=="Centro"],lty=1,ylab="Umed",type='l',ylim=c(30,100),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,40,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$umed[dfull$loc=="Tijuca"],lty=1,col=2,ylab="Umed",type='l',ylim=c(30,100),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$umed[dfull$loc=="Sao Cristovao"],lty=2,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$umed[dfull$loc=="Copacabana"],lty=2,col=3)
title('AP2 (2011-2013)')
legend(300,45,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$umed[dfull$loc=="Iraja"],lty=1,ylab="umed",type='l',ylim=c(30,100),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,45,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)
mtext("Umid med",at=1200,cex=1.4,col=6)

#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$umed[dfull$loc=="Bangu"],lty=1,col=2,ylab="umed",type='l',ylim=c(30,100),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$umed[dfull$loc=="Campo Grande"],lty=2,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$umed[dfull$loc=="Pedra de Guaratiba"],lty=2,col=3)
title('AP5 (2012-2013)')
legend(300,45,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

# mmChuva ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$mmchuva[dfull$loc=="Centro"],lty=1,ylab="mmchuva",type='l',ylim=c(10,200),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,200,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(25,50,75,100),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$mmchuva[dfull$loc=="Tijuca"],lty=1,col=2,ylab="mmchuva",type='l',ylim=c(10,200),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$mmchuva[dfull$loc=="Sao Cristovao"],lty=3,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$mmchuva[dfull$loc=="Copacabana"],lty=3,col=3)
title('AP2 (2011-2013)')
legend(300,200,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(25,50,75,100),lty=3)

#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$mmchuva[dfull$loc=="Iraja"],lty=1,ylab="mmchuva",type='l',ylim=c(10,200),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,200,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(25,50,75,100),lty=3)
mtext("mm Chuva",at=1200,cex=1.4,col=6)
#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$mmchuva[dfull$loc=="Bangu"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,200),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$mmchuva[dfull$loc=="Campo Grande"],lty=3,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$mmchuva[dfull$loc=="Pedra de Guaratiba"],lty=3,col=3)
title('AP5 (2012-2013)')
legend(300,200,c("Bangu","Campo Grande"),lty=1,col=c(2,4),cex=0.7,bty="n")
abline(h=c(25,50,75,100),lty=3)

# diasChuva ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(dfull$julian[dfull$loc=="Centro"],dfull$horaschuva[dfull$loc=="Centro"],lty=1,ylab="horaschuva",type='l',ylim=c(0,24),xlab="") #AP1
title('AP1 (2011-2013)')
legend(300,24,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(3,6,9,12),lty=3)

#AP2
plot(dfull$julian[dfull$loc=="Tijuca"],dfull$horaschuva[dfull$loc=="Tijuca"],lty=1,col=2,ylab="horaschuva",type='l',ylim=c(0,24),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Sao Cristovao"],dfull$horaschuva[dfull$loc=="Sao Cristovao"],lty=3,col=4)
lines(dfull$julian[dfull$loc=="Copacabana"],dfull$horaschuva[dfull$loc=="Copacabana"],lty=3,col=3)
title('AP2 (2011-2013)')
legend(300,24,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(3,6,9,12),lty=3)


#AP3
plot(dfull$julian[dfull$loc=="Iraja"],dfull$horaschuva[dfull$loc=="Iraja"],lty=1,ylab="horaschuva",type='l',ylim=c(0,24),xlab="",xlim=range(dfull$julian)) #AP1
title('AP3 (2012-2013)')
legend(300,24,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(3,6,9,12),lty=3)
mtext("horas Chuva",at=1200,cex=1.4,col=6)
#AP5
plot(dfull$julian[dfull$loc=="Bangu"],dfull$horaschuva[dfull$loc=="Bangu"],lty=1,col=2,ylab="horaschuva",type='l',ylim=c(0,24),xlab="",xlim=range(dfull$julian)) 
lines(dfull$julian[dfull$loc=="Campo Grande"],dfull$horaschuva[dfull$loc=="Campo Grande"],lty=3,col=4)
lines(dfull$julian[dfull$loc=="Pedra de Guaratiba"],dfull$horaschuva[dfull$loc=="Pedra de Guaratiba"],lty=3,col=3)
title('AP5 (2012-2013)')
legend(300,24,c("Bangu","Campo Grande"),lty=1,col=c(2,4),cex=0.7,bty="n")
abline(h=c(3,6,9,12),lty=3)

#--------------------------------------------------------------------------

# clima.dia2sem -----------------------------------------------------------

# dia 1 define o inicio da contagem do tempo calendario, definido inicialmente como 03-01-2010 (SE1): YMD
clima.dia2sem <-function(dd,estacao="Centro",dia1="2010-01-03",jor="2010-01-01"){
  
  loc <- estacao
  bd <- subset(dd,dd$localizacao==loc)
  diaini <- julian(as.Date(dia1),origin=as.Date(jor))  
  
  # criando uma variavel no banco diario identificadora de semana
  bd$ind <- ceiling((bd$julian-diaini)/7 )
  
  # remover a primeira semana, se for incompleta
  sem1 <- min(bd$ind)
  l1 <- length(bd$ind[bd$ind==sem1])
  if (l1<8) bd <- bd[-seq(1:l1),]
  
  # remover a ultima semana se for incompleta
  semu <- max(bd$ind)
  lu <- length(bd$ind[bd$ind==semu])
  if (lu<8) bd <- bd[-which(bd$ind==semu),]
  
  # variavel semanal - inicio da semana em dias julianos
  semjulian <- seq(diaini,max(bd$julian),by=7)  # sequencia completa desde o comeco 
  # variavel semanal - inicio da semana em dias calendario
  datasem <- date.ddmmmyy(semjulian + difftime(as.Date(jor),as.Date("1960-01-02")-1)) #
  ndados <- length(semjulian)
  
  SE<-unique(bd$ind)
  SEini<-min(SE)
  SEfim<-max(SE)
  
  bdsem <- data.frame(sem.data=datasem[SEini:SEfim],sem.julian=semjulian[SEini:SEfim],SE,localizacao=loc)
  
  bdsem$tmin<-tapply(bd$tmin,bd$ind,mean,na.rm=T)
  bdsem$tmed<-tapply(bd$tmed,bd$ind,mean,na.rm=T)
  bdsem$tmax<-tapply(bd$tmax,bd$ind,max,na.rm=T)
  bdsem$t18<-tapply(bd$t18,bd$ind,sum,na.rm=T)
  bdsem$t24<-tapply(bd$t24,bd$ind,sum,na.rm=T)
  bdsem$t28<-tapply(bd$t28,bd$ind,sum,na.rm=T)
  bdsem$t32<-tapply(bd$t32,bd$ind,sum,na.rm=T)
  bdsem$mmchuva<-tapply(bd$mmchuva,bd$ind,sum,na.rm=T)
  bdsem$diaschuva<-tapply(bd$horaschuva,bd$ind,sum,na.rm=T)/24
  bdsem$umin<-tapply(bd$umin,bd$ind,mean,na.rm=T)
  bdsem$umed<-tapply(bd$umed,bd$ind,mean,na.rm=T)
  bdsem
}

#USO:
sBangu<-clima.dia2sem(dfull,estacao="Bangu")
sCGrande<-clima.dia2sem(dfull,estacao="Campo Grande")
sCopa<-clima.dia2sem(dfull,estacao="Copacabana")
sTijuca<-clima.dia2sem(dfull,estacao="Tijuca")
sSCristovao<-clima.dia2sem(dfull,estacao="Sao Cristovao")
sGuaratiba<-clima.dia2sem(dfull,estacao="Pedra de Guaratiba")
sIraja<-clima.dia2sem(dfull,estacao="Iraja")
sCentro<-clima.dia2sem(dfull,estacao="Centro")

sfull<-rbind(sBangu,sCGrande,sCentro,sCopa,sTijuca,sSCristovao,sGuaratiba,sIraja)

write.table(sfull,file="temp_semanal.csv",row.names=F,sep=",")


# Calculando uma media para a cidade

  
  bdrio <- data.frame(SE=sort(unique(sfull$SE)),
                      sem.julian=tapply(sfull$sem.julian,sfull$SE,unique),
  tmin=tapply(sfull$tmin,sfull$SE,mean,na.rm=T),
  tmed=tapply(sfull$tmed,sfull$SE,mean,na.rm=T),
  tmax=tapply(sfull$tmax,sfull$SE,mean,na.rm=T),
  t18=tapply(sfull$t18,sfull$SE,mean,na.rm=T),
  t24=tapply(sfull$t24,sfull$SE,mean,na.rm=T),
  t28=tapply(sfull$t28,sfull$SE,mean,na.rm=T),
  t32=tapply(sfull$t32,sfull$SE,mean,na.rm=T),
  mmchuva=tapply(sfull$mmchuva,sfull$SE,mean,na.rm=T),
  diaschuva=tapply(sfull$diaschuva,sfull$SE,mean,na.rm=T),
  umin=tapply(sfull$umin,sfull$SE,mean,na.rm=T),
  umed=tapply(sfull$umed,sfull$SE,mean,na.rm=T))

bdrio$sem.data <- date.ddmmmyy(bdrio$sem.julian + difftime(as.Date(julianorigin),as.Date("1960-01-02")-1))
bdrio
write.table(bdrio,file="climaRio2010-2013.csv",sep=',')

# Graficos semanais -------------------------------------------------------



# FigTminsemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$tmin[sfull$loc=="Centro"],lty=1,ylab="Tmin",type='l',ylim=c(10,40),xlab="",axes=F) #AP1
axis(2)
title('AP1 (2011-2013)')
legend(50,40,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$tmin[sfull$loc=="Tijuca"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) 
axis(2)
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$tmin[sfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$tmin[sfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(50,40,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$tmin[sfull$loc=="Iraja"],lty=1,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) #AP1
axis(2)
axis(1)
title('AP3 (2012-2013)')
legend(50,40,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)
mtext("Temp min",at=180,line=2,cex=1.4,col=6)
#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$tmin[sfull$loc=="Bangu"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) 
axis(1)
axis(2)
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$tmin[sfull$loc=="Campo Grande"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$tmin[sfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(50,40,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

# FigTmedsemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$tmed[sfull$loc=="Centro"],lty=1,ylab="tmed",type='l',ylim=c(10,40),xlab="",axes=F) #AP1
axis(2)
title('AP1 (2011-2013)')
legend(50,40,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$tmed[sfull$loc=="Tijuca"],lty=1,col=2,ylab="tmed",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) 
axis(2)
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$tmed[sfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$tmed[sfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(50,40,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$tmed[sfull$loc=="Iraja"],lty=1,ylab="tmed",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) #AP1
axis(2)
axis(1)
title('AP3 (2012-2013)')
legend(50,40,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)
mtext("Temp med",at=180,line=2,cex=1.4,col=6)
#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$tmed[sfull$loc=="Bangu"],lty=1,col=2,ylab="tmed",type='l',ylim=c(10,40),xlab="",xlim=range(sfull$semana),axes=F) 
axis(1)
axis(2)
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$tmed[sfull$loc=="Campo Grande"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$tmed[sfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(50,40,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,25,30),lty=3)

# FigTmaxsemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$tmax[sfull$loc=="Centro"],lty=1,ylab="tmax",type='l',ylim=c(10,50),xlab="",axes=F) #AP1
axis(2)
title('AP1 (2011-2013)')
legend(50,20,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,30,40),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$tmax[sfull$loc=="Tijuca"],lty=1,col=2,ylab="tmax",type='l',ylim=c(10,50),xlab="",xlim=range(sfull$semana),axes=F) 
axis(2)
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$tmax[sfull$loc=="Sao Cristovao"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$tmax[sfull$loc=="Copacabana"],lty=1,col=3)
title('AP2 (2011-2013)')
legend(50,20,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,30,40),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$tmax[sfull$loc=="Iraja"],lty=1,ylab="tmax",type='l',ylim=c(10,50),xlab="",xlim=range(sfull$semana),axes=F) #AP1
axis(2)
axis(1)
title('AP3 (2012-2013)')
legend(50,20,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(20,30,40),lty=3)
mtext("Temp max",at=180,line=2,cex=1.4,col=6)
#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$tmax[sfull$loc=="Bangu"],lty=1,col=2,ylab="tmax",type='l',ylim=c(10,50),xlab="",xlim=range(sfull$semana),axes=F) 
axis(1)
axis(2)
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$tmax[sfull$loc=="Campo Grande"],lty=1,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$tmax[sfull$loc=="Pedra de Guaratiba"],lty=1,col=3)
title('AP5 (2012-2013)')
legend(50,20,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(20,30,40),lty=3)

# FigUmedsemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$umed[sfull$loc=="Centro"],lty=1,ylab="Umed",type='l',ylim=c(30,100),xlab="") #AP1
title('AP1 (2011-2013)')
legend(40,40,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$umed[sfull$loc=="Tijuca"],lty=1,col=2,ylab="Umed",type='l',ylim=c(30,100),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$umed[sfull$loc=="Sao Cristovao"],lty=2,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$umed[sfull$loc=="Copacabana"],lty=2,col=3)
title('AP2 (2011-2013)')
legend(40,45,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$umed[sfull$loc=="Iraja"],lty=1,ylab="umed",type='l',ylim=c(30,100),xlab="",xlim=range(sfull$semana)) #AP1
title('AP3 (2012-2013)')
legend(40,45,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)
mtext("Umid med",at=180,line=1,cex=1.4,col=6)

#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$umed[sfull$loc=="Bangu"],lty=1,col=2,ylab="umed",type='l',ylim=c(30,100),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$umed[sfull$loc=="Campo Grande"],lty=2,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$umed[sfull$loc=="Pedra de Guaratiba"],lty=2,col=3)
title('AP5 (2012-2013)')
legend(40,45,c("Bangu","Campo Grande","Pedra de Guaratiba"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(50,70,90),lty=3)

# FigmmChuvasemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$mmchuva[sfull$loc=="Centro"],lty=1,ylab="mmchuva",type='l',ylim=c(10,200),xlab="") #AP1
title('AP1 (2011-2013)')
legend(50,200,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,100,150),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$mmchuva[sfull$loc=="Tijuca"],lty=1,col=2,ylab="mmchuva",type='l',ylim=c(10,200),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$mmchuva[sfull$loc=="Sao Cristovao"],lty=3,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$mmchuva[sfull$loc=="Copacabana"],lty=3,col=3)
title('AP2 (2011-2013)')
legend(80,200,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(50,100,150),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$mmchuva[sfull$loc=="Iraja"],lty=1,ylab="mmchuva",type='l',ylim=c(10,200),xlab="",xlim=range(sfull$semana)) #AP1
title('AP3 (2012-2013)')
legend(10,200,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(50,100,150),lty=3)
mtext("mm Chuva",at=180,cex=1.4,col=6)
#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$mmchuva[sfull$loc=="Bangu"],lty=1,col=2,ylab="Tmin",type='l',ylim=c(10,200),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$mmchuva[sfull$loc=="Campo Grande"],lty=3,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$mmchuva[sfull$loc=="Pedra de Guaratiba"],lty=3,col=3)
title('AP5 (2012-2013)')
legend(10,200,c("Bangu","Campo Grande"),lty=1,col=c(2,4),cex=0.7,bty="n")
abline(h=c(50,100,150),lty=3)

# FigdiasChuvasemanal ######################################################
#AP1
par(mfrow=c(2,2),mar=c(2,2,2,2))
plot(sfull$semana[sfull$loc=="Centro"],sfull$diaschuva[sfull$loc=="Centro"]*24,lty=1,ylab="horaschuva",type='l',ylim=c(0,30),xlab="") #AP1
title('AP1 (2011-2013)')
legend(30,30,c("Centro"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(10,20),lty=3)

#AP2
plot(sfull$semana[sfull$loc=="Tijuca"],sfull$diaschuva[sfull$loc=="Tijuca"]*24,lty=1,col=2,ylab="horaschuva",type='l',ylim=c(0,30),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Sao Cristovao"],sfull$diaschuva[sfull$loc=="Sao Cristovao"]*24,lty=3,col=4)
lines(sfull$semana[sfull$loc=="Copacabana"],sfull$diaschuva[sfull$loc=="Copacabana"]*24,lty=3,col=3)
title('AP2 (2011-2013)')
legend(30,30,c("Tijuca","Sao Cristovao","Copa"),lty=1,col=c(2,4,3),cex=0.7,bty="n")
abline(h=c(10,20),lty=3)

#AP3
plot(sfull$semana[sfull$loc=="Iraja"],sfull$diaschuva[sfull$loc=="Iraja"]*24,lty=1,ylab="horaschuva",type='l',ylim=c(0,30),xlab="",xlim=range(sfull$semana)) #AP1
title('AP3 (2012-2013)')
legend(30,30,c("Iraja"),lty=1,col=1,cex=0.7,bty="n")
abline(h=c(10,20),lty=3)
mtext("horas Chuva",at=180,cex=1.4,col=6)

#AP5
plot(sfull$semana[sfull$loc=="Bangu"],sfull$diaschuva[sfull$loc=="Bangu"]*24,lty=1,col=2,ylab="horaschuva",type='l',ylim=c(0,30),xlab="",xlim=range(sfull$semana)) 
lines(sfull$semana[sfull$loc=="Campo Grande"],sfull$diaschuva[sfull$loc=="Campo Grande"]*24,lty=3,col=4)
lines(sfull$semana[sfull$loc=="Pedra de Guaratiba"],sfull$diaschuva[sfull$loc=="Pedra de Guaratiba"]*24,lty=3,col=3)
title('AP5 (2012-2013)')
legend(30,30,c("Bangu","Campo Grande"),lty=1,col=c(2,4),cex=0.7,bty="n")
abline(h=c(10,20),lty=3)


