library("AlertTools"); library(assertthat) ; library(tidyverse)

### 1. O que temos desse estado no banco de dados?
UF = "Rio Grande do Sul"
con <- DenguedbConnect(pass = pw)
(getRegionais(uf = UF))
(getRegionais(uf = UF, macroreg = TRUE))
cid = getCidades(uf = UF, datasource=con)
nrow(cid)
head(cid)

save(cid, file = "cid.RData")
# Se todas as cidades estao presentes, siga para (3)

### 2. Seu municipio(s) não está? Coloque-o, usando informacao do IBGE (se adequado)
nomedacidade = "Porto Alegre"
geocodigo =  4314902 #tabuf$Código.Município.Completo[tabuf$Nome_Município==nomedacidade]
id =  1# tabuf$Mesorregião.Geográfica[tabuf$Nome_Município==nomedacidade]
nomereg = "Porto Alegre" #tabuf$Nome_Mesorregião[tabuf$Nome_Município==nomedacidade]
# nao sei se funciona
insert_city_infodengue(geocodigo=geocodigo, regional = "Porto Alegre", id_regional=id)

### 2a. Quer colocar o estado todo de uma vez? Nao se preocupe, quem tiver já no banco nao sera mexido
## (adaptar para incluir macroregiao)

tabuf <- read.csv("../Regionais_Saude_CE.csv") # qdo é custmizada a regional de saude
names(tabuf)
tabuf <- tabuf[,c(10,11,9)]
names(tabuf)[1:3]<-c("nome_municipio","nome_regional","municipio_geocodigo")  # incluir nome_macroreg se tiver
head(tabuf)
unique(tabuf$nome_regional)
n = dim(tabuf)[1]
for (i in 2:n){
  nomedacidade = tabuf$nome_municipio[i]
  geocodigo = tabuf$municipio_geocodigo[tabuf$nome_municipio==nomedacidade]
  id = 0 #id=tabuf$id_regional[tabuf$nome_municipio==nomedacidade]
  nomereg = tabuf$nome_regional[tabuf$nome_municipio==nomedacidade]
  insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg, senha=pw)
  
}

macroreg=getRegionais(uf = "Minas Gerais", macroreg = TRUE)
reg=getRegionais(uf = "Minas Gerais")


### 3. Inserção das estacoes meteorologicas na tabela das regionais - requer SENHA
# ----------------------------------------------------------------
#https://estacoes.dengue.mat.br/

# Usar a tabela gerada pelo estacoes.dengue. Se os dados forem ruins, a opcao é selecionar
# as estacoes na mao. Script:# Vamos agora verificar a qualidade das estacoes usando script 
#tutoriais/relatorio-qualidade-dados


# funcao para escrever a partir do csv
escrevewu <- function(csvfile=NULL, UF, senha){
  if(!is.null(csvfile)){  # csvfile vem do estacoes-mais-proximas
    wus <- read.csv(csvfile,header = F)
    wusES <- wus[,c(2,4,6)]
    names(wusES) <- c("geocodigo", "estacao", "dist")  
    newdat <- data.frame(municipio_geocodigo=unique(wusES$geocodigo), 
                         primary_station=NA,
                         secondary_station=NA)
    for(cid in newdat$municipio_geocodigo) {
      estacoes <- wusES[wusES$geocodigo==cid,]
      estacoes <- estacoes[order(estacoes$dist, decreasing = FALSE),] # ordm cresc distancia
      newdat$primary_station[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[1])
      newdat$secondary_station[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[2])
    }
  }
  
  setWUstation(st = newdat, UF = UF, senha = senha)
  newdat
}

escrevewu(csvfile="estacoes/estações-mais-proximasRS.csv", UF = "Rio Grande do Sul")
#escrevewu(lista=CE.Reg.estacoes)

# PS. Na mão: usar setWUstation()
# uma:
dados <- data.frame(municipio_geocodigo = geocodigo, 
                    primary_station = "SBPA", secondary_station = "SBNM")
setWUstation(dados, senha ="",UF = "Rio Grande do Sul")

