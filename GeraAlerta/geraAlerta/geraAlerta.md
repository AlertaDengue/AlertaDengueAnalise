Alerta de Dengue para o Rio de Janeiro
======================
versao 0.2






**Hoje e' dia 2014-10-20 , SE 201443**



**Curvas epidemica da dengue na cidade**




Os ultimos dados disponiveis de casos de dengue se referem a'semana 201441:



```
##         SE      x
## 270 201438 50.239
## 271 201439 51.572
## 272 201440 33.880
## 273 201441  7.669
## 274 201442     NA
## 275 201443     NA
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5.png) 

**Curvas epidemicas da dengue por APS**

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6.png) 

**Tweet na cidade**



Os ultimos dados disponiveis de tweet sao da semana 201441:


```
##          SE tweets
## 2865 201438     57
## 2866 201439     80
## 2867 201440     65
## 2868 201441    143
## 2869 201442     NA
## 2870 201443     NA
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

** Dados de temperatura mínima e máxima por APS**



Os ultimos dados disponiveis de temperatura minima sao da semana 201443. 


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##    22    22    22    22    22    22    21    20    20    20
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







