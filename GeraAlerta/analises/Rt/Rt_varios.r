# Testando diferentes formulas de Rt
# ==============================================

#### IMPORTAR DADOS #################################################
require(foreign)

#Dados de 2010 a 2013
d10 <- read.dbf(file="../../dados_brutos/sinan/old/Dengue2010_BancoSINAN16_04_2012_v09012014.dbf")[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA","SEM_PRI")]
d11 <- read.dbf(file="../../dados_brutos/sinan/old/Dengue2011_BancoSINAN14_10_2013_v09012014.dbf")[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA","SEM_PRI")]
d12 <- read.dbf(file="../../dados_brutos/sinan/old/Dengue2012_BancoSINAN09_09_2013_v09012014.dbf")[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA","SEM_PRI")]
d13 <- read.dbf(file="../../dados_brutos/sinan/old/Dengue2013_BancoSINAN30_12_2013.dbf")[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA","SEM_PRI")]
d14 <- read.dbf(file="../../dados_brutos/sinan/old/DENGON2014_02_01_2015.dbf")[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI","DT_DIGITA","SEM_PRI")]

d<-rbind(d10,d11,d12,d13,d14)
rm(d10,d11,d12,d13,d14)
n1<-dim(d)[1]

# Calcula série temporal
st <- aggregate(d$SEM_PRI,by=list(d$SEM_PRI),FUN=length)
names(st)<-c("SE","casos")
st$SE<-as.numeric(as.character(st$SE))
tail(st)

#==================================================
library(R0)
inc<-check.incid(st$casos,st$SE)
# A funcao est.R0.DT calcula Rt
mGT<-generation.time("lognormal", c(23, 6))
plot(mGT)
mGTweek<-c(sum(mGT$GT[1:7]),sum(mGT$GT[2:14]),sum(mGT$GT[15:21]),sum(mGT$GT[22:28]),sum(mGT$GT[29:35]),sum(mGT$GT[36:42]))
barplot(mGTweek)
Rt<-est.R0.TD(inc$incid,generation.time(type="empirical",val=mGTweek))
Rt

