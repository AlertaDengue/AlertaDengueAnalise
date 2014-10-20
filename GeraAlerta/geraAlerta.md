Alerta de Dengue para o Rio de Janeiro
======================
versao 0.2






**Hoje e' dia 2014-10-20 , SE 201443**



**Curvas epidemica da dengue na cidade**




Os ultimos dados disponiveis de casos de dengue se referem a'semana 201441:



```
##         SE  x
## 268 201436 48
## 269 201437 36
## 270 201438 42
## 271 201439 41
## 272 201440 25
## 273 201441  5
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

**Curvas epidemicas da dengue por APS**

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

**Tweet na cidade**



Os ultimos dados disponiveis de tweet sao da semana 201441:


```
##          SE tweets
## 2845 201436     53
## 2846 201437     45
## 2847 201438     57
## 2848 201439     80
## 2849 201440     65
## 2850 201441    143
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

** Dados de temperatura mínima e máxima por APS**



Os ultimos dados disponiveis de temperatura minima sao da semana 201435. 


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##    17    17    17    17    17    17    17    17    17    17
```

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11.png) 




Modelo de alerta com 5 indicadores
========

- AlertaCli = Temperatura minima semanal > 22 graus por 3 semanas
- Alertatweet = crescimento significativo de tweet na ultima semana
- AlertaRt =  (Rt > 1) por 3 semanas. Se nao houver notificacao, completar com o Rt dos tweets
- AlertaCasos = Casos > limiar de epidemia (100 por 100.000) 
- Rm = Mosquitos que aumentam significativamente (a fazer) 












**Grafico de Prob(Rt > 1)**

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17.png) 







**Alerta por APS**

Para cada APS, indica-se as semanas em que houve alerta de temperatura, de Rt e de casos.

```
## [1] "AP1"
##         SE APS alertaCli alertaRt alertaCasos
## 208 201434 AP1         0        0           0
## 218 201435 AP1         0        0           0
## 241 201436 AP1        NA        0           0
## 225 201437 AP1        NA        0           0
## 265 201438 AP1        NA        0           0
## 245 201439 AP1        NA        0           0
## 268 201440 AP1        NA        0           0
## 239 201441 AP1        NA        0           0
```

```
## [1] "AP2.1"
##         SE   APS alertaCli alertaRt alertaCasos
## 590 201434 AP2.1         0        0           0
## 487 201435 AP2.1         0        0           0
## 540 201436 AP2.1        NA        0           0
## 589 201437 AP2.1        NA        0           0
## 569 201438 AP2.1        NA        0           0
## 557 201439 AP2.1        NA        0           0
## 580 201440 AP2.1        NA        0           0
## 586 201441 AP2.1        NA        0           0
```

```
## [1] "AP2.2"
##         SE   APS alertaCli alertaRt alertaCasos
## 862 201434 AP2.2         0        0           0
## 802 201435 AP2.2         0        0           0
## 798 201436 AP2.2        NA        0           0
## 899 201437 AP2.2        NA        0           0
## 889 201438 AP2.2        NA        0           0
## 829 201439 AP2.2        NA        0           0
## 812 201440 AP2.2        NA        0           0
## 878 201441 AP2.2        NA        0           0
```

```
## [1] "AP3.1"
##          SE   APS alertaCli alertaRt alertaCasos
## 1216 201434 AP3.1         0        0           0
## 1044 201435 AP3.1         0        0           0
## 1028 201436 AP3.1        NA        0           0
## 1189 201437 AP3.1        NA        0           0
## 1180 201438 AP3.1        NA        0           0
## 1019 201439 AP3.1        NA        0           0
## 1042 201440 AP3.1        NA        0           0
## 1203 201441 AP3.1        NA        0           0
```

```
## [1] "AP3.2"
##          SE   APS alertaCli alertaRt alertaCasos
## 1526 201434 AP3.2         0        0           0
## 1382 201435 AP3.2         0        0           0
## 1350 201436 AP3.2        NA        0           0
## 1447 201437 AP3.2        NA        0           0
## 1404 201438 AP3.2        NA        0           0
## 1275 201439 AP3.2        NA        0           0
## 1282 201440 AP3.2        NA        0           0
## 1487 201441 AP3.2        NA        0           0
```

```
## [1] "AP3.3"
##          SE   APS alertaCli alertaRt alertaCasos
## 1808 201434 AP3.3         0        0           0
## 1828 201435 AP3.3         0        0           0
## 1633 201436 AP3.3        NA        0           0
## 1798 201437 AP3.3        NA        0           0
## 1716 201438 AP3.3        NA        0           0
## 1736 201439 AP3.3        NA        1           0
## 1581 201440 AP3.3        NA        1           0
## 1812 201441 AP3.3        NA        1           0
```

```
## [1] "AP4"
##          SE APS alertaCli alertaRt alertaCasos
## 2112 201434 AP4         0        0           0
## 2145 201435 AP4         0        0           0
## 1928 201436 AP4        NA        0           0
## 2025 201437 AP4        NA        0           0
## 2050 201438 AP4        NA        0           0
## 2099 201439 AP4        NA        0           0
## 1860 201440 AP4        NA        0           0
## 2052 201441 AP4        NA        0           0
```

```
## [1] "AP5.1"
##          SE   APS alertaCli alertaRt alertaCasos
## 2385 201434 AP5.1         0        0           0
## 2381 201435 AP5.1         0        0           0
## 2176 201436 AP5.1        NA        0           0
## 2389 201437 AP5.1        NA        0           0
## 2401 201438 AP5.1        NA        0           0
## 2411 201439 AP5.1        NA        0           0
## 2170 201440 AP5.1        NA        0           0
## 2416 201441 AP5.1        NA        0           0
```

```
## [1] "AP5.2"
##          SE   APS alertaCli alertaRt alertaCasos
## 2737 201434 AP5.2         0        0           0
## 2571 201435 AP5.2         0        0           0
## 2663 201436 AP5.2        NA        0           0
## 2686 201437 AP5.2        NA        0           0
## 2696 201438 AP5.2        NA        0           0
## 2640 201439 AP5.2        NA        0           0
## 2677 201440 AP5.2        NA        0           0
## 2726 201441 AP5.2        NA        0           0
```

```
## [1] "AP5.3"
##          SE   APS alertaCli alertaRt alertaCasos
## 3020 201434 AP5.3         0        1           0
## 3030 201435 AP5.3         0        1           0
## 3040 201436 AP5.3        NA        0           0
## 3050 201437 AP5.3        NA        0           0
## 3060 201438 AP5.3        NA        0           0
## 3070 201439 AP5.3        NA        0           0
## 3080 201440 AP5.3        NA        0           0
## 3090 201441 AP5.3        NA        0           0
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20.png) 









