---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-04-06  (SE 201514)**




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
 **269**  201508   76          87.44           81    24.34 

 **270**  201509   93           112            94    23.03 

 **271**  201510   119         153.6          129    23.69 

 **272**  201511   141         204.7          137    22.86 

 **273**  201512   183         332.9          146    21.71 

 **274**  201513   82          267.2          141     22.3 
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
 **269**  201508 25.14     2    0.8812    1        0         0        0     amarelo

 **270**  201509 23.57     2    0.8812    1        0         0        0     amarelo

 **271**  201510 24.43     4    1.762     1        0         0        0     amarelo

 **272**  201511   24      4    1.762     1        1         0        0     amarelo

 **273**  201512   23      3    1.322     1        1         0        0     amarelo

 **274**  201513 23.71     2    0.8812    1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **543**  201508 25.14     4    0.7237    1        0         0        0     amarelo

 **544**  201509 23.57     6    1.086     1        0         0        0     amarelo

 **545**  201510 24.43    14    2.533     1        0         0        0     amarelo

 **546**  201511   24     16    2.895     1        1         0        0     amarelo

 **547**  201512   23     19    3.438     1        1         1        0     laranja

 **548**  201513 23.71    11     1.99     1        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **817**  201508 25.14     5    1.347     1        0         0        0     amarelo

 **818**  201509 23.57     1    0.2695    1        0         0        0     amarelo

 **819**  201510 24.43    10    2.695     1        0         0        0     amarelo

 **820**  201511   24      3    0.8084    1        1         0        0     amarelo

 **821**  201512   23     16    4.311     1        1         0        0     amarelo

 **822**  201513 23.71     2    0.5389    1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1091**  201508 24.71     9    1.223    1        0         0        0     amarelo

 **1092**  201509 22.71    16    2.175    1        0         0        0     amarelo

 **1093**  201510   24     13    1.767    1        0         0        0     amarelo

 **1094**  201511 22.86    21    2.854    1        1         0        0     amarelo

 **1095**  201512 21.71    25    3.398    0        1         1        0     laranja

 **1096**  201513 22.43    16    2.175    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1365**  201508 24.71    10    2.042     1        0         0        0     amarelo

 **1366**  201509 22.71    10    2.042     1        0         0        0     amarelo

 **1367**  201510   24      3    0.6126    1        0         0        0     amarelo

 **1368**  201511 22.86     6    1.225     1        1         0        0     amarelo

 **1369**  201512 21.71    20    4.084     0        1         0        0     amarelo

 **1370**  201513 22.43     7    1.429     0        1         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1639**  201508 24.71     5    0.5409    1        0         0        0     amarelo

 **1640**  201509 22.71    11     1.19     1        0         0        0     amarelo

 **1641**  201510   24     14    1.515     1        0         0        0     amarelo

 **1642**  201511 22.86    12    1.298     1        1         0        0     amarelo

 **1643**  201512 21.71    15    1.623     0        1         0        0     amarelo

 **1644**  201513 22.43     6    0.6491    0        1         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1913**  201508   24      9    1.073    1        0         0        0     amarelo

 **1914**  201509 23.29    12    1.431    1        0         0        0     amarelo

 **1915**  201510 25.14    15    1.788    1        0         0        0     amarelo

 **1916**  201511 23.29    16    1.907    1        1         0        0     amarelo

 **1917**  201512 22.57    26    3.099    1        1         1        0     laranja

 **1918**  201513 23.29    12    1.431    1        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2187**  201508 23.29    16    2.439    1        0         0        0     amarelo

 **2188**  201509 22.71    14    2.135    1        0         0        0     amarelo

 **2189**  201510 22.14    23    3.507    1        0         0        0     amarelo

 **2190**  201511 21.57    34    5.184    0        1         0        0     amarelo

 **2191**  201512 20.14    29    4.422    0        1         1        0     laranja

 **2192**  201513 20.43     8    1.22     0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2461**  201508 23.29    11    1.654    1        0         0        0     amarelo

 **2462**  201509 22.71    16    2.405    1        0         0        0     amarelo

 **2463**  201510 22.14    20    3.007    1        0         0        0     amarelo

 **2464**  201511 21.57    25    3.758    0        1         1        0     laranja

 **2465**  201512 20.14    21    3.157    0        1         1        0     laranja

 **2466**  201513 20.43    16    2.405    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2735**  201508 23.29     5    1.357     1        0         0        0     amarelo

 **2736**  201509 22.71     5    1.357     1        0         0        0     amarelo

 **2737**  201510 22.14     3    0.814     1        0         0        0     amarelo

 **2738**  201511 21.57     4    1.085     0        1         0        0     amarelo

 **2739**  201512 20.14     9    2.442     0        1         0        0     amarelo

 **2740**  201513 20.43     2    0.5427    0        1         0        0     amarelo
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


