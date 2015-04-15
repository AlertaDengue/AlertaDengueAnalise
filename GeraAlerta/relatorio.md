---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-04-13  (SE 201515)**




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
 **270**  201509   93           107            94    23.03 

 **271**  201510   125         150.5          129    23.69 

 **272**  201511   157         202.7          137    22.86 

 **273**  201512   214         310.6          146    21.71 

 **274**  201513   195         354.8          141     22.3 

 **275**  201514   109         355.1          187    20.64 
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
 **270**  201509 23.57     2    0.8812    1        0         0        0     amarelo

 **271**  201510 24.43     5    2.203     1        0         0        0     amarelo

 **272**  201511   24      5    2.203     1        1         0        0     amarelo

 **273**  201512   23      4    1.762     1        1         0        0     amarelo

 **274**  201513 23.71     2    0.8812    1        1         0        0     amarelo

 **275**  201514   22      1    0.4406    1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **545**  201509 23.57     6    1.086    1        0         0        0     amarelo

 **546**  201510 24.43    14    2.533    1        0         0        0     amarelo

 **547**  201511   24     16    2.895    1        1         0        0     amarelo

 **548**  201512   23     19    3.438    1        1         1        0     laranja

 **549**  201513 23.71    23    4.161    1        1         1        0     laranja

 **550**  201514   22     10    1.809    1        1         1        0     laranja
----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **820**  201509 23.57     1    0.2695    1        0         0        0     amarelo

 **821**  201510 24.43    10    2.695     1        0         0        0     amarelo

 **822**  201511   24      3    0.8084    1        1         0        0     amarelo

 **823**  201512   23     16    4.311     1        1         0        0     amarelo

 **824**  201513 23.71    11    2.964     1        1         0        0     amarelo

 **825**  201514   22     13    3.503     1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1095**  201509 22.71    17    2.31     1        0         0        0     amarelo

 **1096**  201510   24     14    1.903    1        0         0        0     amarelo

 **1097**  201511 22.86    21    2.854    1        1         0        0     amarelo

 **1098**  201512 21.71    28    3.805    0        1         1        0     laranja

 **1099**  201513 22.43    41    5.572    0        1         1        0     laranja

 **1100**  201514 20.71    12    1.631    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1370**  201509 22.71     9    1.838    1        0         0        0     amarelo

 **1371**  201510   24      5    1.021    1        0         0        0     amarelo

 **1372**  201511 22.86     8    1.634    1        1         0        0     amarelo

 **1373**  201512 21.71    23    4.697    0        1         0        0     amarelo

 **1374**  201513 22.43    11    2.246    0        1         0        0     amarelo

 **1375**  201514 20.71     8    1.634    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1645**  201509 22.71    11    1.19     1        0         0        0     amarelo

 **1646**  201510   24     16    1.731    1        0         0        0     amarelo

 **1647**  201511 22.86    21    2.272    1        1         0        0     amarelo

 **1648**  201512 21.71    27    2.921    0        1         1        0     laranja

 **1649**  201513 22.43    18    1.947    0        1         1        0     laranja

 **1650**  201514 20.71    13    1.406    0        1         0        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1920**  201509 23.29    12    1.431    1        0         0        0     amarelo

 **1921**  201510 25.14    15    1.788    1        0         0        0     amarelo

 **1922**  201511 23.29    15    1.788    1        1         0        0     amarelo

 **1923**  201512 22.57    28    3.338    1        1         0        0     amarelo

 **1924**  201513 23.29    30    3.576    1        1         1        0     laranja

 **1925**  201514 20.43    23    2.742    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2195**  201509 22.71    15    2.287    1        0         0        0     amarelo

 **2196**  201510 22.14    24    3.659    1        0         0        0     amarelo

 **2197**  201511 21.57    37    5.641    0        1         0        0     amarelo

 **2198**  201512 20.14    39    5.946    0        1         1        0     laranja

 **2199**  201513 20.43    27    4.117    0        1         1        0     laranja

 **2200**  201514 19.29    15    2.287    0        1         0        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2470**  201509 22.71    15    2.255    1        0         0        0     amarelo

 **2471**  201510 22.14    20    3.007    1        0         0        0     amarelo

 **2472**  201511 21.57    27    4.059    0        1         1        0     laranja

 **2473**  201512 20.14    21    3.157    0        1         1        0     laranja

 **2474**  201513 20.43    30    4.51     0        1         1        0     laranja

 **2475**  201514 19.29    11    1.654    0        1         0        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2745**  201509 22.71     5    1.357     1        0         0        0     amarelo

 **2746**  201510 22.14     2    0.5427    1        0         0        0     amarelo

 **2747**  201511 21.57     4    1.085     0        1         0        0     amarelo

 **2748**  201512 20.14     9    2.442     0        1         0        0     amarelo

 **2749**  201513 20.43     2    0.5427    0        1         0        0     amarelo

 **2750**  201514 19.29     3    0.814     0        1         0        0     amarelo
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


