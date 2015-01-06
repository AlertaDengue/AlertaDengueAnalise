---
title: "Alerta Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-01-06  (SE 201501)**




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
 **256**  201448   34          40.67           46    22.34 

 **257**  201449   40          50.31           40    21.48 

 **258**  201450   32          43.37           46    22.91 

 **259**  201451   18          27.61           28    21.87 

 **260**  201452    3           5.65           40    24.15 

 **261**  201453   10          31.55           39    25.16 
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
 **256**  201448   22      1    0.4406    0        0         0        0      verde 

 **257**  201449 22.14     1    0.4406    0        0         0        0      verde 

 **258**  201450 22.86     1    0.4406    1        0         0        0     amarelo

 **259**  201451 22.71     2    0.8812    1        0         0        0     amarelo

 **260**  201452 24.43     0      0       1        0         0        0     amarelo

 **261**  201453 26.14     1    0.4406    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **517**  201448   22      6    1.086     0        0         0        0      verde 

 **518**  201449 22.14     5    0.9047    0        0         0        0      verde 

 **519**  201450 22.86     5    0.9047    1        0         0        0     amarelo

 **520**  201451 22.71     2    0.3619    1        0         0        0     amarelo

 **521**  201452 24.43     0      0       1        0         0        0     amarelo

 **522**  201453 26.14     5    0.9047    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **778**  201448   22      5    1.347     0        0         0        0      verde 

 **779**  201449 22.14     8    2.156     0        0         0        0      verde 

 **780**  201450 22.86     1    0.2695    1        0         0        0     amarelo

 **781**  201451 22.71     1    0.2695    1        0         0        0     amarelo

 **782**  201452 24.43     1    0.2695    1        0         0        0     amarelo

 **783**  201453 26.14     0      0       1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1039**  201448 22.67     3    0.4077    0        0         0        0      verde 

 **1040**  201449 21.86     0      0       0        0         0        0      verde 

 **1041**  201450 23.33     1    0.1359    0        0         0        0      verde 

 **1042**  201451 22.29     2    0.2718    0        0         0        0      verde 

 **1043**  201452  24.6     0      0       1        0         0        0     amarelo

 **1044**  201453  25.1     1    0.1359    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1300**  201448 22.67     1    0.2042    0        0         0        0      verde 

 **1301**  201449 21.86     2    0.4084    0        0         0        0      verde 

 **1302**  201450 23.33     2    0.4084    0        0         0        0      verde 

 **1303**  201451 22.29     4    0.8168    0        0         0        0      verde 

 **1304**  201452  24.6     1    0.2042    1        0         0        0     amarelo

 **1305**  201453  25.1     2    0.4084    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1561**  201448 22.67     0      0       0        0         0        0      verde 

 **1562**  201449 21.86     5    0.5409    0        0         0        0      verde 

 **1563**  201450 23.33     3    0.3245    0        0         0        0      verde 

 **1564**  201451 22.29     3    0.3245    0        0         0        0      verde 

 **1565**  201452  24.6     1    0.1082    1        0         0        0     amarelo

 **1566**  201453  25.1     0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1822**  201448   23     10    1.192     0        0         0        0      verde 

 **1823**  201449 21.29     7    0.8345    0        0         0        0      verde 

 **1824**  201450   22      6    0.7153    0        0         0        0      verde 

 **1825**  201451 21.57     3    0.3576    0        0         0        0      verde 

 **1826**  201452 25.43     0      0       0        0         0        0      verde 

 **1827**  201453 25.43     1    0.1192    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2083**  201448 22.14     3    0.4574    0        0         0        0      verde 

 **2084**  201449  20.5     3    0.4574    0        0         0        0      verde 

 **2085**  201450 22.83     5    0.7623    0        0         0        0      verde 

 **2086**  201451 20.71     0      0       0        0         0        0      verde 

 **2087**  201452   23      0      0       0        0         0        0      verde 

 **2088**  201453 24.14     0      0       0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2344**  201448 22.14     4    0.6013    0        0         0        0      verde 

 **2345**  201449  20.5     8    1.203     0        0         0        0      verde 

 **2346**  201450 22.83     3    0.451     0        0         0        0      verde 

 **2347**  201451 20.71     1    0.1503    0        0         0        0      verde 

 **2348**  201452   23      0      0       0        0         0        0      verde 

 **2349**  201453 24.14     0      0       0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2605**  201448 22.14     1    0.2713    0        0         0        0      verde 

 **2606**  201449  20.5     1    0.2713    0        0         0        0      verde 

 **2607**  201450 22.83     5    1.357     0        0         0        0      verde 

 **2608**  201451 20.71     0      0       0        0         0        0      verde 

 **2609**  201452   23      0      0       0        0         0        0      verde 

 **2610**  201453 24.14     0      0       0        0         0        0      verde 
------------------------------------------------------------------------------------





### <a name="notas"></a> Notas


- Os dados do sinan mais recentes ainda não foram totalmente digitados. Estimamos o número esperado de casos
notificados considerando o tempo ate os casos serem digitados.
- Os dados de tweets são gerados pelo Observatório de Dengue (UFMG). Os tweets são processados para exclusão de informes e outros temas relacionados a dengue
- Algumas vezes, os casos da última semana ainda não estao disponiveis, nesse caso, usa-se uma estimação com base na tendência de variação da serie 

Créditos
------
Esse e um projeto desenvolvido em parceria pela Fiocruz, FGV e Prefeitura do Rio de Janeiro, com apoio da SVS/MS

Mais detalhes, ver: www.dengue.mat.br


