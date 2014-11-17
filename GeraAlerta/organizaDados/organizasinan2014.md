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
##   DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI        NM_BAIRRO
## 1 2014-02-28  201409   2014 2014-02-28  201409             <NA>
## 2 2014-02-27  201409   2014 2014-02-22  201408           TIJUCA
## 3 2014-03-05  201410   2014 2014-02-21  201408 JARDIM GUANABARA
## 4 2014-02-11  201407   2014 2014-02-09  201407    VIGARIO GERAL
## 5 2014-03-11  201411   2014 2014-03-07  201410            MEIER
## 6 2014-01-30  201405   2014 2014-01-28  201405            BANGU
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 42
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 41 201441    41
## 42 201442    49
## 43 201443    47
## 44 201444    80
## 45 201445    19
## 46 201446     8
```


```
## [1] 2376
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


