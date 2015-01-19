#=============================
# Script para atualizar dados
#=============================
rm(list=ls())

# Requer
library(knitr)
library(markdown)
library(foreign)
library(rmongodb)
source("fun/callmongoclima.r")

#=============================
# A. Organizar os dados novos:
# ============================

# A1. Atualizar dados de temperatura: 
source("organizaDados/organizaTemperatura.r")

# A2. Atualizar dados de tweet:
source("organizaDados//organizatweets.r")

 # A3. Atualizar dados de dengue:
# esse e' o unico que precisa ser nominalmente indicado aqui. 
# O dbf deve estar na pasta indicada no path dados_brutos/sinan/
novosinan2014 <- "dados_brutos/sinan/Dengue2014_12_01_2014.dbf"
novosinan2015 <- "dados_brutos/sinan/Dengue2015_12_01_2014.dbf"
source("organizaDados/organizasinan.r")


# A4. Juntar todos os dados numa unica tabela
source("organizaDados//juntaTudo.r")

# =======================================
# B. Alerta: Para ajustar o modelo de alerta:
# =======================================
# Selecione os dados da semana desejada
dadosAPS<-"dados_limpos/dadosAPS_201502.csv"
source("geraAlerta/geraAlerta.r")




## OLD ################################################



#knit(input="geraAlerta/geraAlerta.rmd",quiet=TRUE,envir=new.env()) # 
#markdownToHTML("geraAlerta.md",output="html/Alerta.html", fragment.only = TRUE) 
#alerta<-"alerta/alertaAPS_201453.csv"
#knit(input="geraAlerta/relatorio.rmd",quiet=TRUE,envir=new.env())
#wkhtmltopdf Alerta.html Alerta.pdf
