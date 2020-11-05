library("AlertTools"); library(assertthat) ; library(tidyverse)

### 1. O que temos desse estado no banco de dados?
UF = "São Paulo"
con <- DenguedbConnect(pass = pw)
(getRegionais(uf = UF))
(getRegionais(uf = UF, macroreg = TRUE))
cid = getCidades(uf = UF, datasource=con)
nrow(cid)
head(cid)

#save(cid, file = "cid.RData")
# Se todas as cidades estao presentes, siga para (3)

### 2. Seu municipio(s) não está? Coloque-o, usando informacao do IBGE (se adequado)
nomedacidade = "Sorocaba"
geocodigo =  3552205 #tabuf$Código.Município.Completo[tabuf$Nome_Município==nomedacidade]
id =  16# tabuf$Mesorregião.Geográfica[tabuf$Nome_Município==nomedacidade]
nomereg = "Sorocaba" #tabuf$Nome_Mesorregião[tabuf$Nome_Município==nomedacidade]
macroreg = "Sorocaba"
insert_city_infodengue(geocodigo=geocodigo, regional = nomereg, id_regional=id, macroreg = macroreg)

### 2a. Quer colocar o estado todo de uma vez? Nao se preocupe, quem tiver já no banco nao sera mexido
## (adaptar para incluir macroregiao)

tabuf <- read.csv("REGIONAIS_MA.csv", as.is = TRUE) # qdo é custmizada a regional de saude
head(tabuf)

for (i in 1:nrow(tabuf)){
  insert_city_infodengue(geocodigo = sevendigitgeocode(tabuf$codmun[i]), 
                         id_regional = tabuf$numreg[i], 
                         regional = tabuf$regional[i], 
                         macroreg = tabuf$macroregional[i],
                         datasource = con)
}

#macroreg=getRegionais(uf = "Minas Gerais", macroreg = TRUE)
reg=getRegionais(uf = UF)


### 3. Inserção das estacoes meteorologicas na tabela das regionais - requer SENHA
# ----------------------------------------------------------------
#https://estacoes.dengue.mat.br/

# Usar a tabela gerada pelo estacoes.dengue. Se os dados forem ruins, a opcao é selecionar
# as estacoes na mao. Script:# Vamos agora verificar a qualidade das estacoes usando script 
#tutoriais/relatorio-qualidade-dados

csvfile <- "estacoes/estações-mais-proximasMAmod.csv"

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

escrevewu(csvfile="estacoes/estações-mais-proximasMAmod.csv", UF = "Maranhão",senha = "aldengue")
#escrevewu(lista=CE.Reg.estacoes)

# PS. Na mão: usar setWUstation()
# uma:
dados <- data.frame(municipio_geocodigo = geocodigo, 
                    primary_station = "SBAU", secondary_station = "SBAU")
setWUstation(dados, senha ="",UF = "São Paulo")

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


# Verificando 
getWUstation(cities = newdat$municipio_geocodigo[1:100])



#### 4. Inserção dos parametros na tabela parameters 
## ------------------------------------------------------
#Os limiares epidemicos (MEM) são obtidos no script config/calc-mem.R no terminal em bash pois pode demorar
load("AlertaDengueAnalise/config/thresMA.RData") 
d <- thresMA; rm(thresMA)
names(d)
# tem tres tipos:
  # percentile simples
  # minimo fixo
  # threshold mem
# IMPORTANTE!!!! o alerta usa incidencia, e nao casos 
cid10 <- "A90"
N <- length(d$thresholds$municipio_geocodigo)
#which(d$thresholds$municipio_geocodigo==3112208)
for (i in 1:N){
  params = data.frame(municipio_geocodigo = d$thresholds$municipio_geocodigo[i], cid10 = cid10,
                      limiar_preseason = d$thresholds$limiar_preseason[i], 
                      limiar_posseason = d$thresholds$limiar_posseason[i], 
                      limiar_epidemico =d$thresholds$limiar_epidemico[i])
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params = params, 
                          overwrite = TRUE, senha)
}
                    
# para um local so

params = data.frame(municipio_geocodigo = 3506003, cid10 = cid10,
                    limiar_preseason = 4.44, 
                    limiar_posseason = 3.94, 
                    limiar_epidemico = 57.6)
res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params = params, 
                        overwrite = TRUE, senha = "aldengue")

read.parameters(3506003)
# para verificar
sqlquery = "SELECT * FROM \"Dengue_global\".\"parameters\" WHERE municipio_geocodigo 
 = 2110005"
dr <- dbGetQuery(con, sqlquery)
summary(dr)

### 5. Inserção dos limiares de temperatura e umidade

#
pars1 <- data.frame(nome = c("Norte","Leste","Sul"),
                            varcli = rep("umid_max", 3),
                            clicrit = c(78,88.5, 94.9),
                    codmodelo = rep("Aw",3))


cidee <- cid %>%
  left_join(pars1, by = c("nome_macroreg" = "nome"))

# apenas Balsas tem um padrao diferente
cidee$clicrit[cidee$nome_regional == "Balsas"] <- 89  

  
for (i in 1:nrow(cidee)){
  params = data.frame(municipio_geocodigo = cidee$municipio_geocodigo[i], cid10 = cid10,
                      varcli = cidee$varcli[i],
                      clicrit = cidee$clicrit[i],
                      codmodelo = cidee$codmodelo[i])
  
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                          overwrite = TRUE, senha)
}


# para um municipio só, a mao ()
read.parameters(3549805)

params = data.frame(municipio_geocodigo = 3549805, 
                    cid10 = cid10,
                    varcli = "temp_min",
                    clicrit = 20,
                    codmodelo = "Af")
res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                        overwrite = TRUE, senha)


### Para criar estrutura de diretorios (pode ser o estado, a regional ou o municipio)
source("config/fun_initializeSites.R")
# USO: setTree.newsite(siglaestado="CE",regional="Nova Regional")
# USO: setTree.newsite(siglaestado="SP", municipio = "Bauru")
setTree.newsite(siglaestado="MA")

# Proximo passo: criar o main


###  Uma olhadinha nos casos
# --------------------------------
geocodigo = cid$municipio_geocodigo[cid$nome=="São Luís"]
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
