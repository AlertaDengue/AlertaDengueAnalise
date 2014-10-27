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
```

```
## Error: não foi possível encontrar a função "data2SE"
```

```r
# Agregar por semana
df<-aggregate(d[,2:3],by=list(SE=d$SE,estacao=d$estacao),FUN=mean,na.rm=TRUE)
```

```
## Error: arguments must have same length
```

```r
head(df)
```

```
##                                                   
## 1 function (x, df1, df2, ncp, log = FALSE)        
## 2 {                                               
## 3     if (missing(ncp))                           
## 4         .External(C_df, x, df1, df2, log)       
## 5     else .External(C_dnf, x, df1, df2, ncp, log)
## 6 }
```

```r
tail(df)
```

```
##                                                   
## 1 function (x, df1, df2, ncp, log = FALSE)        
## 2 {                                               
## 3     if (missing(ncp))                           
## 4         .External(C_df, x, df1, df2, log)       
## 5     else .External(C_dnf, x, df1, df2, ncp, log)
## 6 }
```



```
## Error: objeto de tipo 'closure' não possível dividir em subconjuntos
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

```
## Error: objeto 'dAP' não encontrado
```

Salvar:





```r
write.table(dAP,file="../dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
```

```
## Error: objeto 'dAP' não encontrado
```
