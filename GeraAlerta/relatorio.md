---
title: "Alerta Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-01-12  (SE 201502)**




* [Na cidade](#tab1)

* [Por APS](#tab2)


<br> </br>

### <a name="tab1"></a> Situação na cidade do Rio de Janeiro




![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png) 

\pagebreak

Últimas 6 semanas:


-----------------------------------------------------------
 &nbsp;     SE    casos   casos_corrigidos   tweets   tmin 
--------- ------ ------- ------------------ -------- ------
 **257**  201449   46          55.02           40    21.48 

 **258**  201450   33          41.51           46    22.91 

 **259**  201451   22          29.81           28    21.87 

 **260**  201452    7          10.74           40    24.15 

 **261**  201453   12           22.6           39    25.16 

 **262**  201501    8          25.24           37    23.89 
-----------------------------------------------------------

Legenda:

- SE: semana epidemiológica
- casos: nímero de casos de dengue no SINAN
- casos_corrigidos: estimativa do número de casos notificados (ver [Notas](#notas))
- tweets: número de tweets relatando sintomas de dengue (ver [Notas](#notas))
- tmin: média das temperaturas mínimas da semana



<br> </br>
<br> </br>




**Alerta por APS**

Código:

*Verde (atividade baixa)*
   temperatura < 22 graus por 3 semanas 
   atividade de tweet normal (não aumentada)
   ausência de transmissão sustentada

*Amarelo (Alerta)*
   temperatura > 22C por mais de 3 semanas
   ou atividade de tweet aumentada

*Laranja (Transmissão sustentada)*
  número reprodutivo >1 por 3 semanas

*Vermelho (atividade alta)*
 incidência > 100:100.000




### <a name="ap1"></a> Alerta APS 1



![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png) 

<br> </br>

Histórico da APS 1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **257**  201449 22.14     1    0.4406    0        0         0        0      verde 

 **258**  201450 22.86     1    0.4406    1        0         0        0     amarelo

 **259**  201451 22.71     2    0.8812    1        0         0        0     amarelo

 **260**  201452 24.43     0      0       1        0         0        0     amarelo

 **261**  201453 26.14     1    0.4406    1        0         0        0     amarelo

 **262**  201501 24.86     0      0       1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **519**  201449 22.14     5    0.9047    0        0         0        0      verde 

 **520**  201450 22.86     5    0.9047    1        0         0        0     amarelo

 **521**  201451 22.71     2    0.3619    1        0         0        0     amarelo

 **522**  201452 24.43     0      0       1        0         0        0     amarelo

 **523**  201453 26.14     6    1.086     1        0         0        0     amarelo

 **524**  201501 24.86     0      0       1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **781**  201449 22.14     8    2.156     0        0         0        0      verde 

 **782**  201450 22.86     1    0.2695    1        0         0        0     amarelo

 **783**  201451 22.71     1    0.2695    1        0         0        0     amarelo

 **784**  201452 24.43     2    0.5389    1        0         0        0     amarelo

 **785**  201453 26.14     1    0.2695    1        0         0        0     amarelo

 **786**  201501 24.86     2    0.5389    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1043**  201449 21.86     0      0       0        0         0        0      verde 

 **1044**  201450 23.33     1    0.1359    0        0         0        0      verde 

 **1045**  201451 22.29     2    0.2718    0        0         0        0      verde 

 **1046**  201452  24.6     0      0       1        0         0        0     amarelo

 **1047**  201453  25.1     1    0.1359    1        0         0        0     amarelo

 **1048**  201501 23.86     1    0.1359    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1305**  201449 21.86     2    0.4084    0        0         0        0      verde 

 **1306**  201450 23.33     2    0.4084    0        0         0        0      verde 

 **1307**  201451 22.29     4    0.8168    0        0         0        0      verde 

 **1308**  201452  24.6     1    0.2042    1        0         0        0     amarelo

 **1309**  201453  25.1     2    0.4084    1        0         0        0     amarelo

 **1310**  201501 23.86     2    0.4084    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1567**  201449 21.86     5    0.5409    0        0         0        0      verde 

 **1568**  201450 23.33     3    0.3245    0        0         0        0      verde 

 **1569**  201451 22.29     3    0.3245    0        0         0        0      verde 

 **1570**  201452  24.6     2    0.2164    1        0         0        0     amarelo

 **1571**  201453  25.1     0      0       1        0         0        0     amarelo

 **1572**  201501 23.86     2    0.2164    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1829**  201449 21.29     7    0.8345    0        0         0        0      verde 

 **1830**  201450   22      6    0.7153    0        0         0        0      verde 

 **1831**  201451 21.57     4    0.4768    0        0         0        0      verde 

 **1832**  201452 25.43     1    0.1192    0        0         0        0      verde 

 **1833**  201453 25.43     1    0.1192    0        0         0        0      verde 

 **1834**  201501   25      0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2091**  201449  20.5     4    0.6099    0        0         0        0      verde 

 **2092**  201450 22.83     5    0.7623    0        0         0        0      verde 

 **2093**  201451 20.71     0      0       0        0         0        0      verde 

 **2094**  201452   23      0      0       0        0         0        0      verde 

 **2095**  201453 24.14     0      0       0        0         0        0      verde 

 **2096**  201501 22.57     0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2353**  201449  20.5     8    1.203     0        0         0        0      verde 

 **2354**  201450 22.83     4    0.6013    0        0         0        0      verde 

 **2355**  201451 20.71     4    0.6013    0        0         0        0      verde 

 **2356**  201452   23      1    0.1503    0        0         0        0      verde 

 **2357**  201453 24.14     0      0       0        0         0        0      verde 

 **2358**  201501 22.57     1    0.1503    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2615**  201449  20.5     6    1.628    0        0         0        0      verde 

 **2616**  201450 22.83     5    1.357    0        0         0        0      verde 

 **2617**  201451 20.71     0      0      0        0         0        0      verde 

 **2618**  201452   23      0      0      0        0         0        0      verde 

 **2619**  201453 24.14     0      0      0        0         0        0      verde 

 **2620**  201501 22.57     0      0      1        0         0        0     amarelo
-----------------------------------------------------------------------------------





### <a name="notas"></a> Notas


- Os dados do sinan mais recentes ainda não foram totalmente digitados. Estimamos o número esperado de casos
notificados considerando o tempo ate os casos serem digitados.
- Os dados de tweets são gerados pelo Observatório de Dengue (UFMG). Os tweets são processados para exclusão de informes e outros temas relacionados a dengue
- Algumas vezes, os casos da última semana ainda não estao disponiveis, nesse caso, usa-se uma estimação com base na tendência de variação da serie 

Créditos
------
Esse e um projeto desenvolvido em parceria pela Fiocruz, FGV e Prefeitura do Rio de Janeiro, com apoio da SVS/MS

Mais detalhes, ver: www.dengue.mat.br


