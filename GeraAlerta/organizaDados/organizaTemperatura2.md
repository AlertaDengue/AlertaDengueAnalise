Organiza dados de temperatura do Alerta dengue 
===============================================
Usa dados do OpenWeather, atualmente so' de uma estacao, que e' replicado para
todas as APS



Abre dados: 
-----------


```r
novoclima <- novosinan <- paste("../",novoclima,sep="")
d<-read.csv2(novoclima)
tail(d)
```

```
##            data temp.mean temp.sd temp.min temp.max umid.mean umid.sd
## 1620 2014-06-10     22.48    0.89       21       24     80.93    8.43
## 1621 2014-06-11     22.92    2.10       21       27     79.79   13.77
## 1622 2014-06-12     22.96    2.22       19       27     76.46    9.67
## 1623 2014-06-13     23.17    2.32       20       27     74.88   10.28
## 1624 2014-06-14     22.67    3.32       18       28     70.62   12.93
## 1625 2014-06-15     22.92    2.80       19       27     74.42   13.35
##      umid.min umid.max
## 1620       57       94
## 1621       51       94
## 1622       58       94
## 1623       58       88
## 1624       45       88
## 1625       51       94
```



Incluir variavel semana epidemiologica



Acumular por SE e estacao

```
##   estacao     SE temp.mean temp.sd temp.min temp.max umid.mean umid.sd
## 1  galeao 201001     28.65   2.787    25.14    33.43     73.75   12.18
## 2  galeao 201002     29.05   3.253    24.71    34.57     70.36   13.72
## 3  galeao 201003     28.36   3.500    23.86    34.57     71.28   13.68
## 4  galeao 201004     27.72   3.157    24.00    33.43     73.20   12.57
## 5  galeao 201005     30.04   3.836    25.14    36.43     63.73   15.69
## 6  galeao 201006     30.16   3.970    25.00    36.86     61.60   16.47
##   umid.min umid.max
## 1    51.71    89.71
## 2    46.57    90.71
## 3    45.86    88.29
## 4    47.86    88.71
## 5    38.14    85.29
## 6    33.71    84.71
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 




Salvar:



```r
outputfile
```

```
## [1] "../dados_limpos/temp_201425.csv"
```


```r
write.table(dAP,file=outputfile,sep=",",row.names=FALSE)
```
