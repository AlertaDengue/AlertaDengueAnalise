#=============================
# Script para atualizar dados
#=============================

# Requer
library(knitr)
library(markdown)
library(foreign)
library(rmongodb)
rm(list=ls())
source("fun/callmongoclima.r")

#=============================
# A. Organizar os dados novos:
# ============================
# Selecione os novos dados:

# A1. Ultimos dados de dengue:
# esse e' o unico que precisa ser nominalmente indicado aqui. O dbf deve estar na pasta indicada no path do novosinan
#--------------------------
novosinan <- "dados_brutos/sinan/DENGON2014_24_11_2014_ogc.dbf"

# verificar os dados
d <- read.dbf(novosinan)[,c("DT_NOTIFIC","SEM_NOT","NU_ANO","DT_SIN_PRI",
                            "SEM_PRI","NM_BAIRRO")]
tail(d)

# se OK,
knit(input="organizaDados/organizasinan2014.rmd",quiet=TRUE,
     output="organizaDados/organizasinan2014.md",envir=new.env())

# A2. Ultimos dados de temperatura:
#-----------------------------
#(atualmente so uma estacao - galeao)
#novoclima <- "dados_brutos/clima/galeao_01012010-15062014.csv" # antigo
# atualmente capta direto da internet galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")

# verificar se funciona (OpenWeather) 
#galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")
#tail(galeao)  

# Atualizar os dados de temperatura (no console) - sempre colocar o domingo como data final
system(paste("fun/clima.py -i 2014-11-13 -f 2014-11-23 -c SBRJ"))
system(paste("fun/clima.py -i 2014-11-13 -f 2014-11-23 -c SBJR"))
system(paste("fun/clima.py -i 2014-11-13 -f 2014-11-23 -c SBAF"))
system(paste("fun/clima.py -i 2014-11-13 -f 2014-11-23 -c SBGL"))

# verificar se funciona (WundergroundWeather) 

tail(callmongoclima("galeao") )
tail(callmongoclima("jacarepagua") )
tail(callmongoclima("afonsos") )
tail(callmongoclima("santosdumont") )


#se OK:
knit(input="organizaDados/organizaTemperatura2.rmd",quiet=TRUE,
     output="organizaDados/organizaTemperatura2.md",envir=new.env())

# A3. Ultimos dados de tweet:
#-----------------------
# os dados sao capturados diretamente da API do Observatorio da dengue na UFMG ate a ultima data disponivel

# verificando os dados
system(paste("fun/pega_tweets.py -i 2014-01-05 -f ",Sys.Date())) # primeira SE de 2014 ate hoje
d<-read.csv("tweets_teste.csv",header=TRUE)[,1:2]
tail(d)

#Se OK:
knit(input="organizaDados/organizatweets.rmd",quiet=TRUE,
     output="organizaDados/organizatweets.md",envir=new.env())


# A4. Juntando os dados numa unica tabela (Nao mexer no comando!)

knit(input="organizaDados/juntaTudo.rmd",output="organizaDados/juntaTudo.md",quiet=FALSE, envir=new.env())
markdownToHTML("organizaDados/juntaTudo.md", "html/juntaTudo.html",fragment.only = TRUE)     
 
# Vale a pena conferir os dados em html/juntaTudo.html antes de prosseguir 

# =======================================
# E. Alerta: Para ajustar o modelo de alerta:
# =======================================
# Selecione os dados da semana desejada
dadosAPS<-"dados_limpos/dadosAPS_201447.csv"

knit(input="geraAlerta/geraAlerta.rmd",quiet=TRUE,envir=new.env())
markdownToHTML("geraAlerta.md",output="html/Alerta.html", fragment.only = TRUE) 


#wkhtmltopdf Alerta.html Alerta.pdf


