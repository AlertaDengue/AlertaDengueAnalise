# investigando a distribuicao do tempo serial de dengue usando dados de notificacao 
# intradomiciliar

# em teoria, o tempo serial deve ser composto do tempo que leva uma pessoa ficar doente até seu contato
# ficar doente. No caso de transmissao por vetor, dependerá:
# tempo desde ficar doente até ser picado + [0-5 dias]
# PIE do mosquito recem infectado +  [7-12 dias]
# tempo até o mosquito recem infectante picar alguem na casa+ [0-3 dias]
# tempo de incubacao intrinseco [3-7 dias]
# TOTAL: [10-27 dias]

# outra possibilidade e' que casos sejam irmaos de mesma geracao, isso é, dif tempo ate ser picado pelo mosquito
# digamos, de 0 (se ambos picado no mesmo dia) ate o tempo de vida do mosquito (7 dias, a grosso modo)


# juntando dados
d10<-read.csv2("Rt/dados/d10.csv")[,c("SEM_NOT","NU_ANO","DT_SIN_PRI","X","Y")]
d11<-read.csv2("Rt/dados/d11.csv")[,c("SEM_NOT","NU_ANO","DT_SIN_PRI","X","Y")]
d13<-read.csv2("Rt/dados/d13.csv")[,c("SEM_NOT","NU_ANO","DT_SIN_PRI","COORD_X","COORD_Y")]
names(d13)[4:5]<-c("X","Y")

str(d10)
str(d11)
str(d13)

d<-rbind(d10,d11,d13)
dim(d)  # 113054 registros
summary(d$X)
summary(d$Y)

# coords
# arrendondar para 10 - considerar igual aqueles com <10 de distancia
head(trunc(d$X))
d$X <- trunc(d$X)
d$Y <- trunc(d$Y)

d$xy = d$X+d$Y

# selecionar aquelas locs com mais de um caso - 
xydup=duplicated(d$xy)|duplicated(d$xy,fromLast = TRUE)
dup = d[which(xydup),]
head(dup[order(dup$xy),])

xdup=duplicated(dup$X)|duplicated(dup$X,fromLast = TRUE)
table(xdup)
dups = dup[which(xdup),]
dim(dups)  # 85766
dups<-dups[order(dups$xy,dups$X),]
head(dups)

plot(dups$X,dups$Y)

# criando numeracao para os domicilios
xy<-unique(dups$xy)
x <- unique(dups$x)
plot(x,y) # cada loc tem um xy unico, 
dups$dom <- NA
for (i in 1:dim(dups)[1]) dups$dom[i]<-which(xy==dups$xy[i]) 
dim(dups) # 857662

## selecionar os casos temporalmente proximos, < 60 dias
# 1) arrumar variavel data
class(dups$DT_SIN_PRI)
dups$dini<-as.Date(as.character(dups$DT_SIN_PRI),format="%d/%m/%y")
class(dups$dini)
head(dups$dini)

# 2) calcular o lag minimo entre casos na mesma loc e remover todos os casos distantes temporalmente

dups$minlag<-NA

for(i in 1:dim(dups)[1]){
  domi<-dups$dom[i] # domicilio do individuo
  dinii <- dups$dini[i] # dini do individuo
  du <- dups[-i,]  # tirando o proprio individuo
  casos <- du[du$dom==domi,] # casos no mesmo dom
  lag <- min(abs(casos$dini-dinii))
  dups$minlag[i]<-lag
}
 
dups<-dups[order(dups$dom),]

# remover os com infinito
dups2<-dups[is.finite(dups$minlag),]
dups60<-dups[dups$minlag<=60,]  #66578

# quando foi o primeiro caso do domicilio?
prim<-aggregate(dups60$dini,by=list(dom=dups60$dom),min)
names(prim)[2]<-"dini"
head(prim)

# tempos em relacao ao primeiro caso do domicilio:
dups60$tempo<-NA

for (i in 1:dim(dups60)[1]){
  domi = dups60$dom[i]
  dini = prim$dini[prim$dom==domi]
  dups60$tempo[i]<-dups60$dini[i]-dini

}

dups60<-na.omit(dups60)
hist(dups60$tempo)


# notei que as vezes o primeiro caso nao clusteriza temporalmente com os seguintes, mas os seguintes sim. Como automatizar isso?
# se duas pessoas com distancia maior que 60 dias - remover as duas
# se tres pessoas e a primeira tem distancia maior que 60 das outras, remover a primeira e recalcular

dups60$domsize<-NA # numero de pessoas no domicilio
for (i in 1:dim(dups60)[1]) dups60$domsize[i]<-sum(dups60$dom==dups60$dom[i])
head(dups60)
table(dups60$domsize)

### Clusters espaciais unicos
# estudar mais o cluster de 89 casos:
hist(dups60$tempo[dups60$domsize==89],breaks=50)

# estudar mais o cluster de 81 casos (sao dois clusters temporais):
hist(dups60$tempo[dups60$domsize==81],breaks=50)

# estudar mais o cluster de 76 casos:
hist(dups60$tempo[dups60$domsize==76],breaks=50)

# estudar mais o cluster de 74 casos:
hist(dups60$tempo[dups60$domsize==74],breaks=50)

# estudar mais o cluster de 65 casos:
hist(dups60$tempo[dups60$domsize==65],breaks=50)

# estudar mais o cluster de 54 casos (sao 3 clusters temporais):
hist(dups60$tempo[dups60$domsize==54],breaks=50)

# estudar mais o cluster de 52 casos (sao varios temporais):
hist(dups60$tempo[dups60$domsize==52],breaks=50)

# estudar mais o cluster de 51 casos (sao 2 clusters temporais):
hist(dups60$tempo[dups60$domsize==51],breaks=50)

# estudar mais os 2 clusters de 50 casos:
c50 <- dups60[dups60$domsize==50,] 
table(c50$dom)

# cluster de 50 com 2 temporais
hist(dups60$tempo[dups60$domsize==50 & dups60$dom==6009],breaks=50)

# cluster de 50 com 2 temporais
hist(dups60$tempo[dups60$domsize==50 & dups60$dom==7965],breaks=50)

# tem muito mais...


# analisando os clusters de 2
c2 <- subset(dups60,domsize==2)
hist(c2$tempo[c2$tempo>0],breaks=60,probability=TRUE,xlim=c(0,20))

