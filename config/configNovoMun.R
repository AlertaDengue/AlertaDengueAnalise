# tabela com dados de todo o brasil do IBGE
tab <- read.csv("../tabela-regionaisIBGE.csv")


### 1. Qual é o estado?
tabuf <- subset(tab, Nome_UF=="São Paulo")
unique(tabuf$Nome_Microrregião)
unique(tabuf$Nome_Mesorregião)

### 2. O que temos desse estado no banco de dados?
library("AlertTools")
con <- DenguedbConnect()

reg=getRegionais(uf = "Ceará")
reg

cid = getCidades(uf = "Ceará", datasource=con)
dim(cid)

### 3. Seu municipio não está? Coloque-o, usando informacao do IBGE (se adequado)
nomedacidade = "Pinheiros"
geocodigo = 320410# 320360  #tabuf$Código.Município.Completo[tabuf$Nome_Município==nomedacidade]
id = 20# tabuf$Mesorregião.Geográfica[tabuf$Nome_Município==nomedacidade]
nomereg = "Pouso Alegre" #tabuf$Nome_Mesorregião[tabuf$Nome_Município==nomedacidade]

insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg, senha = "aldengue")


### 4. Quer colocar o estado todo de uma vez? Nao se preocupe, quem tiver já no banco nao sera mexido
## REQUER SENHA

tabuf <- read.csv("../Regionais_Saude_CE.csv") # qdo é custmizada a regional de saude
names(tabuf)
tabuf <- tabuf[,c(10,11,9)]
names(tabuf)[1:3]<-c("nome_municipio","nome_regional","municipio_geocodigo")
head(tabuf)
unique(tabuf$nome_regional)
n = dim(tabuf)[1]
for (i in 2:n){
  nomedacidade = tabuf$nome_municipio[i]
  geocodigo = tabuf$municipio_geocodigo[tabuf$nome_municipio==nomedacidade]
  id = 0 #id=tabuf$id_regional[tabuf$nome_municipio==nomedacidade]
  nomereg = tabuf$nome_regional[tabuf$nome_municipio==nomedacidade]
  insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg, senha="aldengue")
  
}

reg=getRegionais(uf = "Ceará")
reg




### Inserção das estacoes meteorologicas na tabela das regionais - requer SENHA
# ----------------------------------------------------------------
#https://estacoes.dengue.mat.br/

# Usar a tabela gerada pelo estacoes.dengue. Se os dados forem ruins, tem a opcao de colocar manualmente:

CE.Reg.estacoes <- list(SBTE=c("Tauá","Crato","Canindé","Cratéus","Quixadá"),
                 SBFZ=c("Sobral ","Tianguá","Caucaia","Maracanaú","Itapipoca",
                 "Limoeiro do Norte","Acaraú","Baturité","Fortaleza","Aracati","Russas","Cascavel","Camocim"),
                 SBPL =c("Juazeiro do Norte","Icó","Iguatu","Brejo Santo"))

escrevewu <- function(csvfile=NULL,lista=NULL, UF){
  if(!is.null(csvfile)){
    wus <- read.csv(csvfile,header = F)
    wusES <- wus[,c(2,4,6)]
    names(wusES) <- c("geocodigo", "estacao", "dist")  
    newdat <- data.frame(municipio_geocodigo=unique(wusES$geocodigo), codigo_estacao_wu=NA,
                         estacao_wu_sec=NA)
    for(cid in newdat$municipio_geocodigo) {
      estacoes <- wusES[wusES$geocodigo==cid,]
      estacoes <- estacoes[order(estacoes$dist),] # ordm decresc distancia
      newdat$codigo_estacao_wu[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[1])
      newdat$estacao_wu_sec[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[2])
    }
  }
  if(!is.null(lista)){
    cidades <- getCidades(uf = "Ceará", datasource = con)
    cidades$estacao <- NULL
    for (e in 1:length(lista))cidades$estacao[cidades$nome_regional%in%lista[[e]]] <- names(lista)[e]
    newdat <- data.frame(municipio_geocodigo=cidades$municipio_geocodigo, codigo_estacao_wu=cidades$estacao,
                         estacao_wu_sec=cidades$estacao)
  }
    
  newpars = c("codigo_estacao_wu","estacao_wu_sec")
  res = write.parameters(newpars,newdat,senha="aldengue")
  newdat
}

#escrevewu(csvfile="../CE-estacoes-mais-proximas.csv")
escrevewu(lista=CE.Reg.estacoes)



### 5. Uma olhadinha nos casos
# --------------------------------
nome = "Guaramiranga"
geocodigo = tabuf$municipio_geocodigo[tabuf$nome_municipio==nome]
casos = getCases(city=geocodigo, datasource = con)
par(mar=c(5,5,2,2))
plot(casos$casos, type="l")
summary(casos$casos)


#### 6. Inserção dos limiares epidemicos na tabela
## ------------------------------------------------------
#thresholds.table <- info.dengue.apply.mem(mun_list=cid$municipio_geocodigo[1],con = con)
load("mem-ceara.RData") # rodei direto a funcao do marcelo na pasta mem-marcelo (provisorio)
newpars = c("limiar_preseason","limiar_posseason","limiar_epidemico")
res = write.parameters(newpars,thresholds.table,senha="aldengue")

sqlquery = "SELECT * FROM \"Dengue_global\".\"regional_saude\" WHERE municipio_geocodigo < 2400000"
d <- dbGetQuery(con, sqlquery)
head(d)
tapply(d$limiar_preseason,d$nome_regional,median) # para atribuir uma media as regionais no par (provisorio)


### 5. Atraso de notificacao (metodo da Claudia)
library("survival")
res1<-fitDelayModel(cities=geocodigo, datasource=con)
res<-fitDelayModel(cities=geocodigo, period=c("2013-01-01","2016-01-01"), datasource=con)

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
source(fun_initializeSites.R)
# USO: setTree.newsite(siglaestado="CE",regional="Nova Regional")
setTree.newsite(siglaestado="CE")



### Para calcular o mem (por enquanto, preparar um dataframe e mandar pro Marcelo)
# a partir do objeto aleCE gerado pelo main.
n <- length(aleCE)

ceara <- aleCE[[1]]$data[,c("SE","cidade", "nome" ,"casos")]
for (i in 2:n) ceara <- rbind(ceara, aleCE[[i]]$data[,c("SE","cidade", "nome" ,"casos")])

save(ceara, file="ceara.RData")
