---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-03-30  (SE 201513)**




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
 **268**  201507   40          46.02           57    23.43 

 **269**  201508   71          85.47           81    24.34 

 **270**  201509   87          112.3           94    23.03 

 **271**  201510   89          129.2          129    23.69 

 **272**  201511   65          118.3          137    22.86 

 **273**  201512   NA            NA           146    21.71 
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
 **268**  201507   25      2    0.8812    1        0         0        0     amarelo

 **269**  201508 25.14     2    0.8812    1        0         0        0     amarelo

 **270**  201509 23.57     0      0       1        0         0        0     amarelo

 **271**  201510 24.43     1    0.4406    1        0         0        0     amarelo

 **272**  201511   24      1    0.4406    1        1         0        0     amarelo

 **273**  201512   23   0.8196  0.3611    1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **541**  201507   25      5    0.9047    1        0         0        0     amarelo

 **542**  201508 25.14     3    0.5428    1        0         0        0     amarelo

 **543**  201509 23.57     6    1.086     1        0         0        0     amarelo

 **544**  201510 24.43    12    2.171     1        0         0        0     amarelo

 **545**  201511   24     13    2.352     1        1         0        0     amarelo

 **546**  201512   23    20.18  3.651     1        1         1        0     laranja
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **814**  201507   25      2    0.5389    1        0         0        0     amarelo

 **815**  201508 25.14     3    0.8084    1        0         0        0     amarelo

 **816**  201509 23.57     1    0.2695    1        0         0        0     amarelo

 **817**  201510 24.43    10    2.695     1        0         0        0     amarelo

 **818**  201511   24      2    0.5389    1        1         0        0     amarelo

 **819**  201512   23    26.95  7.263     1        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1087**  201507 22.43     6    0.8155    0        0         0        0     amarelo

 **1088**  201508 24.71     8    1.087     1        0         0        0     amarelo

 **1089**  201509 22.71    17     2.31     1        0         0        0     amarelo

 **1090**  201510   24      6    0.8155    1        0         0        0     amarelo

 **1091**  201511 22.86    11    1.495     1        1         0        0     amarelo

 **1092**  201512 21.71   6.281  0.8537    0        1         0        0     amarelo
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

 **1363**  201510   24      3    0.6126    1        0         0        0     amarelo

 **1364**  201511 22.86     1    0.2042    1        1         0        0     amarelo

 **1365**  201512 21.71   3.237  0.6611    0        1         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1633**  201507 22.43     0      0       0        0         0        0     amarelo

 **1634**  201508 24.71     4    0.4327    1        0         0        0     amarelo

 **1635**  201509 22.71    12    1.298     1        0         0        0     amarelo

 **1636**  201510   24      9    0.9736    1        0         1        0     laranja

 **1637**  201511 22.86     0      0       1        1         0        0     laranja

 **1638**  201512 21.71   14.79   1.6      0        1         0        0     laranja
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1906**  201507 24.71     4    0.4768    1        0         0        0     amarelo

 **1907**  201508   24      9    1.073     1        0         0        0     amarelo

 **1908**  201509 23.29    12    1.431     1        0         0        0     amarelo

 **1909**  201510 25.14    12    1.431     1        0         0        0     amarelo

 **1910**  201511 23.29     9    1.073     1        1         0        0     amarelo

 **1911**  201512 22.57   16.97  2.023     1        1         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2179**  201507 22.43     9    1.372    0        0         0        0     amarelo

 **2180**  201508 23.29    16    2.439    1        0         0        0     amarelo

 **2181**  201509 22.71    13    1.982    1        0         0        0     amarelo

 **2182**  201510 22.14    19    2.897    1        0         0        0     amarelo

 **2183**  201511 21.57    12    1.83     0        1         0        0     amarelo

 **2184**  201512 20.14   26.05  3.972    0        1         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2452**  201507 22.43     5    0.7517    0        0         0        0     amarelo

 **2453**  201508 23.29    11    1.654     1        0         0        0     amarelo

 **2454**  201509 22.71    14    2.105     1        0         0        0     amarelo

 **2455**  201510 22.14    15    2.255     1        0         1        0     laranja

 **2456**  201511 21.57    12    1.804     0        1         0        0     laranja

 **2457**  201512 20.14   21.48  3.229     0        1         0        0     laranja
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2725**  201507 22.43     5    1.357     0        0         0        0     amarelo

 **2726**  201508 23.29     5    1.357     1        0         0        0     amarelo

 **2727**  201509 22.71     3    0.814     1        0         0        0     amarelo

 **2728**  201510 22.14     2    0.5427    1        0         0        0     amarelo

 **2729**  201511 21.57     4    1.085     0        1         0        0     amarelo

 **2730**  201512 20.14   1.636  0.4438    0        1         0        0     amarelo
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


