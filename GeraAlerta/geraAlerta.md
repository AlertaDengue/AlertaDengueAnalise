Relatorio Semanal do Projeto Alerta Dengue para a cidade do Rio de Janeiro
===========================================================






**Rio de Janeiro, 2014-11-26  (SE 201448)**


```
## Error in paste("../", dadosAPS, sep = ""): objeto 'dadosAPS' não encontrado
```

```
## Error in read.table(file = file, header = header, sep = sep, quote = quote, : objeto 'dadosAPS' não encontrado
```

```
## Error in subset(d, SE >= 201001): objeto 'd' não encontrado
```

```
## Error in unique(d$APS): objeto 'd' não encontrado
```

```
## Error in corrigecasos(d$casos[d$APS == listaAPS[i]]): objeto 'd' não encontrado
```

Dengue a nivel da cidade
-----------------------


```
## Error in eval(expr, envir, enclos): objeto 'd' não encontrado
```

```
## Error in na.omit(dc): objeto 'dc' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'dc' não encontrado
```

Dados das ultimas 12 semanas:


```
## Error in aggregate(d[, "casos"], by = list(SE = d$SE), FUN = sum): objeto 'd' não encontrado
```

```
## Error in aggregate(d[, "casosm"], by = list(SE = d$SE), FUN = sum): objeto 'd' não encontrado
```

```
## Error in merge(casos, casosm, by = "SE"): objeto 'casos' não encontrado
```

```
## Error in names(cidade) <- c("SE", "casos", "casos_corrigidos"): objeto 'cidade' não encontrado
```

```
## Error in subset(d, APS == "AP1"): objeto 'd' não encontrado
```

```
## Error in aggregate(d[, "tempmin"], by = list(SE = d$SE), FUN = mean, na.rm = TRUE): objeto 'd' não encontrado
```

```
## Error in names(dc)[2] <- "tempmin": objeto 'dc' não encontrado
```

```
## Error in merge(cidade, dt, by = "SE"): objeto 'cidade' não encontrado
```

```
## Error in merge(cidade, dc, by = "SE"): objeto 'cidade' não encontrado
```

```
## Error in tail(cidade, n = 12): objeto 'cidade' não encontrado
```

Legenda:

- SE: semana epidemiologica
- casos: numero de casos de dengue no SINAN
- casos_corrigidos: estimativa do numero de casos notificados (1)
- tweets: numero de tweets relatando sintomas de dengue (2)
- tempmin: media das temperaturas minimas da semana



```
## Error in subset(cidade, SE >= 201101): objeto 'cidade' não encontrado
```

```
## Error in plot(cidade$tweets, type = "l", ylab = "tweets", axes = FALSE, : objeto 'cidade' não encontrado
```

```
## Error in axis(2): plot.new has not been called yet
```

```
## Error in eval(expr, envir, enclos): objeto 'cidade' não encontrado
```

```
## Error in seq(le, 1, by = -12): objeto 'le' não encontrado
```



```
## Error in plot(cidade$casos, type = "l", xlab = "", ylab = "casos notificados no MRJ", : objeto 'cidade' não encontrado
```

```
## Error in axis(2): plot.new has not been called yet
```

```
## Error in seq(le, 1, by = -12): objeto 'le' não encontrado
```


```
## Error in plot(cidade$tempmin, type = "l", ylab = "temperatura", axes = FALSE, : objeto 'cidade' não encontrado
```

```
## Error in axis(2): plot.new has not been called yet
```

```
## Error in eval(expr, envir, enclos): objeto 'cidade' não encontrado
```

```
## Error in seq(le, 1, by = -12): objeto 'le' não encontrado
```




```
## Error in which(is.na(d$tempmin)): objeto 'd' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'm' não encontrado
```

```
## Error in which(is.na(d$tempmin)): objeto 'd' não encontrado
```

Alerta por APS em 4 niveis
-------------

**Verde (atividade baixa)** 
- se temperatura < 22 graus por 3 semanas 
- se atividade de tweet for normal (nao aumentada)
- ausencia de transmissao sustentada
- se incidencia < 100:100.000

**Amarelo (Alerta)**
- se temperatura > 22C por mais de 3 semanas
- se atividade de tweet aumentar

**Laranja (Transmissao sustentada)**
- se numero reprodutivo >1, por 3 semanas

**Vermelho (atividade alta)**
- se incidencia > 100:100.000


```
## Error in eval(expr, envir, enclos): objeto 'd' não encontrado
```

```
## Error in expand.grid(SE = SE, APS = listaAPS): objeto 'SE' não encontrado
```

