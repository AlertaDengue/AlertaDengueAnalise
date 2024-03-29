library("AlertTools"); library(assertthat) ; library(tidyverse)
library(RPostgreSQL)


UF = "Acre"
# USAR esse se do servidor:
#con <- DenguedbConnect(pass = pw)

# OU esse remoto
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

### 1. O que temos desse estado no banco de dados?
(getRegionais(uf = UF))
(getRegionais(uf = UF, macroreg = TRUE))
cid = getCidades(uf = "Acre")
nrow(cid)
head(cid)


#save(cid, file = "cid.RData")
# Se todas as cidades estao presentes, siga para (3)

### 2. Inserção das estacoes meteorologicas na tabela das regionais - requer SENHA
# ----------------------------------------------------------------
#https://estacoes.dengue.mat.br/

# Usar a tabela gerada pelo estacoes.dengue. Se os dados forem ruins, a opcao é selecionar
# as estacoes na mao. Script:# Vamos agora verificar a qualidade das estacoes usando script 
#tutoriais/relatorio-qualidade-dados

csvfile <- "estacoes/estacoes_sc.csv"
est <- read.csv2(csvfile)
head(est)
table(est$Município)

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
dados <- data.frame(municipio_geocodigo = 1200401, 
                    primary_station = "SBRB", secondary_station = "SBTK")
setWUstation(dados, UF = "Acre")

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

# a partir da tabela do Vinicius
csvfile <- "estacoes/estacoes_pr.csv"
est <- read.csv2(csvfile)
muns <- unique(est$Código)
for (m in muns){
  estacoes <- est$ICAO[est$Código == m]
  if (length(estacoes) == 2) dados <- data.frame(municipio_geocodigo = m,
                                                 primary_station = estacoes[1], 
                                                 secondary_station = estacoes[2])
  
  if (length(estacoes) == 1) dados <- data.frame(municipio_geocodigo = m, 
                                                 primary_station = estacoes[1], 
                                                 secondary_station = estacoes[1])
  
  setWUstation(dados, UF = UF)
}

# Verificando 
wus <- getWUstation(cities = 1200401)
table(wus$codigo_estacao_wu)


#### 4. Inserção dos parametros na tabela parameters 
## ------------------------------------------------------
#Os limiares epidemicos (MEM) são obtidos no script config/calc-mem.R no terminal em bash pois pode demorar
load("AlertaDengueAnalise/config/thresSC.RData") 
d <- thres
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

params = data.frame(municipio_geocodigo = 1200401, cid10 = "A90",
                    limiar_preseason = 12.6, 
                    limiar_posseason = 11.5, 
                    limiar_epidemico = 71.54)
res <- write_parameters(city = params$municipio_geocodigo, cid10 = "A90", params = params, 
                        overwrite = TRUE)

read.parameters(1200401)
# para verificar
sqlquery = "SELECT * FROM \"Dengue_global\".\"parameters\" WHERE municipio_geocodigo 
 = 2110005"
dr <- dbGetQuery(con, sqlquery)
summary(dr)

### 5. Inserção dos limiares de temperatura e umidade

mregs <- getRegionais(uf = UF, macroreg = TRUE)

pars1 <- data.frame(nome_macroregional = mregs,
                    varcli = "temp_min",
                    codmodelo = rep("Af"),
                    clicrit = NA)
pars1$clicrit[pars1$nome_macroregional %in% c("Oeste Paranaense")] <- 19.8
pars1$clicrit[pars1$nome_macroregional %in% c("Norte Central Paranaense", "Noroeste Paranaense", 
                                         "Centro Oriental Paranaense","Sudoeste Paranaense",
                                         "Sudeste Paranaense", "Centro Sul Paranaense",
                                         "Norte Pioneiro Paranaense", "Centro Ocidental Paranaense")] <- 18.6  
pars1$clicrit[pars1$nome_macroregional %in% c("Metropolitana de Curitiba")] <- 24.8


cidee <- cid %>%
  left_join(pars1, by = c("nome_macroreg" = "nome_macroregional"))
cid10 = "A90"
summary(cidee)

for (i in 1:nrow(cidee)){
  params = data.frame(municipio_geocodigo = cidee$municipio_geocodigo[i], cid10 = cid10,
                      varcli = cidee$varcli[i],
                      clicrit = cidee$clicrit[i],
                      codmodelo = cidee$codmodelo[i])
  
  res <- write_parameters(city = params$municipio_geocodigo, cid10 = cid10, params, 
                          overwrite = TRUE, datasource = con)
}


# para um municipio só, a mao ()
read.parameters(3549805)

params = data.frame(municipio_geocodigo = 1200401, 
                    cid10 = "A90",
                    varcli = "temp_min",
                    clicrit = 22,
                    codmodelo = "Af")
res <- write_parameters(city = params$municipio_geocodigo, cid10 = "A90", params, 
                        overwrite = TRUE)

## Para copiar os valores para a tabela regionais_saude
 ## e' essa que é usada no site.
### update tabela regional_saude
# dados para fazer update
#d <- dbReadTable(con, c("Dengue_global","parameters"))
#head(d)
d <- read.parameters(cid$municipio_geocodigo)

for(i in 2:nrow(d)){
  m <- d$municipio_geocodigo[i]
  lpre <- d$limiar_preseason[i]
  lpos <- d$limiar_posseason[i]
  lepi <- d$limiar_epidemico[i]
  #cli <- d$varcli[i]  # precisa colocar '  '
  
  #update_cli = paste0("UPDATE \"Dengue_global\".regional_saude 
  #                 SET varcli = '", cli, "' 
  #                   WHERE municipio_geocodigo = ", m)
  
  #if(cli == "temp_min") update_clicrit = paste0("UPDATE \"Dengue_global\".regional_saude 
  #                   SET tcrit = ", d$clicrit[i], " WHERE municipio_geocodigo = ", m)
#  
  #if(cli == "umid_max") update_clicrit = paste0("UPDATE \"Dengue_global\".regional_saude 
  #                   SET ucrit = ", d$clicrit[i], " WHERE municipio_geocodigo = ", m)
  
  update_limiar = paste0("UPDATE \"Dengue_global\".regional_saude 
                   SET limiar_preseason = ", lpre, ", limiar_posseason = ",lpos," ,
                    limiar_epidemico = ",lepi, " WHERE municipio_geocodigo = ", m)
  
  try(dbGetQuery(con, update_limiar))
}




### Para criar estrutura de diretorios (pode ser o estado, a regional ou o municipio)
source("config/fun_initializeSites.R")
# USO: setTree.newsite(siglaestado="CE",regional="Nova Regional")
# USO: setTree.newsite(siglaestado="SP", municipio = "Bauru")
setTree.newsite(siglaestado="MA")

# Proximo passo: criar o main


###  Uma olhadinha nos casos
# --------------------------------
geocodigo = cid$municipio_geocodigo[cid$nome=="Florianópolis"]
# dengue
casos = getCases(cities=geocodigo, dataini = "sinpri", datasource = con)
par(mar=c(5,5,2,2))
plot(casos$casos, type="l")
summary(casos$casos)

# chik
casosC = getCases(cities=geocodigo, cid10 = "A92.0", datasource = con)
plot(casosC$casos, type="l")

# zika
casosZ = getCases(cities=geocodigo, cid10 = "A92.8", datasource = con)
plot(casosZ$casos, type="l")
