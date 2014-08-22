Gerador de alerta a nivel de Municipio (versão 1.0)
===================================================






**Hoje e' dia 2014-07-10, SE 201428**

Dados:
------


```r
dadosMRJ <- paste("../",dadosMRJ,sep="")
d<-read.csv(dadosMRJ)
tail(d)
```

```
##         SE casos tweets  tmin temp.sd temp.min temp.max umid.mean umid.sd
## 261 201420    63    105 21.49   3.244    17.00    27.14     70.18   15.61
## 262 201421    57     41 23.47   2.420    20.00    27.57     73.25   11.44
## 263 201422    38     80 21.17   2.059    18.43    25.00     77.14   10.58
## 264 201423    40     54 22.19   3.019    18.71    28.00     72.01   14.86
## 265 201424    19     49 23.37   2.706    19.43    27.86     72.66   12.77
## 266 201425     4     55 22.92   2.800    19.00    27.00     74.42   13.35
##     umid.min umid.max
## 261    40.86    88.86
## 262    53.29    87.57
## 263    56.14    91.57
## 264    45.43    89.71
## 265    48.29    89.86
## 266    51.00    94.00
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





- **Data do alerta: 201425**
- Arquivo de saida: ../alerta/alertaMRJ_201425.csv  


```r
write.table(df,file=outputfile,row.names=FALSE,sep=",")
```
