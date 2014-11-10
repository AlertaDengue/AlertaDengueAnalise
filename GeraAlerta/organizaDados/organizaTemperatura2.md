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
```

```
## Warning: This fails for most NoSQL data structures. I am working on a new
## solution
```

```r
std <- callmongoclima("santosdumont")
```

```
## Warning: This fails for most NoSQL data structures. I am working on a new
## solution
```

```r
afo <- callmongoclima("afonsos")
```

```
## Warning: This fails for most NoSQL data structures. I am working on a new
## solution
```

```r
jac <- callmongoclima("jacarepagua")
```

```
## Warning: This fails for most NoSQL data structures. I am working on a new
## solution
```

```r
d<- rbind(gal,std,afo,jac)
rm(gal,std,afo,jac)

# Atribuir SE
d$SE<-data2SE(d$data,file="../tabelas/SE.csv",format="%Y-%m-%d")

# Agregar por semana
df<-aggregate(d[,2:3],by=list(SE=d$SE,estacao=d$estacao),FUN=mean,na.rm=TRUE)

head(df)
```

```
##       SE estacao       data tempmin
## 1 201001  galeao 2010-01-06   25.17
## 2 201002  galeao 2010-01-13   24.43
## 3 201003  galeao 2010-01-20   23.86
## 4 201004  galeao 2010-01-27   23.71
## 5 201005  galeao 2010-02-03   25.14
## 6 201006  galeao 2010-02-10   24.67
```

```r
tail(df)
```

```
##          SE     estacao       data tempmin
## 1005 201441 jacarepagua 2014-10-08   18.71
## 1006 201442 jacarepagua 2014-10-15   21.00
## 1007 201443 jacarepagua 2014-10-22   20.14
## 1008 201444 jacarepagua 2014-10-29   20.50
## 1009 201445 jacarepagua 2014-11-05   22.71
## 1010 201446 jacarepagua 2014-11-09   22.00
```




Salvar:





```r
write.table(dAP,file="../dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
```
