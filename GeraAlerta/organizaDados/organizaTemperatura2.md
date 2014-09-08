Organiza dados de temperatura do Alerta dengue 
===============================================
Usa dados do OpenWeather, atualmente so' de uma estacao, que e' replicado para
todas as APS



Abre dados: 
-----------


```r
#novoclima <- novosinan <- paste("../",novoclima,sep="")
#d<-read.csv2(novoclima)
galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")
d <- galeao
tail(d)
```

```
##            data temp.mean temp.sd temp.min temp.max umid.mean umid.sd
## 1669 2014-08-19     21.00    1.14       19       23     82.04    6.74
## 1670 2014-08-20     21.54    1.74       20       25     75.88    8.22
## 1671 2014-08-21     21.16    2.79       17       26     81.36   13.47
## 1672 2014-08-22     22.37    4.85       17       31     75.74   22.79
## 1673 2014-08-23     22.71    4.03       17       30     74.38   18.56
## 1674 2014-08-24     23.75    5.14       17       32     68.50   25.40
##      umid.min umid.max
## 1669       69       94
## 1670       57       83
## 1671       54       94
## 1672       38      100
## 1673       33       94
## 1674       24       94
```



Incluir variavel semana epidemiologica



Acumular por SE e estacao

```
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
## Warning: argument is not numeric or logical: returning NA
```

```
##   estacao     SE temp.sd temp.min temp.max umid.mean umid.sd umid.min
## 1  galeao 201001   2.787    25.14    33.43     73.75   12.18    51.71
## 2  galeao 201002   3.253    24.71    34.57     70.36   13.72    46.57
## 3  galeao 201003   3.500    23.86    34.57     71.28   13.68    45.86
## 4  galeao 201004   3.157    24.00    33.43     73.20   12.57    47.86
## 5  galeao 201005   3.836    25.14    36.43     63.73   15.69    38.14
## 6  galeao 201006   3.970    25.00    36.86     61.60   16.47    33.71
##   umid.max estacao
## 1    89.71      NA
## 2    90.71      NA
## 3    88.29      NA
## 4    88.71      NA
## 5    85.29      NA
## 6    84.71      NA
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 




Salvar:



```r
outputfile
```

```
## [1] "../dados_limpos/temp_201435.csv"
```


```r
write.table(dAP,file="../dados_limpos/climasemanaRJ.csv",sep=",",row.names=FALSE)
```
