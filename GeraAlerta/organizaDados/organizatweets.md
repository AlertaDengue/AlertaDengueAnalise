Organização dos dados do tweet RJ
===================================
Concatena os dados mais recentes com a serie historica. Sao precisos 3 dados de entrada:
- serie historica em semanas (a mais atualizada que tiver)
- ultima serie de tweets recem-recebidos, diarios
- penultima serie de tweets diarios (necessario porque as vezes a semana epidemiologica nao fecha direitinho) 





Dados 
-----

**Serie historica de tweets por semana:**

```r
ult_tweet_limpo<-paste("../",ult_tweet_limpo,sep="")
dant<-read.csv(ult_tweet_limpo)
```

**Penultima serie da tweets diarios:**


```r
penultimotweet_diario<-paste("../",penultimotweet_diario,sep="")
d1<-read.table(penultimotweet_diario,sep=",",header=TRUE)[,c("data","rio")]
d1
```

```
##         data rio
## 1 2014-06-11  13
## 2 2014-06-12   7
## 3 2014-06-13   4
## 4 2014-06-14  14
## 5 2014-06-15  10
## 6 2014-06-16  15
## 7 2014-06-17   4
```

**Ultima serie de tweets diarios:**

```r
ultimotweet_diario<-paste("../",ultimotweet_diario,sep="")
d2<-read.csv(ultimotweet_diario)[,c("data","rio")]
d2
```

```
##         data rio
## 1 2014-06-18   7
## 2 2014-06-19  11
## 3 2014-06-20   5
## 4 2014-06-21   3
## 5 2014-06-22  10
## 6 2014-06-23   5
## 7 2014-06-24  10
```

Concatenacao
------------

Concatenar as series diarias, preenchendo com NA, se necessario.




A serie tem 4 dias na primeira semana e 3 dias na ultima semana. Serao removidos.

**Tweets/semana**

```
##       SE tweets
## 2 201425     55
```



![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9.png) 

Salvar
------



O arquivo de saida e' ../dados_limpos/tweet_201425.csv  


```r
write.table(twRJ,file=outputfile,sep=",",row.names=FALSE)
```

