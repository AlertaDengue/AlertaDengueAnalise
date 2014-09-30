#=============================
# Script para atualizar dados
#=============================

# Requer
library(knitr)
library(markdown)
#library(lubridate)
library(xts)
require(foreign)
rm(list=ls())

#--------------
#Etapa inicial:
#-------------

#1) Verificar se ha dados novos em: 
#     sftp://alertadengue@200.20.164.152
#     senha: Sqv4tRoh8GNayFoR      
      
#2) Copiar os dados novos  na subpasta correpondente em /dados_brutos/ 


#=============================
# A. Para organizar os dados novos:
# ============================
# Selecione os novos dados:

#-------------------------
# 1. Ultimos dados de dengue:
#--------------------------
novosinan <- "dados_brutos/sinan/Dengue2014_23_06_2014.dbf"

#-----------------------------
# 2. Ultimos dados de temperatura:
#-----------------------------
#(atualmente so uma estacao - galeao)
#novoclima <- "dados_brutos/clima/galeao_01012010-15062014.csv" # antigo
# atualmente capta direto da internet galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")

#-----------------------
# 3. Ultimos dados de tweet:
#-----------------------
# Precisamos de 3 arquivos:
# Ultimo arquivo semanal de tweet (pasta ../dados_limpos/)
ult_tweet_limpo <- "dados_limpos/tweet_201425.csv"

# Ultimo arquivo diario de tweet (pasta ../dados_brutos/)
ultimotweet_diario<-"dados_brutos/tweet/tweet_18062014_24062014.csv"

# Penultimo arquivo diario de tweet (pasta ../dados_brutos/)
penultimotweet_diario<-"dados_brutos/tweet/tweet_11062014_17062014.csv"


#Organizando os dados separadamente
# Nao precisa mexer nessa secao, so' executar

knit(input="organizaDados/organizasinan2014.rmd",quiet=TRUE,
     output="organizaDados/organizasinan2014.md",envir=new.env())

knit(input="organizaDados/organizatweets.rmd",quiet=TRUE,
     output="organizaDados/organizatweets.md",envir=new.env())

knit(input="organizaDados/organizaTemperatura2.rmd",quiet=TRUE,
     output="organizaDados/organizaTemperatura2.md",envir=new.env())

markdownToHTML("organizaDados/organizasinan2014.md", "html/html-organizacao/organizasinan2014.html",fragment.only = TRUE)
markdownToHTML("organizaDados/organizasinan2014.md", "html/html-organizacao/organizatweets.html",fragment.only = TRUE)
markdownToHTML("organizaDados/organizasinan2014.md", "html/html-organizacao/organizaTemperatura.html",fragment.only = TRUE)

#---------------------------------------
# 4. Os comandos acima geraram .csv com dados separados, falta junta-los
#---------------------------------------
# Selecione os dados a serem juntados:

#Casos de Dengue no MRJ (formato: sinanRJ_*.csv)
dengueRJlimpo <- "dados_limpos/sinanRJ_201425.csv"

# Casos de Dengue por APS (formato: sinanAPS_*.csv)
dengueAPSlimpo <-"dados_limpos/sinanAP_201425.csv"

# Tweets (formato: tweet_*.csv)
twlimpo<- "dados_limpos/tweet_201425.csv"

# Clima (formato: temp_*.csv)
climalimpo<-"dados_limpos/temp_201425.csv"


# # D. Juntando os dados numa unica tabela (Nao mexer no comando!)


knit(input="organizaDados/juntaTudo.rmd",output="organizaDados/juntaTudo.md",quiet=FALSE, envir=new.env())
markdownToHTML("organizaDados/juntaTudo.md", "html/html-organizacao/juntaTudo.html",fragment.only = TRUE)     
 
# =======================================
# E. Alerta: Para ajustar o modelo de alerta:
# =======================================
# Selecione os dados

# Dados do municipio do Rio de Janeiro (formato ../dados_limpos/dadosMRJ*.csv)
dadosMRJ <- "dados_limpos/dadosMRJ_201425.csv"

# Dados por APS (formato ../dados_limpos/dadosAPS*.csv)
dadosAPS<-"dados_limpos/dadosAPS_201425.csv"

# E. Alerta: Atualizar
# PS Nao mexer

knit(input="geraAlerta/geraAlertaMRJ.rmd",quiet=TRUE,envir=new.env())

knit(input="geraAlerta/geraAlertaAPS.rmd",quiet=TRUE,envir=new.env())

markdownToHTML("geraAlertaMRJ.md",output="AlertaMRJ.html",fragment.only = TRUE)  
markdownToHTML("geraAlertaAPS.md",output="AlertaAPS.html", fragment.only = TRUE)  





