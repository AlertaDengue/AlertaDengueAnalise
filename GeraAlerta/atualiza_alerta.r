#=============================
# Script para atualizar dados
#=============================
rm(list=ls())

# Requer
library(knitr)
library(markdown)
library(foreign)
library(rmongodb)
library(rgeos)
library(maptools)
source("fun/callmongoclima.r")

#=============================
# A. Organizar os dados novos:
# ============================

# A1. Atualizar dados de temperatura (verificar se tem conexão internet): 
source("organizaDados/organizaTemperatura.r")

# A2. Atualizar dados de tweet:
source("organizaDados/organizatweets.r")

# A3. Atualizar dados de dengue:
# esse e' o unico que precisa ser nominalmente indicado aqui. 
# O dbf deve estar na pasta indicada no path dados_brutos/sinan/
novosinan2014 <- "dados_brutos/sinan/Dengue2014_23_03_2015.dbf"
novosinan2015 <- "dados_brutos/sinan/Dengue2015_27_04_2015.dbf"
# esse source retorna os casos que nao foram geolocalizados, verificar se algum pode
# ser resolvido. A tabela APS-bairro esta na pasta tabelas.
source("organizaDados/organizasinan.r")


# A4. Juntar todos os dados numa unica tabela
source("organizaDados//juntaTudo.r")

# =======================================
# B. Alerta: Para ajustar o modelo de alerta:
# =======================================
# Selecione os dados da semana desejada
dadosAPS<-"dados_limpos/dadosAPS_201516.csv"
source("geraAlerta/geraAlerta.r")




