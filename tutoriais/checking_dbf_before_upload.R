## script usado para converter datas no csv ###

library(foreign)
library(lubridate) 

# colocar o nome do arquivo
den23<-read.csv2("BR-DEN-2023-12-15-2023.csv")
str(den23)

den23$DT_NOTIFIC <- ymd(den23$DT_NOTIFIC)
den23$DT_SIN_PRI<- ymd(den23$DT_SIN_PRI)
den23$DT_NASC <- ymd(den23$DT_NASC)
den23$DT_INVEST <- ymd(den23$DT_INVEST)
den23$DT_ALRM <- ymd(den23$DT_ALRM)
den23$DT_CHIK_S1<- ymd(den23$DT_CHIK_S1)
den23$DT_CHIK_S2<- ymd(den23$DT_CHIK_S2)
den23$DT_ENCERRA <- ymd(den23$DT_ENCERRA)
den23$DT_GRAV<- ymd(den23$DT_GRAV)
den23$DT_INTERNA<- ymd(den23$DT_INTERNA)
den23$DT_NS1<-ymd(den23$DT_NS1)
den23$DT_OBITO <-ymd(den23$DT_OBITO)
den23$DT_PCR<-ymd(den23$DT_PCR)
den23$DT_PRNT<-ymd(den23$DT_PRNT)
den23$DT_SORO<-ymd(den23$DT_SORO)
den23$DT_VIRAL<-ymd(den23$DT_VIRAL)
den23$DT_DIGITA <- ymd(den23$DT_DIGITA)
str(den23)
# salvar como dbf (ver formato do arquivo)
write.dbf(den23,"BR-DEN-2023-12-15-2023.dbf")
