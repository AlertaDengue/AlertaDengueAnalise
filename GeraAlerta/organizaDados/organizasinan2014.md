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
## 1 2014-03-19  201412   2014 2014-03-14  201411 ENGENHEIRO LEAL
## 2 2014-03-07  201410   2014 2014-03-07  201410         TAQUARA
## 3 2014-01-03  201401   2014 2013-12-30  201401     VILA ISABEL
## 4 2014-02-21  201408   2014 2014-02-21  201408     LARANJEIRAS
## 5 2014-01-22  201404   2014 2014-01-11  201402          PAVUNA
## 6 2014-02-04  201406   2014 2014-02-04  201406         ANDARAI
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 218
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 45 201445    30
## 46 201446    35
## 47 201447    46
## 48 201448    31
## 49 201449    38
## 50 201450    14
```


```
## [1] 3553
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png) 

**Salvando**


