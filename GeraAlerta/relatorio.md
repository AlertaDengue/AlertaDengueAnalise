---
title: "Alerta Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-01-19  (SE 201503)**




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
 **258**  201450   33          37.97           46    22.91 

 **259**  201451   22          26.49           28    21.87 

 **260**  201452    7          9.037           40    24.15 

 **261**  201453   12          17.42           39    25.16 

 **262**  201501    8          14.55           37    23.89 

 **263**  201502   NA            NA            51     25.2 
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
 **258**  201450 22.86     1    0.4406    1        0         0        0     amarelo

 **259**  201451 22.71     2    0.8812    1        0         0        0     amarelo

 **260**  201452 24.43     0      0       1        0         0        0     amarelo

 **261**  201453 26.14     1    0.4406    1        0         0        0     amarelo

 **262**  201501 24.86     0      0       1        0         0        0     amarelo

 **263**  201502 26.57   1.085  0.4779    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **521**  201450 22.86     5    0.9047    1        0         0        0     amarelo

 **522**  201451 22.71     2    0.3619    1        0         0        0     amarelo

 **523**  201452 24.43     0      0       1        0         0        0     amarelo

 **524**  201453 26.14     6    1.086     1        0         0        0     amarelo

 **525**  201501 24.86     0      0       1        0         0        0     amarelo

 **526**  201502 26.57   8.173  1.479     1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **784**  201450 22.86     1    0.2695    1        0         0        0     amarelo

 **785**  201451 22.71     1    0.2695    1        0         0        0     amarelo

 **786**  201452 24.43     2    0.5389    1        0         0        0     amarelo

 **787**  201453 26.14     1    0.2695    1        0         0        0     amarelo

 **788**  201501 24.86     2    0.5389    1        0         0        0     amarelo

 **789**  201502 26.57   1.061  0.2859    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1047**  201450 23.33     1    0.1359    0        0         0        0      verde 

 **1048**  201451 22.29     2    0.2718    0        0         0        0      verde 

 **1049**  201452  24.6     0      0       1        0         0        0     amarelo

 **1050**  201453  25.1     1    0.1359    1        0         0        0     amarelo

 **1051**  201501 23.86     1    0.1359    1        0         0        0     amarelo

 **1052**  201502 25.86   1.085  0.1474    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1310**  201450 23.33     2    0.4084    0        0         0        0      verde 

 **1311**  201451 22.29     4    0.8168    0        0         0        0      verde 

 **1312**  201452  24.6     1    0.2042    1        0         0        0     amarelo

 **1313**  201453  25.1     2    0.4084    1        0         0        0     amarelo

 **1314**  201501 23.86     2    0.4084    1        0         0        0     amarelo

 **1315**  201502 25.86   2.143  0.4376    1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1573**  201450 23.33     3    0.3245    0        0         0        0      verde 

 **1574**  201451 22.29     3    0.3245    0        0         0        0      verde 

 **1575**  201452  24.6     2    0.2164    1        0         0        0     amarelo

 **1576**  201453  25.1     0      0       1        0         0        0     amarelo

 **1577**  201501 23.86     2    0.2164    1        0         0        0     amarelo

 **1578**  201502 25.86     0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

-------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos    inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------- -------- -------- --------- -------- -------
 **1836**  201450   22      6    0.7153     0        0         0        0      verde 

 **1837**  201451 21.57     4    0.4768     0        0         0        0      verde 

 **1838**  201452 25.43     1    0.1192     0        0         0        0      verde 

 **1839**  201453 25.43     1    0.1192     0        0         0        0      verde 

 **1840**  201501   25      0       0       1        0         0        0     amarelo

 **1841**  201502 24.43  0.5809  0.06925    1        0         0        0     amarelo
-------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2099**  201450 22.83     5    0.7623    0        0         0        0      verde 

 **2100**  201451 20.71     0      0       0        0         0        0      verde 

 **2101**  201452   23      0      0       0        0         0        0      verde 

 **2102**  201453 24.14     0      0       0        0         0        0      verde 

 **2103**  201501 22.57     0      0       1        0         0        0     amarelo

 **2104**  201502 23.43     0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2362**  201450 22.83     4    0.6013    0        0         0        0      verde 

 **2363**  201451 20.71     4    0.6013    0        0         0        0      verde 

 **2364**  201452   23      1    0.1503    0        0         0        0      verde 

 **2365**  201453 24.14     0      0       0        0         0        0      verde 

 **2366**  201501 22.57     1    0.1503    1        0         0        0     amarelo

 **2367**  201502 23.43     0      0       1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2625**  201450 22.83     5    1.357    0        0         0        0      verde 

 **2626**  201451 20.71     0      0      0        0         0        0      verde 

 **2627**  201452   23      0      0      0        0         0        0      verde 

 **2628**  201453 24.14     0      0      0        0         0        0      verde 

 **2629**  201501 22.57     0      0      1        0         0        0     amarelo

 **2630**  201502 23.43     0      0      1        0         0        0     amarelo
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


