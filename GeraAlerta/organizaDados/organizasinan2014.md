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
##   DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI          NM_BAIRRO
## 1 2014-03-11  201411   2014 2014-03-08  201410   MAGALHAES BASTOS
## 2 2014-01-13  201403   2014 2014-01-13  201403       BRAS DE PINA
## 3 2014-03-12  201411   2014 2014-03-12  201411          GUARATIBA
## 4 2014-01-23  201404   2014 2014-01-20  201404 COMPLEXO DO ALEMAO
## 5 2014-02-26  201409   2014 2014-02-24  201409           CACHAMBI
## 6 2014-03-18  201412   2014 2014-03-14  201411         COPACABANA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 41
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 39 201439    39
## 40 201440    39
## 41 201441    42
## 42 201442    41
## 43 201443    30
## 44 201444    57
```


```
## [1] 2288
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


