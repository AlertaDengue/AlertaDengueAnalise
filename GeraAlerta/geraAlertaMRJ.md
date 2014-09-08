Gerador de alerta a nivel de Municipio (versão 1.0)
===================================================






**Hoje e' dia 2014-08-25, SE 201435**

Dados:
------


```r
dadosMRJ <- paste("../",dadosMRJ,sep="")
d<-read.csv(dadosMRJ)
tail(d)
```

```
##         SE casos tweets temp.sd temp.min temp.max umid.mean umid.sd
## 239 201430    26     55   2.790    17.14    26.00     67.23   12.26
## 240 201431    39     54   2.471    16.14    23.86     77.39   11.20
## 241 201432    31     68   3.461    15.86    26.14     74.25   15.75
## 242 201433    30     47   3.149    16.29    25.57     76.34   12.48
## 243 201434     5     50   2.847    18.00    26.71     78.02   13.21
## 244 201435    NA     NA   5.140    17.00    32.00     68.50   25.40
##     umid.min umid.max estacao.1
## 239    44.14    84.57        NA
## 240    55.86    90.57        NA
## 241    46.71    93.29        NA
## 242    54.86    91.43        NA
## 243    52.86    93.29        NA
## 244    24.00    94.00        NA
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





- **Data do alerta: 201434**
- Arquivo de saida: ../alerta/alertaMRJ_201434.csv  


```r
write.table(df,file=outputfile,row.names=FALSE,sep=",")
```
