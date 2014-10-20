Organiza dados de temperatura do Alerta dengue 
===============================================
Usa dados do OpenWeather, atualmente so' de uma estacao, que e' replicado para
todas as APS



Abre dados OpenWeather (Oswaldo): 
-----------


```r
#novoclima <- novosinan <- paste("../",novoclima,sep="")
#d<-read.csv2(novoclima)
#galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")
#d <- galeao
#tail(d)
#d$estacao <- "galeao"
#Incluir variavel semana epidemiologica

d$SE<-data2SE(d$data,file="../tabelas/SE.csv",format="%Y-%m-%d")
#head(d[,c("data","SE")])
```


Abre dados weather underground (Flavio)
-----------------

```r
d<-read.csv(file="../dados_brutos/clima/galeao.csv")
tail(d)
```

```
##                   DateUTC Tmin
## 1748 2014-10-14T00:00:00Z 20.0
## 1749 2014-10-15T00:00:00Z 21.0
## 1750 2014-10-16T00:00:00Z 21.0
## 1751 2014-10-17T00:00:00Z 22.0
## 1752 2014-10-18T00:00:00Z 22.0
## 1753 2014-10-19T00:00:00Z 22.0
```

```r
d$dia<-strsplit(as.character(d$DateUTC,"T"))
```

```
## Error: argumento "split" ausente, sem padrão
```


Acumular por SE e estacao

```
## Error: undefined columns selected
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
## Error: não foi possível encontrar a função "xts"
```

```
## Error: objeto 'tmin.ts' não encontrado
```

```
## Error: plot.new has not been called yet
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

```
## Error: objeto 'dAP' não encontrado
```


```r
outputfile
```

```
## Error: objeto 'outputfile' não encontrado
```


```r
write.table(dAP,file="../dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
```

```
## Error: objeto 'dAP' não encontrado
```
