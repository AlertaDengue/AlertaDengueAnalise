# ======================================
# Arquivo de execução do Alerta Dengue
# ======================================
rm(list=c()) # limpar o workspace

library(foreign)
library(RPostgreSQL)
#library(AlertTools)
library(devtools)
devtools::load_all()
source("../config.R") # valores dos parametros (params)
source("../pipeline.R") # funcoes pipeline e gerafigura

# ================================
# Definir output
# ================================
# Quer salvar o resultado do Alerta no Banco de Dados? 
escreverBD <- FALSE   # use TRUE apenas quando tiver seguro pois irá aparecer no mapa web
# Quer gerar figuras?
salvafiguras <- TRUE

# =========================
# Abrindo o banco de dados
# =========================
con <- DenguedbConnect()

# verificando as ultimas datas de cada tabela
data2SE(lastDBdate("sinan"), format="%Y-%m-%d")
data2SE(lastDBdate("tweet"), format="%Y-%m-%d")
data2SE(lastDBdate("clima_wu"), format="%Y-%m-%d")
data2SE(lastDBdate("historico"), format="%Y-%m-%d")

# default do alerta (ultima semana de sinan)
datafim <- data2SE(lastDBdate("sinan"), format="%Y-%m-%d")

# ================================
# Alerta Estado do Rio de Janeiro
# ================================
#Regionais: "Metropolitana I"   "Metropolitana II"  "Litoral Sul"
# "Médio Paraíba" "Centro Sul" "Serrana" "Baixada Litorânea" "Norte"            
#"Noroeste" 

run.pipeline(regional = "Metropolitana I", params = RJ.met1, sfigs = salvafiguras)
run.pipeline(regional = "Metropolitana II", params = RJ.met2, sfigs = salvafiguras)
run.pipeline(regional = "Litoral Sul", params = RJ.litoralsul, sfigs = salvafiguras)
run.pipeline(regional = "Médio Paraíba", params = RJ.medparaiba, sfigs = salvafiguras)
run.pipeline(regional = "Centro Sul", params = RJ.centrosul, sfigs = salvafiguras)
run.pipeline(regional = "Serrana", params = RJ.serrana, sfigs = salvafiguras)
run.pipeline(regional = "Baixada Litorânea", params = RJ.baixadalit, sfigs = salvafiguras)
run.pipeline(regional = "Norte", params = RJ.norte, sfigs = salvafiguras)
run.pipeline(regional = "Noroeste", params = RJ.noroeste, sfigs = salvafiguras)

# capital (separado)
run.pipeline(cidade = 330455, params = RJ.capital, sfigs = salvafiguras)
