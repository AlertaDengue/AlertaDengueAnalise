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

# A1. Ultimos dados de dengue:
# esse e' o unico que precisa ser nominalmente indicado aqui. O dbf deve estar na pasta indicada no path do novosinan
#--------------------------
novosinan <- "dados_brutos/sinan/Dados_dengue_25_08_2014.dbf"

knit(input="organizaDados/organizasinan2014.rmd",quiet=TRUE,
     output="organizaDados/organizasinan2014.md",envir=new.env())

# A2. Ultimos dados de temperatura:
#-----------------------------
#(atualmente so uma estacao - galeao)
#novoclima <- "dados_brutos/clima/galeao_01012010-15062014.csv" # antigo
# atualmente capta direto da internet galeao<- read.csv2("http://gtsinan.no-ip.biz:8081/alerta/galeao.csv")

knit(input="organizaDados/organizaTemperatura2.rmd",quiet=TRUE,
     output="organizaDados/organizaTemperatura2.md",envir=new.env())

# A3. Ultimos dados de tweet:
#-----------------------
# os dados sao capturados diretamente da API do Observatorio da dengue na UFMG ate a ultima data disponivel

knit(input="organizaDados/organizatweets.rmd",quiet=TRUE,
     output="organizaDados/organizatweets.md",envir=new.env())


# A4. Juntando os dados numa unica tabela (Nao mexer no comando!)

knit(input="organizaDados/juntaTudo.rmd",output="organizaDados/juntaTudo.md",quiet=FALSE, envir=new.env())
markdownToHTML("organizaDados/juntaTudo.md", "html/html-organizacao/juntaTudo.html",fragment.only = TRUE)     
 
# =======================================
# E. Alerta: Para ajustar o modelo de alerta:
# =======================================
# Selecione os dados da semana desejada

# Dados do municipio do Rio de Janeiro (formato ../dados_limpos/dadosMRJ*.csv)
dadosMRJ <- "dados_limpos/dadosMRJ_201435.csv"

# Dados por APS (formato ../dados_limpos/dadosAPS*.csv)
dadosAPS<-"dados_limpos/dadosAPS_201435.csv"

knit(input="geraAlerta/geraAlertaMRJ.rmd",quiet=TRUE,envir=new.env())
knit(input="geraAlerta/geraAlertaAPS.rmd",quiet=TRUE,envir=new.env())

markdownToHTML("geraAlertaMRJ.md",output="AlertaMRJ.html",fragment.only = TRUE)  
markdownToHTML("geraAlertaAPS.md",output="AlertaAPS.html", fragment.only = TRUE)  





