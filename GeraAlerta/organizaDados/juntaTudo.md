#!/usr/bin/env Rscript

Junta todos os dados para o alerta
=====================================





**Hoje e' dia 2014-10-01, SE 201440**

Dados 
------




Tabela a nivel de municipio
---------------------------------







```
##         SE casos tweets temp.sd temp.min temp.max umid.mean umid.sd
## 243 201434    31     47   2.847       18    26.71     78.02   13.21
## 244 201435    35     81   5.140       17    32.00     68.50   25.40
## 245 201436    33     46      NA       NA       NA        NA      NA
## 246 201437    26     45      NA       NA       NA        NA      NA
## 247 201438    33     57      NA       NA       NA        NA      NA
## 248 201439     4     82      NA       NA       NA        NA      NA
##     umid.min umid.max estacao.1
## 243    52.86    93.29        NA
## 244    24.00    94.00        NA
## 245       NA       NA        NA
## 246       NA       NA        NA
## 247       NA       NA        NA
## 248       NA       NA        NA
```
 



 


```r
write.table(d,file=outputfile,row.names=FALSE,sep=",")
```

Dados por APS
--------------
  






```
##          SE tweets   APS casos estacao temp.sd temp.min temp.max umid.mean
## 2475 201434     47 AP5.3     6  galeao   2.847       18    26.71     78.02
## 2476 201435     81 AP5.3     5  galeao   5.140       17    32.00     68.50
## 2477 201436     46 AP5.3     3    <NA>      NA       NA       NA        NA
## 2478 201437     45 AP5.3     3    <NA>      NA       NA       NA        NA
## 2479 201438     57 AP5.3     3    <NA>      NA       NA       NA        NA
## 2480 201439     82 AP5.3     0    <NA>      NA       NA       NA        NA
##      umid.sd umid.min umid.max estacao.1
## 2475   13.21    52.86    93.29        NA
## 2476   25.40    24.00    94.00        NA
## 2477      NA       NA       NA        NA
## 2478      NA       NA       NA        NA
## 2479      NA       NA       NA        NA
## 2480      NA       NA       NA        NA
```






```r
write.table(Rt.ap,file=outputfile,row.names=FALSE,sep=",")
```
