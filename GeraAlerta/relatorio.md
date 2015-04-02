---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-04-01  (SE 201513)**




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
 **268**  201507   35          40.27           57    23.43 

 **269**  201508   75          90.29           81    24.34 

 **270**  201509   88          113.6           94    23.03 

 **271**  201510   111         161.1          129    23.69 

 **272**  201511   134         243.8          137    22.86 

 **273**  201512   139         452.9          146    21.71 
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
 **268**  201507   25      1    0.4406    1        0         0        0     amarelo

 **269**  201508 25.14     2    0.8812    1        0         0        0     amarelo

 **270**  201509 23.57     2    0.8812    1        0         0        0     amarelo

 **271**  201510 24.43     4    1.762     1        0         0        0     amarelo

 **272**  201511   24      4    1.762     1        1         0        0     amarelo

 **273**  201512   23      3    1.322     1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **541**  201507   25      4    0.7237    1        0         0        0     amarelo

 **542**  201508 25.14     4    0.7237    1        0         0        0     amarelo

 **543**  201509 23.57     6    1.086     1        0         0        0     amarelo

 **544**  201510 24.43    12    2.171     1        0         0        0     amarelo

 **545**  201511   24     16    2.895     1        1         0        0     amarelo

 **546**  201512   23     13    2.352     1        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **814**  201507   25      2    0.5389    1        0         0        0     amarelo

 **815**  201508 25.14     5    1.347     1        0         0        0     amarelo

 **816**  201509 23.57     1    0.2695    1        0         0        0     amarelo

 **817**  201510 24.43    10    2.695     1        0         0        0     amarelo

 **818**  201511   24      3    0.8084    1        1         0        0     amarelo

 **819**  201512   23     16    4.311     1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1087**  201507 22.43     5    0.6795    0        0         0        0     amarelo

 **1088**  201508 24.71     9    1.223     1        0         0        0     amarelo

 **1089**  201509 22.71    15    2.039     1        0         0        0     amarelo

 **1090**  201510   24     13    1.767     1        0         1        0     laranja

 **1091**  201511 22.86    21    2.854     1        1         1        0     laranja

 **1092**  201512 21.71    23    3.126     0        1         1        0     laranja
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1360**  201507 22.43     2    0.4084    0        0         0        0     amarelo

 **1361**  201508 24.71    10    2.042     1        0         0        0     amarelo

 **1362**  201509 22.71     9    1.838     1        0         0        0     amarelo

 **1363**  201510   24      2    0.4084    1        0         0        0     amarelo

 **1364**  201511 22.86     6    1.225     1        1         0        0     amarelo

 **1365**  201512 21.71    20    4.084     0        1         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1633**  201507 22.43     0      0       0        0         0        0     amarelo

 **1634**  201508 24.71     5    0.5409    1        0         0        0     amarelo

 **1635**  201509 22.71    11     1.19     1        0         0        0     amarelo

 **1636**  201510   24     13    1.406     1        0         0        0     amarelo

 **1637**  201511 22.86     9    0.9736    1        1         0        0     amarelo

 **1638**  201512 21.71     8    0.8655    0        1         1        0     laranja
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1906**  201507 24.71     3    0.3576    1        0         0        0     amarelo

 **1907**  201508   24      9    1.073     1        0         0        0     amarelo

 **1908**  201509 23.29    12    1.431     1        0         0        0     amarelo

 **1909**  201510 25.14    14    1.669     1        0         0        0     amarelo

 **1910**  201511 23.29    14    1.669     1        1         0        0     amarelo

 **1911**  201512 22.57    22    2.623     1        1         1        0     laranja
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2179**  201507 22.43     8    1.22     0        0         0        0     amarelo

 **2180**  201508 23.29    16    2.439    1        0         0        0     amarelo

 **2181**  201509 22.71    14    2.135    1        0         0        0     amarelo

 **2182**  201510 22.14    23    3.507    1        0         0        0     amarelo

 **2183**  201511 21.57    34    5.184    0        1         0        0     amarelo

 **2184**  201512 20.14    19    2.897    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2452**  201507 22.43     6    0.902    0        0         0        0     amarelo

 **2453**  201508 23.29    11    1.654    1        0         0        0     amarelo

 **2454**  201509 22.71    13    1.954    1        0         1        0     laranja

 **2455**  201510 22.14    18    2.706    1        0         1        0     laranja

 **2456**  201511 21.57    24    3.608    0        1         1        0     laranja

 **2457**  201512 20.14    14    2.105    0        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2725**  201507 22.43     4    1.085     0        0         0        0     amarelo

 **2726**  201508 23.29     4    1.085     1        0         0        0     amarelo

 **2727**  201509 22.71     5    1.357     1        0         0        0     amarelo

 **2728**  201510 22.14     2    0.5427    1        0         0        0     amarelo

 **2729**  201511 21.57     3    0.814     0        1         0        0     amarelo

 **2730**  201512 20.14     1    0.2713    0        1         0        0     amarelo
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


