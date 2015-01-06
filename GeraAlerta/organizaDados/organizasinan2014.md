#!/usr/bin/env Rscript

Organização dos dados do SINAN para o Alerta dengue
====================================================
A serie temporal 2010-13 ja esta pronta. Esse script agrega com a serie de 2014 em diante



Dados do SINAN 2014
--------------------


```r
novosinan <- paste("../",novosinan,sep="")
```


```
##      DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI      NM_BAIRRO
## 3810 2014-02-06  201406   2014 2014-02-02  201406       CURICICA
## 3811 2014-02-07  201406   2014 2014-02-06  201406          MEIER
## 3812 2014-01-21  201404   2014 2014-01-07  201402         CENTRO
## 3813 2014-01-23  201404   2014 2014-01-19  201404    VILA ISABEL
## 3814 2014-02-16  201408   2014 2014-02-14  201407 VILA VALQUEIRE
## 3815 2014-02-04  201406   2014 2014-02-02  201406   PADRE MIGUEL
## 3816 2014-01-10  201402   2014 2013-12-29  201401    COELHO NETO
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


