Alerta de Dengue para o Rio de Janeiro
======================
versao 0.2






**Hoje e' dia 2014-10-20 , SE 201443**



**Curvas epidemica da dengue na cidade**




Os ultimos dados disponiveis de casos de dengue se referem a'semana 201441:


![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 




**Tweet na cidade**



Os ultimos dados disponiveis de tweet sao da semana 201442:


```
##          SE tweets
## 2865 201438     62
## 2866 201439     80
## 2867 201440     65
## 2868 201441    143
## 2869 201442    105
## 2870 201443     NA
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

** Dados de temperatura mínima e máxima por APS**



Os ultimos dados disponiveis de temperatura minima sao da semana 201443. 






![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12.png) 




Modelo de alerta com 5 indicadores
========

- AlertaCli = Temperatura minima semanal > 22 graus por 3 semanas
- Alertatweet = crescimento significativo de tweet na ultima semana
- AlertaRt =  (Rt > 1) por 3 semanas. Se nao houver notificacao, completar com o Rt dos tweets
- AlertaCasos = Casos > limiar de epidemia (100 por 100.000) 
- Rm = Mosquitos que aumentam significativamente (a fazer) 












**Grafico de Prob(Rt > 1)**

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 




**Alerta por APS**

Para cada APS, indica-se as semanas em que houve alerta de temperatura, de Rt e de casos.

```
## [1] "AP1"
##         SE APS alertaCli alertaRtweet alertaRt alertaCasos
## 241 201436 AP1         0            0        0           0
## 225 201437 AP1         0            0        0           0
## 265 201438 AP1         0            0        0           0
## 245 201439 AP1         0            1        0           0
## 268 201440 AP1         0            1        0           0
## 239 201441 AP1         0            2        0           0
## 294 201442 AP1         0            2        0           0
## 285 201443 AP1         0           NA       NA           0
```

```
## [1] "AP2.1"
##         SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 540 201436 AP2.1         0            0        0           0
## 589 201437 AP2.1         0            0        0           0
## 582 201438 AP2.1         0            0        0           0
## 557 201439 AP2.1         0            1        0           0
## 580 201440 AP2.1         0            1        0           0
## 599 201441 AP2.1         0            2        0           0
## 596 201442 AP2.1         0            2        0           0
## 597 201443 AP2.1         0           NA       NA           0
```

```
## [1] "AP2.2"
##         SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 798 201436 AP2.2         0            0        0           0
## 908 201437 AP2.2         0            0        0           0
## 903 201438 AP2.2         0            0        0           0
## 842 201439 AP2.2         0            1        0           0
## 812 201440 AP2.2         0            1        0           0
## 891 201441 AP2.2         0            2        0           0
## 878 201442 AP2.2         0            2        0           0
## 843 201443 AP2.2         0           NA       NA           0
```

```
## [1] "AP3.1"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 1028 201436 AP3.1         0            0        0           0
## 1202 201437 AP3.1         0            0        0           0
## 1193 201438 AP3.1         0            0        0           0
## 1019 201439 AP3.1         0            1        0           0
## 1042 201440 AP3.1         0            1        0           0
## 1203 201441 AP3.1         0            2        0           0
## 1207 201442 AP3.1         0            2        0           0
## 1087 201443 AP3.1         0           NA       NA           0
```

```
## [1] "AP3.2"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 1363 201436 AP3.2         0            0        0           0
## 1460 201437 AP3.2         0            0        0           0
## 1444 201438 AP3.2         0            0        0           0
## 1275 201439 AP3.2         0            1        0           0
## 1282 201440 AP3.2         0            1        0           0
## 1500 201441 AP3.2         0            2        0           0
## 1447 201442 AP3.2         0            2        0           0
## 1454 201443 AP3.2         0           NA       NA           0
```

```
## [1] "AP3.3"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 1646 201436 AP3.3         0            0        0           0
## 1798 201437 AP3.3         0            0        0           0
## 1743 201438 AP3.3         0            0        0           0
## 1736 201439 AP3.3         0            1        1           0
## 1594 201440 AP3.3         0            1        1           0
## 1812 201441 AP3.3         0            2        1           0
## 1757 201442 AP3.3         0            2        1           0
## 1752 201443 AP3.3         0           NA       NA           0
```

```
## [1] "AP4"
##          SE APS alertaCli alertaRtweet alertaRt alertaCasos
## 1954 201436 AP4         0            0        0           0
## 2038 201437 AP4         0            0        0           0
## 2090 201438 AP4         0            0        0           0
## 2099 201439 AP4         0            1        0           0
## 1870 201440 AP4         1            1        0           0
## 2065 201441 AP4         1            2        0           0
## 2051 201442 AP4         1            2        0           0
## 2102 201443 AP4         0           NA       NA           0
```

```
## [1] "AP5.1"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 2202 201436 AP5.1         0            0        0           0
## 2402 201437 AP5.1         0            0        0           0
## 2450 201438 AP5.1         0            0        0           0
## 2424 201439 AP5.1         0            1        0           0
## 2182 201440 AP5.1         0            1        0           0
## 2416 201441 AP5.1         0            2        0           0
## 2415 201442 AP5.1         0            2        0           0
## 2398 201443 AP5.1         0           NA       NA           0
```

```
## [1] "AP5.2"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 2663 201436 AP5.2         0            0        0           0
## 2686 201437 AP5.2         0            0        0           0
## 2696 201438 AP5.2         0            0        0           0
## 2653 201439 AP5.2         0            1        0           0
## 2677 201440 AP5.2         0            1        0           0
## 2726 201441 AP5.2         0            2        0           0
## 2736 201442 AP5.2         0            2        0           0
## 2721 201443 AP5.2         0           NA       NA           0
```

```
## [1] "AP5.3"
##          SE   APS alertaCli alertaRtweet alertaRt alertaCasos
## 3040 201436 AP5.3         0            0        0           0
## 3050 201437 AP5.3         0            0        0           0
## 3060 201438 AP5.3         0            0        0           0
## 3070 201439 AP5.3         0            1        0           0
## 3080 201440 AP5.3         0            1        0           0
## 3090 201441 AP5.3         0            2        0           0
## 3100 201442 AP5.3         0            2        0           0
## 3110 201443 AP5.3         0           NA       NA           0
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-201.png) ![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-202.png) 

```
## RStudioGD 
##         2
```









