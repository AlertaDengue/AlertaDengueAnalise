---
title: "Info Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2015-02-24  (SE 201508)**




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
 **263**  201502   40          46.02           51     25.2 

 **264**  201503   29          34.91           62    24.37 

 **265**  201504   27          34.86           48     24.4 

 **266**  201505   27          39.19           64    22.27 

 **267**  201506    5          9.097           47    24.84 

 **268**  201507   NA            NA            57    23.43 
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
 **263**  201502 26.57     1    0.4406    1        0         0        0     amarelo

 **264**  201503 26.14     1    0.4406    1        0         0        0     amarelo

 **265**  201504   26      0      0       1        0         0        0     amarelo

 **266**  201505 24.14     0      0       1        0         0        0     amarelo

 **267**  201506   26      0      0       1        0         0        0     amarelo

 **268**  201507   25      0      0       1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **531**  201502 26.57     4    0.7237    1        0         0        0     amarelo

 **532**  201503 26.14     2    0.3619    1        0         0        0     amarelo

 **533**  201504   26      7    1.267     1        0         0        0     amarelo

 **534**  201505 24.14     3    0.5428    1        0         0        0     amarelo

 **535**  201506   26      0      0       1        0         0        0     amarelo

 **536**  201507   25    2.954  0.5344    1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png) 

<br> </br>

Histórico da AP2.2

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **799**  201502 26.57     1    0.2695    1        0         0        0     amarelo

 **800**  201503 26.14     2    0.5389    1        0         0        0     amarelo

 **801**  201504   26      3    0.8084    1        0         0        0     amarelo

 **802**  201505 24.14     3    0.8084    1        0         0        0     amarelo

 **803**  201506   26      0      0       1        0         0        0     amarelo

 **804**  201507   25    4.293  1.157     1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1067**  201502 25.86     9    1.223     1        0         0        0     amarelo

 **1068**  201503 24.86     2    0.2718    1        0         0        0     amarelo

 **1069**  201504 24.29     3    0.4077    1        0         0        0     amarelo

 **1070**  201505 20.71     2    0.2718    0        0         0        0     amarelo

 **1071**  201506 25.29     0      0       0        0         0        0     amarelo

 **1072**  201507 22.43   1.104  0.1501    0        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-23](figure/unnamed-chunk-23-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1335**  201502 25.86     6    1.225     1        0         0        0     amarelo

 **1336**  201503 24.86     3    0.6126    1        0         0        0     amarelo

 **1337**  201504 24.29     5    1.021     1        0         0        0     amarelo

 **1338**  201505 20.71     4    0.8168    0        0         0        0     amarelo

 **1339**  201506 25.29     1    0.2042    0        0         0        0     amarelo

 **1340**  201507 22.43   3.741  0.764     0        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1603**  201502 25.86     5    0.5409    1        0         0        0     amarelo

 **1604**  201503 24.86     5    0.5409    1        0         0        0     amarelo

 **1605**  201504 24.29     4    0.4327    1        0         0        0     amarelo

 **1606**  201505 20.71     0      0       0        0         0        0     amarelo

 **1607**  201506 25.29     2    0.2164    0        0         0        0     amarelo

 **1608**  201507 22.43     0      0       0        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1871**  201502 24.43     7    0.8345    1        0         0        0     amarelo

 **1872**  201503 23.86     5    0.596     1        0         0        0     amarelo

 **1873**  201504   25      4    0.4768    1        0         0        0     amarelo

 **1874**  201505 23.43    10    1.192     1        0         0        0     amarelo

 **1875**  201506 25.57     1    0.1192    1        0         0        0     amarelo

 **1876**  201507 24.71   13.36  1.592     1        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP5.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2139**  201502 23.43     4    0.6099    1        0         0        0     amarelo

 **2140**  201503 22.29     4    0.6099    1        0         0        0     amarelo

 **2141**  201504 22.71     1    0.1525    1        0         0        0     amarelo

 **2142**  201505 21.57     1    0.1525    0        0         0        0     amarelo

 **2143**  201506   23      1    0.1525    0        0         0        0     amarelo

 **2144**  201507 22.43  0.7058  0.1076    0        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2407**  201502 23.43     3    0.451     1        0         0        0     amarelo

 **2408**  201503 22.29     5    0.7517    1        0         0        0     amarelo

 **2409**  201504 22.71     0      0       1        0         0        0     amarelo

 **2410**  201505 21.57     4    0.6013    0        0         0        0     amarelo

 **2411**  201506   23      0      0       0        0         0        0     amarelo

 **2412**  201507 22.43   4.994  0.7508    0        0         0        0     amarelo
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP5.3

-----------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **2675**  201502 23.43     0      0      1        0         0        0     amarelo

 **2676**  201503 22.29     0      0      1        0         0        0     amarelo

 **2677**  201504 22.71     0      0      1        0         0        0     amarelo

 **2678**  201505 21.57     0      0      0        0         0        0     amarelo

 **2679**  201506   23      0      0      0        0         0        0     amarelo

 **2680**  201507 22.43    NA     NA      0        0         0        NA    amarelo
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