```
## Error in merge(d2, d[, c("SE", "APS", "data", "tweets", "estacao", "casos", : objeto 'd2' não encontrado
```

```
## Error in merge(d2, pop): objeto 'd2' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```



```
## Error in d2$alertaCli <- NA: objeto 'd2' não encontrado
```

```
## Error in detcli(d2$tempmin[d2$APS == listaAPS[i]]): objeto 'd2' não encontrado
```



```
## Error in d2$Rtw <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$ptw1 <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$Rtwlr <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$Rtwur <- NA: objeto 'd2' não encontrado
```

```
## Error in Rt.beta(d2$tweets[d2$APS == listaAPS[i]]): objeto 'd2' não encontrado
```

```
## Error in Rtgreat1(d2$ptw1[d2$APS == listaAPS[i]], pcrit = 0.9, lag = 0): objeto 'd2' não encontrado
```

```
## Error in Rtgreat1(d2$ptw1[d2$APS == listaAPS[i]], pcrit = 0.9, lag = 3): objeto 'd2' não encontrado
```



```
## Error in d2$Rt <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$pRt1 <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$Rtlr <- NA: objeto 'd2' não encontrado
```

```
## Error in d2$Rtur <- NA: objeto 'd2' não encontrado
```

```
## Error in Rt.beta((d2$casosm[d2$APS == listaAPS[i]])): objeto 'd2' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```

```
## Error in Rtgreat1(d2$pRti[d2$APS == listaAPS[i]], pcrit = 0.9, lag = 0): objeto 'd2' não encontrado
```

```
## Error in Rtgreat1(d2$pRti[d2$APS == listaAPS[i]], pcrit = 0.9, lag = 3): objeto 'd2' não encontrado
```





```
## Error in d2$casos_est <- NA: objeto 'd2' não encontrado
```

```
## Error in fillCasos((d2$casos[d2$APS == listaAPS[i]]), d2$Rt[d2$APS == : objeto 'd2' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```

```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```


Resultado
---------

**Legenda:**
- SE : semana epidemiologica
- data: data de inicio da SE
- APS: area programatica da saude
- tempmin: media das temperaturas minimas da semana
- casos_est: numero de casos estimados na semana (3)
- inc: casos por 100.000 habitantes
- alertaClima = 1, se temperatura > 22C por mais de 3 semanas
- alertaTweet = 1, se Tweet com tendencia de aumento 
- alertaTransmissao = 1, se casos com tendencia de aumento
- alertaCasos = 1, se Incidencia > 100 por 100 mil

 


```
## Error in eval(expr, envir, enclos): objeto 'd2' não encontrado
```

```
## Error in d2$cor <- NA: objeto 'd2' não encontrado
```

```
## Error in def.cor(d2[d2$APS == listaAPS[i], ]): objeto 'd2' não encontrado
```

```
## Error in ifelse(d2$alertaRtweet >= 3, 1, 0): objeto 'd2' não encontrado
```

```
## Error in ifelse(d2$alertaCli >= 3, 1, 0): objeto 'd2' não encontrado
```

```
## Error in ifelse(d2$alertaRt >= 3, 1, 0): objeto 'd2' não encontrado
```

```
## Error in d2$nivel <- "nulo": objeto 'd2' não encontrado
```

```
## Error in d2$nivel[d2$cor == 1] <- "verde": objeto 'd2' não encontrado
```

```
## Error in d2$nivel[d2$cor == 2] <- "amarelo": objeto 'd2' não encontrado
```

```
## Error in d2$nivel[d2$cor == 3] <- "laranja": objeto 'd2' não encontrado
```

```
## Error in d2$nivel[d2$cor == 4] <- "vermelho": objeto 'd2' não encontrado
```

```
## Error in print(as.character(listaAPS[i])): objeto 'listaAPS' não encontrado
```











```
## Error in is.data.frame(x): objeto 'd2' não encontrado
```

**Confira o mapa da dengue em alerta.dengue.mat.br**

Notas
-----
- (1) Os dados do sinan mais recentes ainda nao foram totalmente digitados. Estimamos o numero esperado de casos
notificados considerando o tempo ate os casos serem digitados.
- (2) Os dados de tweets sao gerados pelo Observatorio de Dengue (UFMG). Os tweets sao processados para exclusao de informes e outros temas relacionados a dengue
- (3) Algumas vezes, os casos da ultima semana ainda nao estao disponiveis, nesse caso, usa-se uma estimacao com base na tendencia de variacao da serie 

Creditos
------
Esse e um projeto desenvolvido em parceria pela Fiocruz, FGV e Prefeitura do Rio de Janeiro, com apoio da SVS/MS

Mais detalhes, ver: www.dengue.mat.br
