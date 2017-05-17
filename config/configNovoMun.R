# tabela com dados de todo o brasil do IBGE
tab <- read.csv("../tabela-regionaisIBGE.csv")


### 1. Qual é o estado?
tabuf <- subset(tab, Nome_UF=="Minas Gerais")
unique(tabuf$Nome_Microrregião)
unique(tabuf$Nome_Mesorregião)

### 2. O que temos desse estado no banco de dados?
library("AlertTools")
con <- DenguedbConnect()

reg=getRegionais(uf = "Minas Gerais")
reg

cid = getCidades(regional = "Sete Lagoas", uf = "Minas Gerais", datasource=con)
dim(cid)

### 3. Seu municipio não está? Coloque-o, usando informacao do IBGE (se adequado)
nomedacidade = "Pinheiros"
geocodigo = 320410# 320360  #tabuf$Código.Município.Completo[tabuf$Nome_Município==nomedacidade]
id = 20# tabuf$Mesorregião.Geográfica[tabuf$Nome_Município==nomedacidade]
nomereg = "Pouso Alegre" #tabuf$Nome_Mesorregião[tabuf$Nome_Município==nomedacidade]

insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg, senha = "aldengue")


### 4. Quer colocar o estado todo de uma vez? Nao se preocupe, quem tiver já no banco nao sera mexido
## REQUER SENHA
tabuf <- read.csv("../Regionais_Saude_ES.csv")
names(tabuf)[1:3]<-c("nome_municipio","nome_regional","municipio_geocodigo")
head(tabuf)
n = dim(tabuf)[1]
for (i in 2:n){
  nomedacidade = tabuf$nome_municipio[i]
  geocodigo = tabuf$municipio_geocodigo[tabuf$nome_municipio==nomedacidade]
  id = 0 #id=tabuf$id_regional[tabuf$nome_municipio==nomedacidade]
  nomereg = tabuf$nome_regional[tabuf$nome_municipio==nomedacidade]
  insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg, senha="aldengue")

}

#for (i in 11:dim(tabuf)[1]){
#  nomedacidade = tabuf$Nome_Município[i]
#  geocodigo = tabuf$Código.Município.Completo[tabuf$Nome_Município==nomedacidade]
#  id = tabuf$Mesorregião.Geográfica[tabuf$Nome_Município==nomedacidade]
#  nomereg = tabuf$Nome_Mesorregião[tabuf$Nome_Município==nomedacidade]
#  insertCityinAlerta(city=geocodigo, id_regional=id, regional = nomereg)
  
#}

reg=getRegionais(uf = "Espírito Santo")
reg

### Inserção das estacoes meteorologicas na tabela das regionais - requer SENHA
# ----------------------------------------------------------------
escrevewu <- function(csvfile){
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
  newpars = c("codigo_estacao_wu","estacao_wu_sec")
  res = write.parameters(newpars,newdat,senha="aldengue")
  newdat
}

escrevewu("estações-mais-proximas-MG.csv")

getCidades(regional="Sete Lagoas",uf="Minas Gerais")

### 5. Uma olhadinha nos casos
# --------------------------------
nome = "Sete Lagoas"
geocodigo = tabuf$Código.Município.Completo[tabuf$Nome_Município==nome]
casos = getCases(city=geocodigo, datasource = con)
par(mar=c(5,5,2,2))
plot(casos$casos, type="l")
summary(casos$casos)


### 5. Atraso de notificacao (metodo da Claudia)
library("survival")
res1<-fitDelayModel(cities=geocodigo, datasource=con)
res<-fitDelayModel(cities=geocodigo, period=c("2013-01-01","2016-01-01"), datasource=con)

#Os parametros a serem anotados no config são:
list(meanlog=res1$icoef[1], sdlog=exp(res1$icoef[2]))



