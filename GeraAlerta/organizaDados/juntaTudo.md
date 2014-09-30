#!/usr/bin/env Rscript

Junta todos os dados para o alerta
=====================================





**Hoje e' dia 2014-07-10, SE 201428**

Dados 
------

Casos de Dengue no MRJ


```r
dengueRJlimpo<-paste("../",dengueRJlimpo,sep="")
st<-read.csv(dengueRJlimpo)
```

Casos de Dengue por APS

```r
dengueAPSlimpo<-paste("../",dengueAPSlimpo,sep="")
st.ap<-read.csv(dengueAPSlimpo)
```

Tweets

```r
twlimpo<-paste("../",twlimpo,sep="")
tw<-read.csv(twlimpo)
```

Temperatura 

```r
climalimpo<-paste("../",climalimpo,sep="")
tempAP<-read.csv(climalimpo)
```


Tabela a nivel de municipio
---------------------------------







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
 



 


```r
write.table(d,file=outputfile,row.names=FALSE,sep=",")
```

Dados por APS
--------------
  






```
##          SE tweets   APS casos estacao temp.mean temp.sd temp.min temp.max
## 2655 201420    105 AP5.3     8  galeao     21.49   3.244    17.00    27.14
## 2656 201421     41 AP5.3    12  galeao     23.47   2.420    20.00    27.57
## 2657 201422     80 AP5.3     8  galeao     21.17   2.059    18.43    25.00
## 2658 201423     54 AP5.3     2  galeao     22.19   3.019    18.71    28.00
## 2659 201424     49 AP5.3     0  galeao     23.37   2.706    19.43    27.86
## 2660 201425     55 AP5.3     0  galeao     22.92   2.800    19.00    27.00
##      umid.mean umid.sd umid.min umid.max
## 2655     70.18   15.61    40.86    88.86
## 2656     73.25   11.44    53.29    87.57
## 2657     77.14   10.58    56.14    91.57
## 2658     72.01   14.86    45.43    89.71
## 2659     72.66   12.77    48.29    89.86
## 2660     74.42   13.35    51.00    94.00
```






```r
write.table(Rt.ap,file=outputfile,row.names=FALSE,sep=",")
```
