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
## 1 2014-02-03  201406   2014 2014-01-31  201405 CENTRO MESQUITA
## 2 2014-02-03  201406   2014 2014-02-01  201405 CENTRO MESQUITA
## 3 2014-01-22  201404   2014 2014-01-15  201403 CENTRO MESQUITA
## 4 2014-06-18  201425   2014 2014-05-25  201422    EDSON PASSOS
## 5 2014-01-31  201405   2014 2014-01-29  201405          CENTRO
## 6 2014-05-21  201421   2014 2014-05-19  201421            <NA>
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 209
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 40 201440    57
## 41 201441    59
## 42 201442    69
## 43 201443    52
## 44 201444    88
## 45 201445    11
```


```
## [1] 3347
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


