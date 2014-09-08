Alerta de Dengue a nivel de APS - Rio de Janeiro
======================
versao 0.1






**Hoje e' dia 2014-08-25 , SE 201435**




**Curvas epidemicas da dengue por APS (periodo: 2010-)**


![plot of chunk unnamed-chunk-4](figure/unnamed-chunk-4.png) 



Os ultimos dados disponiveis de casos de dengue se referem a'semana 201434:


```
##   AP1 AP2.1 AP2.2 AP3.1 AP3.2 AP3.3   AP4 AP5.1 AP5.2 AP5.3 
##    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA
```







**Tweet na cidade**



Os ultimos dados disponiveis de tweet sao da semana 201434:


```
##          SE tweets
## 2435 201430     55
## 2436 201431     54
## 2437 201432     68
## 2438 201433     47
## 2439 201434     50
## 2440 201435     NA
```

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10.png) 



```
## Error: undefined columns selected
```

**Temperatura**





```
## Error: objeto 'd3' não encontrado
```

Os ultimos dados disponiveis de temperatura minima sao da semana 201434. 


```
## Error: objeto 'd3' não encontrado
```

      

Modelo de alerta com 3 indicadores
========

- Temperatura minima semanal > 22 graus  : condicoes propicias para o desenvolvimento do vetor
- Rt > 1 : casos com tendencia de aumento
- Casos > Media + 1.96dp : casos acima de (calculado para todo o periodo 2010-presente) 


**1. Estimando Rt (dengue) a partir dos dados de tweet e clima**

Como os dados de dengue sao em geral atrasados em relacao aos tweets e a temperatura, o sistema estima o Rt da dengue 
utilizando um modelo de regressao linear com as variaveis Rt (tweets) e temperatura. O modelo e ajustado a toda a serie 
historica e usado para estimar os valores faltantes de Rt(dengue).

*Rtd(SE) = b0 + b1xRtw(SE) + b2xtemp.min(SE) + b3xRtw(SE)xtemp.min(SE) + error**

No grafico abaixo:

- preto = serie observada de Rt(dengue)
- vermelha = serie predita pelo modelo 


```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'AP1' não encontrado
```



```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```

```
## Error: plot.new has not been called yet
```

```
## Error: plot.new has not been called yet
```

```
## Error: plot.new has not been called yet
```

```
## Error: objeto 'd3' não encontrado
```



```
## Error: objeto 'd3' não encontrado
```



```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```



```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd3' não encontrado
```

**Serie de casos estimados**

O alerta de epidemia dispara quando casos excedem o limiar "media + 1.96 dp". 
O Rt(dengue) estimado previamente e' utilizado para reconstruir a curva epidemica e completar os dados 
faltantes

*casos(SE+1)=casos(SE)xRt_est(dengue)*

O grafico abaixo mostra a serie de casos por APS nas ultimas 70 semanas.

Legenda:
- preto = dados do sinan 
- vermelha = serie reconstruida de casos de dengue a partir do modelo 



```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: plot.new has not been called yet
```

```
## Error: plot.new has not been called yet
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: plot.new has not been called yet
```

```
## Error: objeto 'd4' não encontrado
```




```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```

**Alerta por APS**

Para cada APS, indica-se as semanas em que houve alerta de temperatura, de Rt e de casos.
O alerta e' indicado pela linha cinza no grafico.

Tambem mostramos para cada APS, os valores dos indicadores nas ultimas 6 semanas. Esses indicadores
serao usados para criar o codigo de cores do alerta.


```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```


```
## Error: objeto 'listaAP' não encontrado
```


**Salvar**



```
## Error: objeto 'd4' não encontrado
```

```
## Error: objeto 'd4' não encontrado
```


```
## Error: objeto de tipo 'closure' não possível dividir em subconjuntos
```


