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
## 1 2014-01-01  201401   2014 2014-01-01  201401  PADRE MIGUEL
## 2 2014-01-02  201401   2014 2014-01-01  201401         IRAJA
## 3 2014-01-02  201401   2014 2014-01-02  201401 FREGUESIAILHA
## 4 2014-01-02  201401   2014 2014-01-01  201401        TIJUCA
## 5 2014-01-02  201401   2014 2014-01-01  201401      REALENGO
## 6 2014-01-02  201401   2014 2014-01-01  201401        TIJUCA
```


**Criar variavel APS**



Numero de registros sem AP (falha no mapeamento bairro -> APS)

```
## [1] 50
```


**Serie temporal de casos no municipio todo em 2014**


```
##        SE casos
## 34 201434    31
## 35 201435    35
## 36 201436    33
## 37 201437    26
## 38 201438    33
## 39 201439     4
```

**Total de casos no ano**


```
## [1] 2058
```





**Serie temporal de casos na cidade**
![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 


**Serie temporal de casos por APS**
![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 

**Salvando**


