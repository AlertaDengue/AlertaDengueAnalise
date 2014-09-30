######################
## Concatena tweets
######################

# Funcao que concatena uma ou mais tabelas de tweets e 
# verifica se ha dados faltantes. Colocar em ordem crescente de data

concatweet<-function(d1,d2,na=TRUE){
      # verifica se o primeiro campo e' data
      d1[,1]<-as.Date(d1[,1],format="%Y-%m-%d")
      d2[,1]<-as.Date(d2[,1],format="%Y-%m-%d")
      t1 <- dim(d1)[1]
      t2 <- dim(d2)[1]
      # verificar se a sequencia esta correta
      lag <- d2$data[1] - d1$data[t1] 
      if(lag == 1) d<-rbind(d1,d2)  # tudo ok
      else {
            warning(paste("tem", d2$data[1] - d1$data[t1], "dias faltantes, NA incluido"))
            d<-d1
            for (i in 1:lag) d<-rbind(d, data.frame(data=d[dim(d)[1],1]+1, rio=NA))
            d <- rbind(d,d2)
            }
      d     
}

#d1<-read.csv("dados/tweets_13052014_22052014.csv",sep="\t")
#d2<-read.csv("dados/tweets_23052014_03062014.csv")
#d<-concatweet(d1,d2)