# varias:
# essa tabela foi criada a mão (verificar se os nomes estao iguais ao da getRegionais)
ests <- data.frame(nome = c("NORTE", "NORDESTE", "NOROESTE","JEQUITINHONHA",
                            "LESTE","CENTRO","OESTE","TRIÂNGULO DO NORTE",
                            "TRIÂNGULO DO SUL", "LESTE DO SUL","CENTRO SUL","SUL","SUDESTE"),
                   est1 = c("SBMK","SBMK","SBMK","SBMK","SBLS","SBLS","SBLS",
                            "SBUL","SBUR","SBBQ","SBBQ","SBKP","SBBQ"),
                   est2 = c("SBLP","SBBR","SBBR","SBLS","SBCF","SBPR","SBCF",
                            "SBUR","SBUL","SBCF","SBCF","SBTA","SBCF"))
cide <- cid %>% 
  left_join(ests, by = c("nome_macroreg" = "nome")) %>%
  select(municipio_geocodigo, primary_station = est1, secondary_station = est2)
setWUstation(cide, UF = "Minas Gerais",senha = "")


# Verificando (so funciona para uma cidade por vez)
getWUstation(cities = geocodigo)



#### 4. Inserção dos parametros na tabela parameters 
## ------------------------------------------------------
#Os limiares epidemicos (MEM) são obtidos no script config/calc-mem.R no terminal em bash pois pode demorar
load("AlertaDengueAnalise/config/thresMG.RData") 
d <- thresMG; rm(thresMG)
names(d)
# tem tres tipos:
  # percentile simples
  # minimo fixo
  # threshold mem
# IMPORTANTE!!!! o alerta usa incidencia, e nao casos 
cid10 <- "A90"
N <- length(d$thresholds$municipio_geocodigo)
which(d$thresholds$municipio_geocodigo==3112208)
for (i in 1:N){
  params = data.frame(municipio_geocodigo = d$thresholds$municipio_geocodigo[i], cid10 = cid10,
                      limiar_preseason = d$thresholds$limiar_preseason[i], 
                      limiar_posseason = d$thresholds$limiar_posseason[i], 
                      limiar_epidemico =d$thresholds$limiar_epidemico[i])
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params = params, 
                          overwrite = TRUE, senha)
}
                    
# para um local so

params = data.frame(municipio_geocodigo = 4314902, cid10 = cid10,
                    limiar_preseason = 0.369, 
                    limiar_posseason = 0.338, 
                    limiar_epidemico =1.87)
res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params = params, 
                        overwrite = TRUE, senha)


# para verificar
sqlquery = "SELECT * FROM \"Dengue_global\".\"parameters\" WHERE municipio_geocodigo 
> 3100000 AND municipio_geocodigo < 3200000"
dr <- dbGetQuery(con, sqlquery)
summary(dr)

# apareceram duas cidades inexistentes no banco de dados, 3117835 e 3152139. foram removidas usando sql
#dr %>%
#  filter(is.na(limiar_preseason))

sqlquery = "SELECT * FROM \"Dengue_global\".\"parameters\" WHERE municipio_geocodigo 
= 4314902"
dr <- dbGetQuery(con, sqlquery)
dr

### 5. Inserção dos limiares de temperatura e umidade

# para isso, fazer a analise usando o script ModelagemCasosClima.Rmd
# para varios (MG)
pars1 <- data.frame(nome = c("NORTE", "NORDESTE", "NOROESTE","JEQUITINHONHA","OESTE","TRIÂNGULO DO NORTE",
                            "TRIÂNGULO DO SUL"),
                            varcli = rep("temp_min", 7),
                            varcli2 = rep("umid_max", 7),
                            clicrit = c(18, 18, 18, 18, 18, 18, 18),
                            clicrit2 = c(72, 72, 72, 72, 75, 75, 75),
                    codmodelo = rep("AsAw",7))

cidee <- cid %>%
  filter(nome_macroreg %in% pars1$nome) %>%
  left_join(pars1, by = c("nome_macroreg" = "nome"))

  
