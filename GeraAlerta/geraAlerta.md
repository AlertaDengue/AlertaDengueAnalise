Relatorio Semanal do Projeto Alerta Dengue para a cidade do Rio de Janeiro
===========================================================






**Rio de Janeiro, 2014-10-27  (SE 201444)**



Dengue a nivel da cidade
-----------------------



Dados das ultimas 12 semanas:


```
##         SE casos casos_corrigidos tweets tempmin
## 240 201432    44            47.06     64   15.66
## 241 201433    28            30.27     42   16.43
## 242 201434    26            28.42     47   17.81
## 243 201435    32            35.44     81   17.61
## 244 201436    35            39.41     46   17.99
## 245 201437    32            36.91     45   17.85
## 246 201438    29            34.69     57   19.57
## 247 201439    39            49.06     80   18.95
## 248 201440    37            50.14     65   20.15
## 249 201441    36            55.21    143   17.77
## 250 201442    34            64.03    105   20.44
## 251 201443    16            50.47     88   21.30
```

Legenda:

- SE: semana epidemiologica
- casos: numero de casos de dengue no SINAN
- casos_corrigidos: estimativa do numero de casos notificados (1)
- tweets: numero de tweets relatando sintomas de dengue (2)
- tempmin: media das temperaturas minimas da semana


