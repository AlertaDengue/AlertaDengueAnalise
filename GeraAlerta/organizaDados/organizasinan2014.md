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
## 1 2014-09-04  201436   2014 2014-09-03  201436       PACIENCIA
## 2 2014-09-08  201437   2014 2014-08-23  201434    DEL CASTILHO
## 3 2014-01-11  201402   2014 2014-01-09  201402          MONERO
## 4 2014-03-19  201412   2014 2014-03-15  201411 MARECHAL HERMES
## 5 2014-04-05  201414   2014 2014-04-02  201414           MEIER
## 6 2014-01-15  201403   2014 2014-01-11  201402          TIJUCA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 219
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 46 201446    38
## 47 201447    50
## 48 201448    36
## 49 201449    43
## 50 201450    27
## 51 201451    11
```


```
## [1] 3597
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png) 

**Salvando**


