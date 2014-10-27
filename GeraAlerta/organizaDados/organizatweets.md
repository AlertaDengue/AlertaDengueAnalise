Organização dos dados do tweet RJ
===================================
Concatena os dados mais recentes com a serie historica. Sao precisos 3 dados de entrada:
- serie historica em semanas (a mais atualizada que tiver)
- ultima serie de tweets recem-recebidos, diarios
- penultima serie de tweets diarios (necessario porque as vezes a semana epidemiologica nao fecha direitinho) 





Dados 
-----

**Serie historica de tweets por semana (2010-2013):**

```r
dant<-read.csv("../dados_limpos/tweets_week_2010-2013.csv")
```

**Serie de 2014 de tweets diarios:**

```r
comando<-paste("../fun/pega_tweets.py -i 2014-01-05 -f ",Sys.Date()) # primeira SE de 2014 ate hoje
system(comando)
d<-read.csv("tweets_teste.csv",header=TRUE)[,1:2]
names(d)[2]<-"rio"
```

Concatenacao
------------

Concatenar as series diarias, preenchendo com NA, se necessario.

```
## Error: objeto 'd1' não encontrado
```



A serie tem 7 dias na primeira semana e 1 dias na ultima semana. Serao removidos.

**Tweets/semana**

```
##        SE tweets
## 1  201402     77
## 2  201403     82
## 3  201404     76
## 4  201405     91
## 5  201406     65
## 6  201407     77
## 7  201408     68
## 8  201409     77
## 9  201410     75
## 10 201411     66
## 11 201412     92
## 12 201413     63
## 13 201414     65
## 14 201415     76
## 15 201416     66
## 16 201417     64
## 17 201418    107
## 18 201419    146
## 19 201420    114
## 20 201421     92
## 21 201422     80
## 22 201423     55
## 23 201424     62
## 24 201425     63
## 25 201426     80
## 26 201427     49
## 27 201428     62
## 28 201429     55
## 29 201430     60
## 30 201431     64
## 31 201432     64
## 32 201433     42
## 33 201434     47
## 34 201435     81
## 35 201436     46
## 36 201437     45
## 37 201438     57
## 38 201439     80
## 39 201440     65
## 40 201441    143
## 41 201442    105
## 42 201443     88
```



![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8.png) 

Salvar
------


```r
write.table(twRJ,file="../dados_limpos/tweetsemanaRJ.csv",sep=",",row.names=FALSE)
```

