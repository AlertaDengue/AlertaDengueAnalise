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
## 1 2014-01-01  201401   2014 2013-12-30  201401  PADRE MIGUEL
## 2 2014-01-01  201401   2014 2013-12-31  201401      INHOAIBA
## 3 2014-01-01  201401   2014 2013-12-27  201352         BANGU
## 4 2014-01-01  201401   2014 2014-01-01  201401  PADRE MIGUEL
## 5 2014-01-02  201401   2014 2013-12-27  201352         IRAJA
## 6 2014-01-02  201401   2014 2014-01-02  201401 FREGUESIAILHA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 202
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 37 201437    40
## 38 201438    49
## 39 201439    42
## 40 201440    39
## 41 201441    30
## 42 201442     3
```


```
## [1] 3044
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


