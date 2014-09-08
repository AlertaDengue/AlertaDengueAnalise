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
## 1 2014-01-15  201403   2014 2014-01-11  201402          PILARES
## 2 2014-02-16  201408   2014 2014-02-14  201407        PACIENCIA
## 3 2014-01-24  201404   2014 2014-01-22  201404          TURIACU
## 4 2014-01-15  201403   2014 2014-01-14  201403 MAGALHAES BASTOS
## 5 2014-01-21  201404   2014 2014-01-19  201404         REALENGO
## 6 2014-01-11  201402   2014 2014-01-11  201402       PRACA SECA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 46
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 29 201429    25
## 30 201430    26
## 31 201431    39
## 32 201432    31
## 33 201433    30
## 34 201434     5
```

**Total de casos no ano**


```
## [1] 1927
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


