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
##   DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI     NM_BAIRRO
## 1 2014-03-19  201412   2014 2014-01-08  201402      ABOLICAO
## 2 2014-03-03  201410   2014 2014-02-26  201409        GALEAO
## 3 2014-03-26  201413   2014 2014-03-26  201413    PORTUGUESA
## 4 2014-04-07  201415   2014 2014-04-02  201414     PACIENCIA
## 5 2014-03-19  201412   2014 2014-03-12  201411 VILA DA PENHA
## 6 2014-04-04  201414   2014 2014-04-02  201414      INHOAIBA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 43
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 38 201438    32
## 39 201439    39
## 40 201440    38
## 41 201441    36
## 42 201442    34
## 43 201443    16
```


```
## [1] 2197
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


