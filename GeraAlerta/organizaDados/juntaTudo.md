#!/usr/bin/env Rscript

Junta todos os dados para o alerta
=====================================





**Hoje e' dia 2014-08-22, SE 201434**

Dados 
------




Tabela a nivel de municipio
---------------------------------







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
 



 


```r
write.table(d,file=outputfile,row.names=FALSE,sep=",")
```

Dados por APS
--------------
  






```
##          SE tweets   APS casos estacao temp.mean temp.sd temp.min temp.max
## 2415 201428     61 AP5.3     0  galeao     21.36   1.825       19    24.83
## 2416 201429     56 AP5.3     2  galeao     20.88   2.250       18    25.00
## 2417 201430     55 AP5.3     3    <NA>        NA      NA       NA       NA
## 2418 201431     54 AP5.3     7    <NA>        NA      NA       NA       NA
## 2419 201432     68 AP5.3    10    <NA>        NA      NA       NA       NA
## 2420 201433     47 AP5.3     0    <NA>        NA      NA       NA       NA
##      umid.mean umid.sd umid.min umid.max
## 2415     77.77   9.377     58.5    89.17
## 2416     68.58  11.840     50.0    88.00
## 2417        NA      NA       NA       NA
## 2418        NA      NA       NA       NA
## 2419        NA      NA       NA       NA
## 2420        NA      NA       NA       NA
```






```r
write.table(Rt.ap,file=outputfile,row.names=FALSE,sep=",")
```
