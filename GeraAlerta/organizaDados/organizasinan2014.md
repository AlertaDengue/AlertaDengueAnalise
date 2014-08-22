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
##   DT_NOTIFIC SEM_NOT NU_ANO DT_SIN_PRI SEM_PRI    NM_BAIRRO
## 1 2014-01-07  201402   2014 2014-01-04  201401 DEL CASTILHO
## 2 2014-01-13  201403   2014 2014-01-12  201403        PENHA
## 3 2014-01-15  201403   2014 2014-01-13  201403        BANGU
## 4 2014-01-02  201401   2014 2013-12-26  201352   COPACABANA
## 5 2014-01-03  201401   2014 2013-11-18  201347      ANDARAI
## 6 2014-01-15  201403   2014 2014-01-12  201403        BANGU
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 147
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 51 201420    63
## 52 201421    57
## 53 201422    38
## 54 201423    40
## 55 201424    19
## 56 201425     4
```

**Total de casos no ano**


```
## [1] 2185
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**



```r
outputfile1
```

```
## [1] "../dados_limpos/sinanAP_201425.csv"
```

```r
outputfile2
```

```
## [1] "../dados_limpos/sinanRJ_201425.csv"
```
