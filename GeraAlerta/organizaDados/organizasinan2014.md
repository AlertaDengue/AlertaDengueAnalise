#!/usr/bin/env Rscript

Organização dos dados do SINAN para o Alerta dengue
====================================================
A serie temporal 2010-13 ja esta pronta. Esse script agrega com a serie de 2014



Dados do SINAN 2014
--------------------


```r
novosinan <- paste("../",novosinan,sep="")
```


```
##   DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI       NM_BAIRRO
## 1 2014-04-29  201418   2014 2014-04-28  201418            PARI
## 2 2014-02-27  201409   2014 2014-02-20  201408            <NA>
## 3 2014-02-18  201408   2014 2014-02-15  201407 COELHO DA ROCHA
## 4 2014-03-14  201411   2014 2014-03-11  201411     VILA ROSALI
## 5 2014-03-14  201411   2014 2014-03-08  201410          CENTRO
## 6 2014-04-01  201414   2014 2014-03-14  201411       TOMAZINHO
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 214
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 42 201442    71
## 43 201443    58
## 44 201444    95
## 45 201445    29
## 46 201446    22
## 47 201447    11
```


```
## [1] 3415
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png) 

**Salvando**


