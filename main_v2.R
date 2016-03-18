# ======================================
# Arquivo de execução do Alerta Dengue
# ======================================
rm(list=c()) # limpar o workspace

library(foreign)
library(RPostgreSQL)
#library(AlertTools)
library(devtools)
devtools::load_all()
source("../config.R") # configuracao do alerta (pipeline)


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

# para rodar para uma cidade especifica:
cid <- list(geocodigo = 330450, estacao="SBGL",pdig = c(2.791400,0.9913278),
            tcrit = 22, inccrit = 100)
res = run.pipeline(lugar = cid, sefinal = datafim, sfigs = salvafiguras)

regioes <- c("RJ.noroeste", "RJ.norte", "RJ.serrana", "RJ.lagos", "RJ.metropol", "RJ.centrosul", 
             "RJ.medparaiba", "RJ.costaverde", "RJ.capital")
for (reg in regioes) run.pipeline(lugar = eval(parse(text=reg)), sefinal = datafim, sfigs = salvafiguras)

