Gerador de alerta a nivel de Municipio (versão 1.0)
===================================================






**Hoje e' dia 2014-08-22, SE 201434**

Dados:
------


```r
dadosMRJ <- paste("../",dadosMRJ,sep="")
d<-read.csv(dadosMRJ)
tail(d)
```

```
##         SE casos tweets temp.mean temp.sd temp.min temp.max umid.mean
## 237 201428    25     61     21.36   1.825       19    24.83     77.77
## 238 201429    26     56     20.88   2.250       18    25.00     68.58
## 239 201430    24     55        NA      NA       NA       NA        NA
## 240 201431    41     54        NA      NA       NA       NA        NA
## 241 201432    29     68        NA      NA       NA       NA        NA
## 242 201433     2     47        NA      NA       NA       NA        NA
##     umid.sd umid.min umid.max
## 237   9.377     58.5    89.17
## 238  11.840     50.0    88.00
## 239      NA       NA       NA
## 240      NA       NA       NA
## 241      NA       NA       NA
## 242      NA       NA       NA
```


**Rt(dengue)**


![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

**Rt(tweets), com tg=2**


![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 




Predição
========

**Modelo de alerta com 3 indicadores**

- Rt > 1 
- Casos > Media + 1.96dp
- Temperatura mínima semanal > 24 graus  

1. Estimação de Rt (dengue) a partir dos dados de tweet e clima
----------------------------------------------------------------------------------------
lm(Rt~Rtw*temp.min,data=d)

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 

**Rt.est>1**

```r
d$alertaRt1 <-ifelse(d$Rt_est>1,1,0)
```

**Temperatura min > Tcrit** 
d$temp e' a variavel que vai para o bd final


```r
d$temp <- d$temp.min 
d$temp_crit<-22
d$alertaTemp <-ifelse(d$temp>d$temp_crit,1,0)
```

2. Estimacao de casos a partir do Rt: casos(t+1)=casos(t)*Rt
-------------------------------------------------------------

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 

**Casos > media+1.96dp**


```r
limiarinc<-mean(d$casos,na.rm=TRUE)+1.96*sd(d$casos,na.rm=TRUE)
d$casos_crit<-limiarinc
d$alertaCasos<-ifelse(d$casos_est>d$casos_crit,1,0)
```


Salvar
======

Primeiro, cortar a parte final que nao tenha os 3 alertas:





- **Data do alerta: 201429**
- Arquivo de saida: ../alerta/alertaMRJ_201429.csv  


```r
write.table(df,file=outputfile,row.names=FALSE,sep=",")
```
