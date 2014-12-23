---
title: "Alerta Dengue Rio"
author: "Relatório de situação"
output: pdf_document
---






**Rio de Janeiro, 2014-12-23  (SE 201452)**


```
## Error in paste("../", alerta, sep = ""): objeto 'alerta' não encontrado
```

```
## Error in read.table(file = file, header = header, sep = sep, quote = quote, : objeto 'nalerta' não encontrado
```


* [Na cidade](#tab1)

* [Por APS](#tab2)


<br> </br>

### <a name="tab1"></a> Situação na cidade do Rio de Janeiro




![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png) 

\pagebreak

Últimas 6 semanas:


-----------------------------------------------------------
 &nbsp;     SE    casos   casos_corrigidos   tweets   Tmin 
--------- ------ ------- ------------------ -------- ------
 **254**  201446   32          38.28           47    20.46 

 **255**  201447   45           56.6           50    18.89 

 **256**  201448   29           39.3           46    22.34 

 **257**  201449   36          55.21           40    21.48 

 **258**  201450   14          26.37           46    22.91 

 **259**  201451   NA            NA            28    21.87 
-----------------------------------------------------------

Legenda:

- SE: semana epidemiológica
- casos: nímero de casos de dengue no SINAN
- casos_corrigidos: estimativa do número de casos notificados (ver [Notas](#notas))
- tweets: número de tweets relatando sintomas de dengue (ver [Notas](#notas))
- Tmin: média das temperaturas mínimas da semana



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



![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png) 

<br> </br>

Histórico da APS 1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **214**  201446 20.67     2    0.8812    0        0         0        0      verde 

 **224**  201447 20.17     4    1.762     0        0         0        0      verde 

 **125**  201448   22      2    0.8812    0        0         0        0      verde 

 **135**  201449 22.14     0      0       0        0         0        0      verde 

 **145**  201450 22.86     1    0.4406    1        0         0        0     amarelo

 **155**  201451 22.71     0      0       1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap21"></a> Alerta APS 2.1

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png) 

<br> </br>

Histórico da AP2.1

-----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **512**  201446 20.67     3    0.5428    0        0         0        0      verde 

 **517**  201447 20.17     2    0.3619    0        0         0        0      verde 

 **368**  201448   22      6    1.086     0        0         0        0      verde 

 **378**  201449 22.14     5    0.9047    0        0         0        0      verde 

 **388**  201450 22.86     4    0.7237    1        0         0        0     amarelo

 **398**  201451 22.71   6.433  1.164     1        0         0        0     amarelo
-----------------------------------------------------------------------------------



### <a name="ap22"></a> Alerta APS 2.2

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png) 

<br> </br>

Histórico da AP2.2

----------------------------------------------------------------------------------
 &nbsp;     SE    temp   casos   inc   AClima   ATweet   ATransm   ACasos   nivel 
--------- ------ ------ ------- ----- -------- -------- --------- -------- -------
 **770**  201446 20.67     6    1.617    0        0         0        0      verde 

 **767**  201447 20.17     7    1.886    0        0         0        0      verde 

 **612**  201448   22      0      0      0        0         0        0      verde 

 **622**  201449 22.14     9    2.425    0        0         0        0      verde 

 **632**  201450 22.86     0      0      1        0         0        0     amarelo

 **642**  201451 22.71   12.73  3.431    1        0         0        0     amarelo
----------------------------------------------------------------------------------



### <a name="ap31"></a> Alerta APS 3.1

![plot of chunk unnamed-chunk-35](figure/unnamed-chunk-35-1.png) 

<br> </br>

Histórico da AP3.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1026**  201446 20.71     3    0.4077    0        0         0        0      verde 

 **1023**  201447 19.43     1    0.1359    0        0         0        0      verde 

 **855**   201448 22.67     3    0.4077    0        0         0        0      verde 

 **865**   201449 21.86     0      0       0        0         0        0      verde 

 **875**   201450 23.33     0      0       0        0         0        0      verde 

 **885**   201451 22.29     0      0       0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap32"></a> Alerta APS 3.2

![plot of chunk unnamed-chunk-38](figure/unnamed-chunk-38-1.png) 

<br> </br>

Histórico da AP3.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1271**  201446 20.71     1    0.2042    0        0         0        0      verde 

 **1281**  201447 19.43     4    0.8168    0        0         0        0      verde 

 **1208**  201448 22.67     1    0.2042    0        0         0        0      verde 

 **1218**  201449 21.86     2    0.4084    0        0         0        0      verde 

 **1228**  201450 23.33     2    0.4084    0        0         0        0      verde 

 **1238**  201451 22.29   2.494  0.5092    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap33"></a> Alerta APS 3.3

![plot of chunk unnamed-chunk-41](figure/unnamed-chunk-41-1.png) 

<br> </br>

Histórico da AP3.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1552**  201446 20.71     0      0       0        0         0        0      verde 

 **1553**  201447 19.43     6    0.6491    0        0         0        0      verde 

 **1464**  201448 22.67     0      0       0        0         0        0      verde 

 **1474**  201449 21.86     3    0.3245    0        0         0        0      verde 

 **1484**  201450 23.33     0      0       0        0         0        0      verde 

 **1494**  201451 22.29   4.829  0.5224    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap4"></a> Alerta APS 4

![plot of chunk unnamed-chunk-44](figure/unnamed-chunk-44-1.png) 

<br> </br>

Histórico da AP4

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **1812**  201446 20.86     8    0.9537    0        0         0        0      verde 

 **1811**  201447 18.29    14    1.669     0        0         0        0      verde 

 **1708**  201448   23     10    1.192     0        0         0        0      verde 

 **1718**  201449 21.29     7    0.8345    0        0         0        0      verde 

 **1728**  201450   22      4    0.4768    0        0         0        0      verde 

 **1738**  201451 21.57   7.201  0.8584    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap51"></a> Alerta APS 5.1

![plot of chunk unnamed-chunk-47](figure/unnamed-chunk-47-1.png) 

<br> </br>

Histórico da AP5.1

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2069**  201446 19.86     5    0.7623    0        0         0        0      verde 

 **2067**  201447 17.29     4    0.6099    0        0         0        0      verde 

 **1951**  201448 22.14     2    0.3049    0        0         0        0      verde 

 **1961**  201449  20.5     3    0.4574    0        0         0        0      verde 

 **1971**  201450 22.83     1    0.1525    0        0         0        0      verde 

 **1981**  201451 20.71   2.698  0.4114    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap52"></a> Alerta APS 5.2

![plot of chunk unnamed-chunk-50](figure/unnamed-chunk-50-1.png) 

<br> </br>

Histórico da AP5.2

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2271**  201446 19.86     3    0.451     0        0         0        0      verde 

 **2281**  201447 17.29     3    0.451     0        0         0        0      verde 

 **2291**  201448 22.14     4    0.6013    0        0         0        0      verde 

 **2301**  201449  20.5     4    0.6013    0        0         0        0      verde 

 **2311**  201450 22.83     1    0.1503    0        0         0        0      verde 

 **2321**  201451 20.71   4.797  0.7211    0        0         0        0      verde 
------------------------------------------------------------------------------------



### <a name="ap53"></a> Alerta APS 5.3

![plot of chunk unnamed-chunk-53](figure/unnamed-chunk-53-1.png) 

<br> </br>

Histórico da AP5.3

------------------------------------------------------------------------------------
  &nbsp;     SE    temp   casos   inc    AClima   ATweet   ATransm   ACasos   nivel 
---------- ------ ------ ------- ------ -------- -------- --------- -------- -------
 **2540**  201446 19.86     1    0.2713    0        0         0        0      verde 

 **2550**  201447 17.29     0      0       0        0         0        0      verde 

 **2560**  201448 22.14     1    0.2713    0        0         0        0      verde 

 **2570**  201449  20.5     3    0.814     0        0         0        0      verde 

 **2580**  201450 22.83     1    0.2713    0        0         0        0      verde 

 **2590**  201451 20.71   7.004   1.9      0        0         0        0      verde 
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


