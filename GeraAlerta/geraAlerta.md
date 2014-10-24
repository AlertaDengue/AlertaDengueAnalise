Alerta de Dengue para o Rio de Janeiro
======================
versao 0.2






**Hoje e' dia 2014-10-24 , SE 201443**



**Curvas epidemica da dengue na cidade**




Os ultimos dados disponiveis de casos de dengue se referem a'semana 201442:


![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 




**Tweet na cidade**



Os ultimos dados disponiveis de tweet sao da semana 201442:


```
##          SE tweets
## 2505 201438     57
## 2506 201439     80
## 2507 201440     65
## 2508 201441    134
## 2509 201442    105
## 2510 201443     NA
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

**Dados de temperatura minima por APS**



Os ultimos dados disponiveis de temperatura minima sao da semana 201443. 


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##    22    22    22    22    22    22    21    20    20    20
```





















![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18.png) 





Alerta por APS
==============

Para cada APS, indica-se as semanas em que houve alerta de temperatura, de Rt e de casos.

```
##        APS     SE       data tweets estacao casos casosm temp.min Pop2010
## 2460 AP5.3 201438 2014-09-17     57 afonsos     4  4.785    18.57  368534
## 2470 AP5.3 201439 2014-09-24     80 afonsos     2  2.516    17.43  368534
## 2480 AP5.3 201440 2014-10-01     65 afonsos     1  1.355    19.57  368534
## 2490 AP5.3 201441 2014-10-08    134 afonsos     0  0.000    16.43  368534
## 2500 AP5.3 201442 2014-10-15    105 afonsos     0  0.000    19.86  368534
## 2510 AP5.3 201443 2014-10-19     NA afonsos    NA     NA    20.00  368534
##      alertaCli    Rtw    ptw1  Rtwlr Rtwur twgreat1 alertaRtweet     Rt
## 2460         0 0.8605 0.08947 0.6883 1.065        0            1 1.0225
## 2470         0 1.2297 0.96965 0.9834 1.513        1            1 0.6672
## 2480         0 1.1099 0.84660 0.9039 1.347        1            2 0.8043
## 2490         0 1.3812 0.99979 1.1461 1.644        1            3 0.4472
## 2500         0 1.0896 0.84997 0.9231 1.276        1            4 0.3501
## 2510         0     NA      NA     NA    NA       NA           NA     NA
##         pRt1   Rtlr  Rtur    pRti Rtgreat1 alertaRt casos_est    inc
## 2460 0.52539 0.5004 1.856 0.52539        0        1         4 1.0854
## 2470 0.14570 0.3156 1.338 0.14570        0        1         2 0.5427
## 2480 0.31251 0.3340 1.720 0.31251        0        0         1 0.2713
## 2490 0.07798 0.1644 1.295 0.07798        0        0         0 0.0000
## 2500 0.10964 0.1022 1.678 0.10964        0        0         0 0.0000
## 2510      NA     NA    NA      NA       NA       NA         0 0.0000
##      alertaCasos cor
## 2460           0   1
## 2470           0   1
## 2480           0   1
## 2490           0   2
## 2500           0   2
## 2510           0  NA
```

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-201.png) ![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-202.png) ![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-203.png) 

```
## RStudioGD 
##         2
```











