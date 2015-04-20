---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-04-20  (SE 201516)**




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
 **271**  201510   125         143.8          129    23.69 

 **272**  201511   155         186.6          137    22.86 

 **273**  201512   220          284           146    21.71 

 **274**  201513   213         309.2          141     22.3 

 **275**  201514   249          453           187    20.64 

 **276**  201515   249         811.3          349    21.69 
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
 **271**  201510 24.43     6    2.644     1        0         0        0     amarelo

 **272**  201511   24      5    2.203     1        1         0        0     amarelo

 **273**  201512   23      4    1.762     1        1         0        0     amarelo

 **274**  201513 23.71     4    1.762     1        0         0        0     amarelo

 **275**  201514   22      2    0.8812    1        0         0        0     amarelo

 **276**  201515 22.86     1    0.4406    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **547**  201510 24.43    12    2.171    1        0         0        0     amarelo

 **548**  201511   24     16    2.895    1        1         0        0     amarelo

 **549**  201512   23     19    3.438    1        1         1        0     laranja

 **550**  201513 23.71    23    4.161    1        0         1        0     laranja

 **551**  201514   22     23    4.161    1        0         1        0     laranja

 **552**  201515 22.86    35    6.333    1        0         1        0     laranja
----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **823**  201510 24.43    10    2.695     1        0         0        0     amarelo

 **824**  201511   24      3    0.8084    1        1         0        0     amarelo

 **825**  201512   23     14    3.772     1        1         0        0     amarelo

 **826**  201513 23.71    10    2.695     1        0         0        0     amarelo

 **827**  201514   22     15    4.042     1        0         0        0     amarelo

 **828**  201515 22.86     9    2.425     1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1099**  201510   24     16    2.175    1        0         0        0     amarelo

 **1100**  201511 22.86    20    2.718    1        1         1        0     laranja

 **1101**  201512 21.71    27    3.67     0        1         1        0     laranja

 **1102**  201513 22.43    42    5.708    0        0         1        0     laranja

 **1103**  201514 20.71    20    2.718    0        0         0        0     laranja

 **1104**  201515   22     35    4.757    0        0         0        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1375**  201510   24      4    0.8168    1        0         0        0     amarelo

 **1376**  201511 22.86     8    1.634     1        1         0        0     amarelo

 **1377**  201512 21.71    24    4.901     0        1         0        0     amarelo

 **1378**  201513 22.43    13    2.655     0        0         0        0     amarelo

 **1379**  201514 20.71    15    3.063     0        0         1        0     laranja

 **1380**  201515   22      8    1.634     0        0         0        0     laranja
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1651**  201510   24     15    1.623    1        0         0        0     amarelo

 **1652**  201511 22.86    21    2.272    1        1         0        0     amarelo

 **1653**  201512 21.71    25    2.705    0        1         1        0     laranja

 **1654**  201513 22.43    18    1.947    0        0         0        0     laranja

 **1655**  201514 20.71    42    4.544    0        0         0        0     laranja

 **1656**  201515   22     40    4.327    0        0         0        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **1927**  201510 25.14    15    1.788    1        0         0        0     amarelo

 **1928**  201511 23.29    15    1.788    1        1         0        0     amarelo

 **1929**  201512 22.57    31    3.696    1        1         0        0     amarelo

 **1930**  201513 23.29    28    3.338    1        0         0        0     amarelo

 **1931**  201514 20.43    26    3.099    0        0         1        0     laranja

 **1932**  201515   21     40    4.768    0        0         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2203**  201510 22.14    25    3.812    1        0         0        0     amarelo

 **2204**  201511 21.57    36    5.489    0        1         0        0     amarelo

 **2205**  201512 20.14    38    5.794    0        1         1        0     laranja

 **2206**  201513 20.43    40    6.099    0        0         1        0     laranja

 **2207**  201514 19.29    50    7.623    0        0         1        0     laranja

 **2208**  201515 20.43    31    4.727    0        0         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2479**  201510 22.14    20    3.007    1        0         0        0     amarelo

 **2480**  201511 21.57    27    4.059    0        1         1        0     laranja

 **2481**  201512 20.14    26    3.909    0        1         1        0     laranja

 **2482**  201513 20.43    31    4.66     0        0         1        0     laranja

 **2483**  201514 19.29    49    7.366    0        0         1        0     laranja

 **2484**  201515 20.43    48    7.216    0        0         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2755**  201510 22.14     2    0.5427    1        0         0        0     amarelo

 **2756**  201511 21.57     4    1.085     0        1         0        0     amarelo

 **2757**  201512 20.14    12    3.256     0        1         0        0     amarelo

 **2758**  201513 20.43     4    1.085     0        0         0        0     amarelo

 **2759**  201514 19.29     7    1.899     0        0         0        0     amarelo

 **2760**  201515 20.43     2    0.5427    0        0         0        0     amarelo
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


