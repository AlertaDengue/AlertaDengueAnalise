#!/usr/bin/env Rscript

Junta todos os dados para o alerta
=====================================





**Hoje e' dia 2014-10-20, SE 201443**

Dados 
------




Tabela a nivel de municipio
---------------------------------







```
##         SE casos tweets temp.sd temp.min temp.max umid.mean umid.sd
## 280 201436    51     53      NA       NA       NA        NA      NA
## 281 201437    42     45      NA       NA       NA        NA      NA
## 282 201438    44     57      NA       NA       NA        NA      NA
## 283 201439    42     80      NA       NA       NA        NA      NA
## 284 201440    26     65      NA       NA       NA        NA      NA
## 285 201441     6    143      NA       NA       NA        NA      NA
##     umid.min umid.max estacao.1
## 280       NA       NA        NA
## 281       NA       NA        NA
## 282       NA       NA        NA
## 283       NA       NA        NA
## 284       NA       NA        NA
## 285       NA       NA        NA
```
 



 


```r
write.table(d,file=outputfile,row.names=FALSE,sep=",")
```

Dados por APS
--------------
  






```
##          SE tweets   APS casos estacao temp.sd temp.min temp.max umid.mean
## 2821 201412     92 AP5.3     6  galeao   3.766    23.71    35.71     57.57
## 2822 201413     63 AP5.3     7  galeao   1.919    21.86    27.86     76.40
## 2823 201414     65 AP5.3     7  galeao   2.187    22.71    30.14     74.99
## 2824 201415     76 AP5.3     8  galeao   3.010    21.57    30.86     68.70
## 2825 201416     62 AP5.3     6  galeao   1.896    22.14    27.86     78.35
## 2826 201417     64 AP5.3     5  galeao   1.929    21.57    28.29     72.70
## 2827 201418     88 AP5.3     9  galeao   3.401    17.29    27.57     66.19
## 2828 201419    159 AP5.3    16  galeao   2.674    20.14    28.71     74.62
## 2829 201420    114 AP5.3    11  galeao   3.244    17.00    27.14     70.18
## 2830 201421     92 AP5.3    13  galeao   2.420    20.00    27.57     73.25
## 2831 201422     80 AP5.3    11  galeao   2.059    18.43    25.00     77.14
## 2832 201423     61 AP5.3     3  galeao   3.019    18.71    28.00     72.01
## 2833 201424     62 AP5.3     6  galeao   2.706    19.43    27.86     72.66
## 2834 201425     63 AP5.3     5  galeao   2.800    19.00    27.00     74.42
## 2835 201426     80 AP5.3     1    <NA>      NA       NA       NA        NA
## 2836 201427     44 AP5.3     2    <NA>      NA       NA       NA        NA
## 2837 201428     62 AP5.3     1  galeao   1.825    19.00    24.83     77.77
## 2838 201429     55 AP5.3     3  galeao   2.924    17.14    26.00     67.74
## 2839 201430     60 AP5.3     2  galeao   2.790    17.14    26.00     67.23
## 2840 201431     64 AP5.3     5  galeao   2.471    16.14    23.86     77.39
## 2841 201432     64 AP5.3    11  galeao   3.461    15.86    26.14     74.25
## 2842 201433     42 AP5.3     0  galeao   3.149    16.29    25.57     76.34
## 2843 201434     58 AP5.3     8  galeao   2.847    18.00    26.71     78.02
## 2844 201435     81 AP5.3     5  galeao   5.140    17.00    32.00     68.50
## 2845 201436     53 AP5.3     6    <NA>      NA       NA       NA        NA
## 2846 201437     45 AP5.3     4    <NA>      NA       NA       NA        NA
## 2847 201438     57 AP5.3     3    <NA>      NA       NA       NA        NA
## 2848 201439     80 AP5.3     1    <NA>      NA       NA       NA        NA
## 2849 201440     65 AP5.3     1    <NA>      NA       NA       NA        NA
## 2850 201441    143 AP5.3     0    <NA>      NA       NA       NA        NA
##      umid.sd umid.min umid.max estacao.1
## 2821  16.076    31.14    81.14        NA
## 2822   9.814    59.43    90.00        NA
## 2823  10.597    54.14    90.29        NA
## 2824  14.104    42.57    88.71        NA
## 2825   8.726    61.29    91.14        NA
## 2826  11.161    54.86    89.43        NA
## 2827  16.626    38.00    90.71        NA
## 2828  12.987    50.57    89.86        NA
## 2829  15.610    40.86    88.86        NA
## 2830  11.444    53.29    87.57        NA
## 2831  10.579    56.14    91.57        NA
## 2832  14.864    45.43    89.71        NA
## 2833  12.771    48.29    89.86        NA
## 2834  13.350    51.00    94.00        NA
## 2835      NA       NA       NA        NA
## 2836      NA       NA       NA        NA
## 2837   9.377    58.50    89.17        NA
## 2838  13.986    42.86    87.43        NA
## 2839  12.261    44.14    84.57        NA
## 2840  11.201    55.86    90.57        NA
## 2841  15.750    46.71    93.29        NA
## 2842  12.484    54.86    91.43        NA
## 2843  13.207    52.86    93.29        NA
## 2844  25.400    24.00    94.00        NA
## 2845      NA       NA       NA        NA
## 2846      NA       NA       NA        NA
## 2847      NA       NA       NA        NA
## 2848      NA       NA       NA        NA
## 2849      NA       NA       NA        NA
## 2850      NA       NA       NA        NA
```



```
## [1] "../dados_limpos/dadosAPS_201441.csv"
```



```r
write.table(Rt.ap,file=outputfile,row.names=FALSE,sep=",")
```
