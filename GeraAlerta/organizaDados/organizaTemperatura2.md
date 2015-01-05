Organiza dados de temperatura do Alerta dengue 
===============================================
Usa dados do OpenWeather, atualmente so' de uma estacao, que e' replicado para
todas as APS



Abre dados OpenWeather (autor: Oswaldo): 
-----------


```r
#novoclima <- novosinan <- paste("../",novoclima,sep="")
#d<-read.csv2(novoclima)
#galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")
#d <- galeao
#tail(d)
#d$estacao <- "galeao"
#Incluir variavel semana epidemiologica

#d$SE<-data2SE(d$data,file="../tabelas/SE.csv",format="%Y-%m-%d")
#head(d[,c("data","SE")])

#Acumular por SE e estacao
#df<-aggregate(d[,3:10],by=list(estacao=d$estacao,SE=d$SE),FUN=mean,na.rm=TRUE)
#head(df)
```

```


Abre dados weather underground (autor: Flavio)
-----------------

```r
gal<-callmongoclima("galeao") 
std <- callmongoclima("santosdumont")
afo <- callmongoclima("afonsos")
jac <- callmongoclima("jacarepagua")

d<- rbind(gal,std,afo,jac)
rm(gal,std,afo,jac)

# Atribuir SE
d$SE<-data2SE(d$data,file="../tabelas/SE.csv",format="%Y-%m-%d")

# Agregar por semana
df<-aggregate(d[,2:3],by=list(SE=d$SE,estacao=d$estacao),FUN=mean,na.rm=TRUE)

head(df)
```

```
##       SE estacao       data     tmin
## 1 201001  galeao 2010-01-06 25.16667
## 2 201002  galeao 2010-01-13 24.42857
## 3 201003  galeao 2010-01-20 23.85714
## 4 201004  galeao 2010-01-27 23.71429
## 5 201005  galeao 2010-02-03 25.14286
## 6 201006  galeao 2010-02-10 24.66667
```

```r
tail(df)
```

```
##          SE     estacao       data     tmin
## 1033 201448 jacarepagua 2014-11-26 23.00000
## 1034 201449 jacarepagua 2014-12-03 21.28571
## 1035 201450 jacarepagua 2014-12-10 22.00000
## 1036 201451 jacarepagua 2014-12-17 21.57143
## 1037 201452 jacarepagua 2014-12-24 25.42857
## 1038 201453 jacarepagua 2014-12-31 25.42857
```




Salvar:





```r
write.table(dAP,file="../dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
```