![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 


![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7.png) 

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 





Alerta por APS em 4 niveis
-------------

**Verde (atividade baixa)** 
- se temperatura < 22 graus por 3 semanas 
- se atividade de tweet for normal (nao aumentada)
- ausencia de transmissao sustentada
- se incidencia < 100:100.000

**Amarelo (Alerta)**
- se temperatura > 22C por mais de 3 semanas
- se atividade de tweet aumentar

**Laranja (Transmissao sustentada)**
- se numero reprodutivo >1, por 3 semanas

**Vermelho (atividade alta)**
- se incidencia > 100:100.000


















Resultado
---------

**Legenda:**
- SE : semana epidemiologica
- data: data de inicio da SE
- APS: area programatica da saude
- tempmin: media das temperaturas minimas da semana
- casos_est: numero de casos estimados na semana (3)
- inc: casos por 100.000 habitantes
- alertaClima = 1, se temperatura > 22C por mais de 3 semanas
- alertaTweet = 1, se Tweet com tendencia de aumento 
- alertaTransmissao = 1, se casos com tendencia de aumento
- alertaCasos = 1, se Incidencia > 100 por 100 mil

 


```
## [1] "AP1"
##         SE       data APS tempmin casos_est    inc alertaClima alertaTweet
## 127 201436 2014-09-03 AP1   19.57         0 0.0000           0           0
## 137 201437 2014-09-10 AP1   20.00         2 0.8812           0           0
## 147 201438 2014-09-17 AP1   20.60         2 0.8812           0           0
## 157 201439 2014-09-24 AP1   20.50         3 1.3218           0           0
## 167 201440 2014-10-01 AP1   20.33         2 0.8812           0           0
## 164 201441 2014-10-08 AP1   19.43         1 0.4406           0           0
## 174 201442 2014-10-15 AP1   20.43         0 0.0000           0           0
## 184 201443 2014-10-19 AP1   22.00         1 0.4406           0           0
##     alertaTransmissao alertaCasos nivel
## 127                 0           0 verde
## 137                 0           0 verde
## 147                 0           0 verde
## 157                 0           0 verde
## 167                 0           0 verde
## 164                 0           0 verde
## 174                 0           0 verde
## 184                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-161.png) 

```
## [1] "AP2.1"
##         SE       data   APS tempmin casos_est    inc alertaClima
## 465 201436 2014-09-03 AP2.1   19.57         1 0.1809           0
## 462 201437 2014-09-10 AP2.1   20.00         2 0.3619           0
## 459 201438 2014-09-17 AP2.1   20.60         3 0.5428           0
## 469 201439 2014-09-24 AP2.1   20.50         5 0.9047           0
## 479 201440 2014-10-01 AP2.1   20.33         0 0.0000           0
## 489 201441 2014-10-08 AP2.1   19.43         1 0.1809           0
## 495 201442 2014-10-15 AP2.1   20.43         1 0.1809           0
## 502 201443 2014-10-19 AP2.1   22.00         4 0.7237           0
##     alertaTweet alertaTransmissao alertaCasos nivel
## 465           0                 0           0 verde
## 462           0                 0           0 verde
## 459           0                 0           0 verde
## 469           0                 0           0 verde
## 479           0                 0           0 verde
## 489           0                 0           0 verde
## 495           0                 0           0 verde
## 502           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-162.png) 

```
## [1] "AP2.2"
##         SE       data   APS tempmin casos_est    inc alertaClima
## 696 201436 2014-09-03 AP2.2   19.57         0 0.0000           0
## 706 201437 2014-09-10 AP2.2   20.00         4 1.0778           0
## 716 201438 2014-09-17 AP2.2   20.60         0 0.0000           0
## 726 201439 2014-09-24 AP2.2   20.50         0 0.0000           0
## 723 201440 2014-10-01 AP2.2   20.33         3 0.8084           0
## 720 201441 2014-10-08 AP2.2   19.43        13 3.5029           0
## 730 201442 2014-10-15 AP2.2   20.43         4 1.0778           0
## 714 201443 2014-10-19 AP2.2   22.00         3 0.8084           0
##     alertaTweet alertaTransmissao alertaCasos nivel
## 696           0                 0           0 verde
## 706           0                 0           0 verde
## 716           0                 0           0 verde
## 726           0                 0           0 verde
## 723           0                 0           0 verde
## 720           0                 0           0 verde
## 730           0                 0           0 verde
## 714           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-163.png) 

```
## [1] "AP3.1"
##         SE       data   APS tempmin casos_est    inc alertaClima
## 939 201436 2014-09-03 AP3.1   17.43         4 0.5436           0
## 949 201437 2014-09-10 AP3.1   17.57         0 0.0000           0
## 959 201438 2014-09-17 AP3.1   19.29         3 0.4077           0
## 956 201439 2014-09-24 AP3.1   18.71         3 0.4077           0
## 966 201440 2014-10-01 AP3.1   19.83         2 0.2718           0
## 963 201441 2014-10-08 AP3.1   17.14         1 0.1359           0
## 973 201442 2014-10-15 AP3.1   20.86         7 0.9514           0
## 983 201443 2014-10-19 AP3.1   22.00         1 0.1359           0
##     alertaTweet alertaTransmissao alertaCasos nivel
## 939           0                 0           0 verde
## 949           0                 0           0 verde
## 959           0                 0           0 verde
## 956           0                 0           0 verde
## 966           0                 0           0 verde
## 963           0                 0           0 verde
## 973           0                 0           0 verde
## 983           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-164.png) 

```
## [1] "AP3.2"
##          SE       data   APS tempmin casos_est    inc alertaClima
## 1197 201436 2014-09-03 AP3.2   17.43         4 0.8168           0
## 1207 201437 2014-09-10 AP3.2   17.57         0 0.0000           0
## 1217 201438 2014-09-17 AP3.2   19.29         1 0.2042           0
## 1227 201439 2014-09-24 AP3.2   18.71         2 0.4084           0
## 1237 201440 2014-10-01 AP3.2   19.83         4 0.8168           0
## 1234 201441 2014-10-08 AP3.2   17.14         1 0.2042           0
## 1218 201442 2014-10-15 AP3.2   20.86         2 0.4084           0
## 1228 201443 2014-10-19 AP3.2   22.00         3 0.6126           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 1197           0                 0           0 verde
## 1207           0                 0           0 verde
## 1217           0                 0           0 verde
## 1227           0                 0           0 verde
## 1237           0                 0           0 verde
## 1234           0                 0           0 verde
## 1218           0                 0           0 verde
## 1228           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-165.png) 

```
## [1] "AP3.3"
##          SE       data   APS tempmin casos_est    inc alertaClima
## 1496 201436 2014-09-03 AP3.3   17.43         5 0.5409           0
## 1493 201437 2014-09-10 AP3.3   17.57         3 0.3245           0
## 1490 201438 2014-09-17 AP3.3   19.29         0 0.0000           0
## 1487 201439 2014-09-24 AP3.3   18.71        10 1.0818           0
## 1484 201440 2014-10-01 AP3.3   19.83         3 0.3245           0
## 1494 201441 2014-10-08 AP3.3   17.14         5 0.5409           0
## 1500 201442 2014-10-15 AP3.3   20.86         9 0.9736           0
## 1506 201443 2014-10-19 AP3.3   22.00         1 0.1082           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 1496           0                 0           0 verde
## 1493           0                 0           0 verde
## 1490           0                 0           0 verde
## 1487           0                 0           0 verde
## 1484           0                 0           0 verde
## 1494           0                 0           0 verde
## 1500           0                 0           0 verde
## 1506           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-166.png) 

```
## [1] "AP4"
##          SE       data APS tempmin casos_est    inc alertaClima
## 1727 201436 2014-09-03 AP4   18.29         1 0.1192           0
## 1737 201437 2014-09-10 AP4   18.43         0 0.0000           0
## 1747 201438 2014-09-17 AP4   20.33         4 0.4768           0
## 1749 201439 2014-09-24 AP4   19.57         4 0.4768           0
## 1746 201440 2014-10-01 AP4   22.33         6 0.7153           0
## 1751 201441 2014-10-08 AP4   18.71         3 0.3576           0
## 1753 201442 2014-10-15 AP4   21.00         4 0.4768           0
## 1745 201443 2014-10-19 AP4   21.00         2 0.2384           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 1727           0                 0           0 verde
## 1737           0                 0           0 verde
## 1747           0                 0           0 verde
## 1749           0                 0           0 verde
## 1746           0                 0           0 verde
## 1751           0                 0           0 verde
## 1753           0                 0           0 verde
## 1745           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-167.png) 

```
## [1] "AP5.1"
##          SE       data   APS tempmin casos_est    inc alertaClima
## 1983 201436 2014-09-03 AP5.1   16.86         9 1.3722           0
## 1993 201437 2014-09-10 AP5.1   15.80        17 2.5920           0
## 2003 201438 2014-09-17 AP5.1   18.57         9 1.3722           0
## 2000 201439 2014-09-24 AP5.1   17.43         6 0.9148           0
## 1997 201440 2014-10-01 AP5.1   19.57        11 1.6772           0
## 1994 201441 2014-10-08 AP5.1   16.43         5 0.7623           0
## 2004 201442 2014-10-15 AP5.1   19.86         3 0.4574           0
## 2001 201443 2014-10-19 AP5.1   20.00         0 0.0000           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 1983           0                 0           0 verde
## 1993           0                 0           0 verde
## 2003           0                 0           0 verde
## 2000           0                 0           0 verde
## 1997           0                 0           0 verde
## 1994           0                 0           0 verde
## 2004           0                 0           0 verde
## 2001           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-168.png) 

```
## [1] "AP5.2"
##          SE       data   APS tempmin casos_est    inc alertaClima
## 2184 201436 2014-09-03 AP5.2   16.86         5 0.7517           0
## 2194 201437 2014-09-10 AP5.2   15.80         1 0.1503           0
## 2191 201438 2014-09-17 AP5.2   18.57         3 0.4510           0
## 2201 201439 2014-09-24 AP5.2   17.43         2 0.3007           0
## 2211 201440 2014-10-01 AP5.2   19.57         6 0.9020           0
## 2221 201441 2014-10-08 AP5.2   16.43         5 0.7517           0
## 2231 201442 2014-10-15 AP5.2   19.86         3 0.4510           0
## 2241 201443 2014-10-19 AP5.2   20.00         1 0.1503           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 2184           0                 0           0 verde
## 2194           0                 0           0 verde
## 2191           0                 0           0 verde
## 2201           0                 0           0 verde
## 2211           0                 0           0 verde
## 2221           0                 0           0 verde
## 2231           0                 0           0 verde
## 2241           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-169.png) 

```
## [1] "AP5.3"
##          SE       data   APS tempmin casos_est    inc alertaClima
## 2440 201436 2014-09-03 AP5.3   16.86         6 1.6281           0
## 2450 201437 2014-09-10 AP5.3   15.80         3 0.8140           0
## 2460 201438 2014-09-17 AP5.3   18.57         4 1.0854           0
## 2470 201439 2014-09-24 AP5.3   17.43         4 1.0854           0
## 2480 201440 2014-10-01 AP5.3   19.57         0 0.0000           0
## 2490 201441 2014-10-08 AP5.3   16.43         1 0.2713           0
## 2500 201442 2014-10-15 AP5.3   19.86         1 0.2713           0
## 2510 201443 2014-10-19 AP5.3   20.00         0 0.0000           0
##      alertaTweet alertaTransmissao alertaCasos nivel
## 2440           0                 0           0 verde
## 2450           0                 0           0 verde
## 2460           0                 0           0 verde
## 2470           0                 0           0 verde
## 2480           0                 0           0 verde
## 2490           0                 0           0 verde
## 2500           0                 0           0 verde
## 2510           0                 0           0 verde
```

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-1610.png) 














Notas
-----
- (1) Os dados do sinan mais recentes ainda nao foram totalmente digitados. Estimamos o numero esperado de casos
notificados considerando o tempo ate os casos serem digitados.
- (2) Os dados de tweets sao gerados pelo Observatorio de Dengue (UFMG). Os tweets sao processados para exclusao de informes e outros temas relacionados a dengue
- (3) Algumas vezes, os casos da ultima semana ainda nao estao disponiveis, nesse caso, usa-se uma estimacao com base na tendencia de variacao da serie 

Creditos
------
Esse e um projeto desenvolvido em parceria pela Fiocruz, FGV e Prefeitura do Rio de Janeiro, com apoio da SVS/MS

Mais detalhes, ver: www.dengue.mat.br