for (i in 1:nrow(cidee)){
  params = data.frame(municipio_geocodigo = cidee$municipio_geocodigo[i], cid10 = cid10,
                      varcli = cidee$varcli[i],
                      varcli2 = cidee$varcli2[i],
                      clicrit = cidee$clicrit[i],
                      clicrit2 = cidee$clicrit2[i],
                      codmodelo = cidee$codmodelo[i])
  
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                          overwrite = TRUE, senha)
}

pars2 <- data.frame(nome = c("LESTE","CENTRO","LESTE DO SUL","CENTRO SUL","SUL","SUDESTE"),
                   varcli = rep("temp_min", 6),
                   clicrit = rep(15.5, 6),
                   codmodelo = c(rep("Af",6)))

cidee <- cid %>%
  filter(nome_macroreg %in% pars2$nome) %>%
  left_join(pars2, by = c("nome_macroreg" = "nome"))

for (i in 1:nrow(cidee)){
  params = data.frame(municipio_geocodigo = cidee$municipio_geocodigo[i], cid10 = cid10,
                      varcli = as.character(cidee$varcli[i]),
                      clicrit = cidee$clicrit[i],
                      codmodelo = cidee$codmodelo[i])
  
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                          overwrite = TRUE, senha)
}


# para um municipio só, a mao (POA)
params$varcli = "temp_min"
params$clicrit = 17
params$codmodelo = "Af"
res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                        overwrite = TRUE, senha)

### 5. Atraso de notificacao (metodo da Claudia)
library("survival")
res1<-fitDelayModel(cities=geocodigo, datasource=con, cid10 = "A90") # dengue
res1<-fitDelayModel(cities=geocodigo, datasource=con, cid10 = "A92.0") # chik
res1<-fitDelayModel(cities=geocodigo, datasource=con, cid10 = "A92.8") # zika

res<-fitDelayModel(cities=geocodigo, period=c("2016-01-01","2018-01-01"), datasource=con, cid10 = "A920")

#Os parametros a serem anotados no config são:
list(meanlog=res1$icoef[1], sdlog=exp(res1$icoef[2]))

### Para calcular o atraso por regional (ainda tem que entrar a mao no config)

res.delay <- data.frame(regionais = getRegionais(uf = "Ceará"), casos = 0, param1 = NA, param2 = NA)
for (i in 1:nrow(res.delay)){
  geocodigos = tabuf$municipio_geocodigo[tabuf$nome_regional==res.delay$regionais[i]]
  res<-fitDelayModel(cities=geocodigos, period=c("2013-01-01","2016-01-01"), datasource=con)
  if (!is.null(res)) res.delay[i,3:4] = list(meanlog=res$icoef[1], sdlog=exp(res$icoef[2]))
  
  res.delay$casos[i] <- sum(getCases(city=geocodigos[1], datasource = con)$casos)
  if (length(geocodigos)>1) for (cid in 2:length(geocodigos)) res.delay$casos[i] <- res.delay$casos[i] +
    sum(getCases(city=geocodigos[cid], datasource = con)$casos)
}

res.delay


### Para criar estrutura de diretorios (pode ser o estado, a regional ou o municipio)
source("AlertaDengueAnalise/config/fun_initializeSites.R")
# USO: setTree.newsite(siglaestado="CE",regional="Nova Regional")
setTree.newsite(siglaestado="SP", municipio = "Bauru")

# Proximo passo: criar o main


###  Uma olhadinha nos casos
# --------------------------------
geocodigo = cid$municipio_geocodigo[cid$nome=="Belo Horizonte"]
# dengue
casos = getCases(cities=geocodigo, datasource = con)
par(mar=c(5,5,2,2))
plot(casos$casos, type="l")
summary(casos$casos)

# chik
casosC = getCases(cities=geocodigo, cid10 = "A92.0", datasource = con)
plot(casosC$casos, type="l")

# zika
casosZ = getCases(cities=geocodigo, cid10 = "A92.8", datasource = con)
plot(casosZ$casos, type="l")
