
## Graficos e Mapas para relatorios ########

# ------------ figuramunicipio ------------------------------------
## figuramunicipio: codigo da figura com 3 subfiguras que e usada para os municipios
# obj é o alerta do municipio gerado pelo update.alerta
# USO: figuramunicipio(alePR_RS_Cascavel[["CéuAzul"]])

figuramunicipio <- function(obj, varcli = "temp_min", cid="A90", tsdur=104){
  
  if(cid == "A90") titulo = "Casos de Dengue"
  if(cid == "A92.0") titulo = "Casos de Chikungunya"
  if(cid == "A92.8") titulo = "Casos de Zika"
  
  geoc <- obj$data$cidade[1]
  print(geoc)
  param <- read.parameters(geoc, cid10 = cid)
  
  layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(13), 
         heights = c(rep(lcm(4),2), lcm(5)))
  
  n = dim(obj$data)[1]
  objc = obj$data[(n-tsdur):n,]
  objc = obj$data
  #objc <- obj$data[obj$data$SE>=201301,] 
  # Subfigura do topo (serie temporal de casos e tweets)
  par(mai=c(0,0,0,0),mar=c(1,4,0,3))
  plot(objc$casos, type="l", xlab="", ylab="", axes=FALSE)
  axis(1, pos=0, lty=0, lab=FALSE)
  axis(2)
  mtext(text=titulo, line=2.5,side=2, cex = 0.7)
  maxy <- max(objc$casos, na.rm=TRUE)
  if(cid == "A92.0")legend(25, maxy, c("casos de chikungunya"),col=c(1), lty=1, bty="n",cex=0.7)
  if(cid == "A92.8")legend(25, maxy, c("casos de zika"),col=c(1), lty=1, bty="n",cex=0.7)
  # colocar tweet, so dengue
  if(cid == "A90") {
    legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
    par(new=T)
    if(sum(is.na(objc$tweet))==nrow(objc)) objc$tweet = 0 # 
    plot(objc$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
    lines(objc$tweet, col=3, type="h") #*coefs[2] + coefs[1]
    axis(1, pos=0, lty=0, lab=FALSE)
    axis(4)
    mtext(text="Tweets", line=2.5, side=4, cex = 0.7)
  }
  # subfigura do meio: clima
  par(mai=c(0,0,0,0),mar=c(1,4,0,3))
  if(varcli == "temp_min") {
    plot(objc$temp_min, type="l", xlab="", ylab ="Temperatura min",axes=FALSE)
    abline(h=param$clicrit, lty=2)
  }
  if(varcli == "umid_min") {
    plot(objc$umid_min, type="l", xlab="", ylab ="Umidade min",axes=FALSE)
    abline(h=param$clicrit, lty=2)
  }
  if(varcli == "umid_max") {
    plot(objc$umid_max, type="l", xlab="", ylab ="Umidade max",axes=FALSE)
    abline(h=param$clicrit, lty=2)
  }
  
  legend(x="topleft",lty=c(2),col=c("black"),
         legend=c("limiar favorável transmissão"),cex=0.85,bty="n")
  axis(2)
  
  
  # subfigura de baixo: alerta colorido
  par(mai=c(0,0,0,0),mar=c(1,4,0,4))
  plot_alerta(obj, geocodigo = geoc, var="casos") #"inc",ini=min(objc$SE),fim=max(objc$SE))
  abline(h=param$limiar_epidemico*obj$data$pop[1]/1e5,lty=2, col ="red")
  abline(h=param$limiar_preseason*obj$data$pop[1]/1e5,lty=2, col ="darkgreen")
  abline(h=param$limiar_posseason*obj$data$pop[1]/1e5,lty=2, col ="black")
  legend(x="topright",lty=c(3,2,2),col=c("red","darkgreen","black"),
         legend=c("limiar epidêmico","limiar pré-epidêmico","limiar pós-epidêmico"),cex=0.85,bty="n")
  
}



# --------- mapa.regional --------------------------------------
mapa.regional <- function(alerta, regionais, estado, varcli = "temp_min", sigla, shape, 
                          shapeid, data, dir="",
                          datasource){
  for (i in regionais) {
    cidades = getCidades(regional = i, uf = estado)
    titu = paste(sigla,":",i,"\n")
    nomesemespaco = gsub(" ","",i)
    nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
    fname = paste(dir,"Mapa",sigla,"_",nomesemacento,".png",sep="")
    
    geraMapa(alerta=alerta, subset=cidades$municipio_geocodigo, se=data, legpos = "bottomright",#pars[[i]]$legpos,  
             shapefile=shape, varid=shapeid, 
             titulo=titu ,filename=fname, dir="")
  }
  message("mapa criado:", fname)
  fname
}



# figuraRio -----------------------

figuraRio <- function(cid, varcli = "temp_min"){
  par(mfrow=c(3,1),mar=c(4,4,1,1))
  ymax <- max(110,max(cid$inc, na.rm = TRUE))
  plot(1:dim(cid)[1],cid$tweet,type="h",ylab="",axes=FALSE,xlab="",main="Tweets sobre dengue")
  axis(2)
  plot(1:dim(cid)[1],cid$inc, type="l", xlab="",ylab="incidência (por 100.000)",axes=FALSE,main="Dengue",ylim=c(0,ymax))
  abline(h=14, lty=2, col="blue")
  abline(h=100, lty=2, col="red")
  text(mean(1:dim(cid)[1]),14,"limiar pré epidêmico",col="blue",cex=0.8)
  text(mean(1:dim(cid)[1]),100,"limiar alta atividade",col="red",cex=0.8)
  axis(2)
  
  plot(1:dim(cid)[1],cid$tmin,type="l",ylab="temperatura",axes=FALSE,xlab="",main="Temperatura mínima")
  abline(h=22, lty=2, col=2)
  axis(2)
  le=dim(cid)[1]
  axis(1,at=rev(seq(le,1,by=-12)),labels=cid$se[rev(seq(le,1,by=-12))],las=2)
  text(mean(1:dim(cid)[1]),22,"temp crítica",col=2, cex=0.8)
}

# figuraRioChik

figuraRioChik <- function(cid, varcli = "temp_min"){
  par(mfrow=c(1,1),mar=c(4,4,1,1))
  #ymax <- max(110,max(cid$inc))
  plot(1:dim(cid)[1],cid$casos, type="l", xlab="",ylab="casos notificados",
       axes=FALSE,main="Chikungunia")
  abline(v=201701, lty=3, col="grey")
  axis(2)
  le=dim(cid)[1]
  axis(1,at=rev(seq(le,1,by=-4)),labels=cid$se[rev(seq(le,1,by=-4))],las=2)
}



# fazSomatorio casos nos municipios para calcular totais anuais por municipio, regional
# fazSomatorio -----------------------

tabSomatorio <- function(ale, ano, data, varcli = "temp_min", uf = uf, 
                         agregaregional=FALSE){
  # check data
  dataale <- max(ale[[1]]$data$SE)
  if(dataale < data) print("faztabelaoRS: ultima SE de ale é anterior à data do relatorio")
  data <- dataale
  
  tabSoma = data.frame(nome = names(ale), Municipio = NA, Regional = NA, 
                       totano = NA, totultse = NA,
                       nivel=NA,nivel1 = NA, stringsAsFactors = FALSE)
  N = length(names(ale))
  for (i in 1:N){
    ai <- ale[[i]] 
    reg <- getRegionais(cities = ai$data$cidade[1], uf = uf)
    
    linhasdoano = which(floor(ai$data$SE/100)==ano)
    linhase = which(ai$data$SE==data)
    linhase1 = which(ai$data$SE==data)-1
    
    tabSoma$Municipio[i]=unique(ai$data$nome)
    tabSoma$Regional[i]=reg
    tabSoma$totano[i] = sum(ai$data$casos[linhasdoano],na.rm=TRUE)
    tabSoma$totultse[i] = ai$data$casos[linhase]
    tabSoma$nivel[i] = ai$indices$level[linhase]
    tabSoma$nivel1[i] = ai$indices$level[linhase1]
    
   
  }
  
  if(agregaregional==TRUE){
    tabSomaRS = data.frame(Regional = tapply(tabSoma$Regional,tabSoma$Regional,unique))
    tabSomaRS$totano = tapply(tabSoma$totano,tabSoma$Regional, sum)
    tabSomaRS$totultse = tapply(tabSoma$totultse,tabSoma$Regional, sum)

    tabSomaRS$nverde = tapply(tabSoma$nivel==1,tabSoma$Regional, sum)
    tabSomaRS$namarelo = tapply(tabSoma$nivel==2,tabSoma$Regional, sum)
    tabSomaRS$nlaranja = tapply(tabSoma$nivel==3,tabSoma$Regional, sum)
    tabSomaRS$nvermelho = tapply(tabSoma$nivel==4,tabSoma$Regional, sum)

    tabSomaRS$nverde1 = tapply(tabSoma$nivel1==1,tabSoma$Regional, sum)
    tabSomaRS$namarelo1 = tapply(tabSoma$nivel1==2,tabSoma$Regional, sum)
    tabSomaRS$nlaranja1 = tapply(tabSoma$nivel1==3,tabSoma$Regional, sum)
    tabSomaRS$nvermelho1 = tapply(tabSoma$nivel1==4,tabSoma$Regional, sum)
  
    return(tabSomaRS)
  }
  return(tabSoma)
}

# faztabelaoRS2-------------------------------
# fazTabelao com dados da ultima semana das Regionais ou do estado

faztabelaoRS2 <- function(tab, data,uf, varcli = "temp_min", tex=F){
  
  reg <- data.frame(reg = getRegionais(cities = unique(restab$municipio_geocodigo), uf = uf),
                    municipio_geocodigo = unique(restab$municipio_geocodigo))
  
  # filtrar para o periodo de interesse
  ano <- floor(data/100)
  ano_pre <- ano - 1
  
  restab <- tab %>%
    filter((SE <= data) & (SE > ano_pre*100)) %>%
    left_join(reg)
  
  rm(reg)  
  
  res <- restab %>% 
    group_by(municipio_geocodigo) %>%
    summarize(
      totano = sum(casos[SE >ano*100]),
      n = length(casos),
      totultse = casos[(n-1)]
    )
  
  
  totano=0; totultse=0
  nverde=0; namarelo=0;nlaranja=0;nvermelho=0
  nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
  
  
  tabelao = data.frame(Municipio = character(),Regional = character(), 
                       Clima = numeric(), Tweets=numeric(),
                       Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                       Nivel=character(),stringsAsFactors = FALSE)
  
  
  
  for (i in 1:N){
    
    reg <- getRegionais(cities = ai$data$cidade[1], uf = uf)
    linhasdoano = which(floor(ai$data$SE/100)==ano)
    linhase = which(ai$data$SE==data)
    linhase1 = which(ai$data$SE==data)-1
    
    totano = sum(c(totano, ai$data$casos[linhasdoano]),na.rm=TRUE)
    totultse = sum(c(totultse, ai$data$casos[linhase]),na.rm=TRUE)
    
    nverde = sum(c(nverde,as.numeric(ai$indices$level[linhase]==1)),na.rm=TRUE)
    namarelo = sum(c(namarelo,as.numeric(ai$indices$level[linhase]==2)),na.rm=TRUE)
    nlaranja = sum(c(nlaranja,as.numeric(ai$indices$level[linhase]==3)),na.rm=TRUE)
    nvermelho = sum(c(nvermelho,as.numeric(ai$indices$level[linhase]==4)),na.rm=TRUE)
    
    nverde1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==1)),na.rm=TRUE)
    namarelo1 = sum(c(namarelo1,as.numeric(ai$indices$level[linhase1]==2)),na.rm=TRUE)
    nlaranja1 = sum(c(nlaranja1,as.numeric(ai$indices$level[linhase1]==3)),na.rm=TRUE)
    nvermelho1 = sum(c(nvermelho1,as.numeric(ai$indices$level[linhase1]==4)),na.rm=TRUE)
    
    cores=c("verde","amarelo","laranja","vermelho")
    if (varcli == "temp_min")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = reg,
                                Temperatura = ai$data$temp_min[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    
    if (varcli == "umid_min")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = reg,
                                Umid.min = ai$data$umid_min[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    
    if (varcli == "umid_max")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = reg,
                                Umid.max = ai$data$umid_max[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    
    tabelao[i,] = paratabelao
    
  }
  if(tex==T){
    tabelaox <-xtable(tabelao, align ="ll|lllllll")
    digits(tabelaox) <- c(0,0,0,1,0,0,1,1,0)
    return(tabelaox)
  }else{
    return(list(tabelao=tabelao,totano=totano,totultse=totultse,nverde=nverde,
                namarelo=namarelo,nlaranja=nlaranja,nvermelho=nvermelho,
                nverde1=nverde1,namarelo1=namarelo1,nlaranja1=nlaranja1
                ,nvermelho1=nvermelho1))
  }
}



# faztabelaoRS-------------------------------
# fazTabelao com dados da ultima semana das Regionais ou do estado

faztabelaoRS <- function(ale,ano,data,uf, varcli = "temp_min", tex=F){
  
  # check data
  dataale <- max(ale[[1]]$data$SE)
  if(dataale < data) print("faztabelaoRS: ultima SE de ale é anterior à data do relatorio")
  data <- dataale
  
  totano=0; totultse=0
  nverde=0; namarelo=0;nlaranja=0;nvermelho=0
  nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
  
  # ----- começo do tabelao
  if(varcli == "temp_min") tabelao = data.frame(Municipio = character(),Regional = character(), 
                       Temperatura = numeric(), Tweets=numeric(),
                       Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                       Nivel=character(),stringsAsFactors = FALSE)
  
  if(varcli == "umid_min") tabelao = data.frame(Municipio = character(),Regional = character(), 
                       Umidade = numeric(), Tweets=numeric(),
                       Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                       Nivel=character(),stringsAsFactors = FALSE)
  
  if(varcli == "umid_max") tabelao = data.frame(Municipio = character(),Regional = character(), 
                       Umidade = numeric(), Tweets=numeric(),
                       Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                       Nivel=character(),stringsAsFactors = FALSE)
  
  N = length(names(ale))
  for (i in 1:N){
    ai <- ale[[i]]
    reg <- getRegionais(cities = ai$data$cidade[1], uf = uf)
    linhasdoano = which(floor(ai$data$SE/100)==ano)
    linhase = which(ai$data$SE==data)
    linhase1 = which(ai$data$SE==data)-1
    
    totano = sum(c(totano, ai$data$casos[linhasdoano]),na.rm=TRUE)
    totultse = sum(c(totultse, ai$data$casos[linhase]),na.rm=TRUE)
    
    nverde = sum(c(nverde,as.numeric(ai$indices$level[linhase]==1)),na.rm=TRUE)
    namarelo = sum(c(namarelo,as.numeric(ai$indices$level[linhase]==2)),na.rm=TRUE)
    nlaranja = sum(c(nlaranja,as.numeric(ai$indices$level[linhase]==3)),na.rm=TRUE)
    nvermelho = sum(c(nvermelho,as.numeric(ai$indices$level[linhase]==4)),na.rm=TRUE)
    
    nverde1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==1)),na.rm=TRUE)
    namarelo1 = sum(c(namarelo1,as.numeric(ai$indices$level[linhase1]==2)),na.rm=TRUE)
    nlaranja1 = sum(c(nlaranja1,as.numeric(ai$indices$level[linhase1]==3)),na.rm=TRUE)
    nvermelho1 = sum(c(nvermelho1,as.numeric(ai$indices$level[linhase1]==4)),na.rm=TRUE)
    
    cores=c("verde","amarelo","laranja","vermelho")
    if (varcli == "temp_min")
    paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                              Regional = reg,
                              Temperatura = ai$data$temp_min[linhase],
                              Tweets = ai$data$tweet[linhase],
                              Casos = ai$data$casos[linhase], 
                              Incidencia=ai$data$inc[linhase],
                              Rt=ai$data$Rt[linhase],
                              Nivel=as.character(cores[ai$indices$level[linhase]]),
                              stringsAsFactors = FALSE)

    if (varcli == "umid_min")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = reg,
                                Umid.min = ai$data$umid_min[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)

    if (varcli == "umid_max")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = reg,
                                Umid.max = ai$data$umid_max[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    
    tabelao[i,] = paratabelao
    
  }
  if(tex==T){
    tabelaox <-xtable(tabelao, align ="ll|lllllll")
    digits(tabelaox) <- c(0,0,0,1,0,0,1,1,0)
    return(tabelaox)
  }else{
    return(list(tabelao=tabelao,totano=totano,totultse=totultse,nverde=nverde,
                namarelo=namarelo,nlaranja=nlaranja,nvermelho=nvermelho,
                nverde1=nverde1,namarelo1=namarelo1,nlaranja1=nlaranja1
                ,nvermelho1=nvermelho1))
    }
}

##faztabelaresumo------------------------
# faz tabela resumo dos municipios indicados 


faztabelaresumo <- function(alert,municipios, nmunicipios,varcli = "temp_min",tex=F){
  cidadessemespaco = gsub(" ","",municipios$nome)
  linhascidades <- which(as.numeric(names(alert)) %in% municipios$municipio_geocodigo)
  
  if (varcli=="temp_min")
  tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                  "tcasesICmin","tcasesmed","tcasesICmax")])
  
  if (varcli=="umid_min")
    tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","umid_min",
                                                    "tcasesICmin","tcasesmed","tcasesICmax")])
  
  if (varcli=="umid_max")
    tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","umid_max",
                                                    "tcasesICmin","tcasesmed","tcasesICmax")])
  
  tabelaregional <- data.frame(SE=tabela$SE)
  
  for (n in 2:nmunicipios){
    
    if (varcli=="temp_min")   newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                       "tcasesICmin","tcasesmed","tcasesICmax")])
    if (varcli=="umid_min")   newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","umid_min",
                                                         "tcasesICmin","tcasesmed","tcasesICmax")])
    if (varcli=="umid_max")  newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","umid_max",
                                                         "tcasesICmin","tcasesmed","tcasesICmax")])
    
    #tabela[,2:8] <- tabela[,2:8]+newtabela[,2:8]
    tabela = rbind(tabela,newtabela)
    
  }
  
  if (varcli=="temp_min") tabelaregional$tempmin <- tapply(tabela$temp_min, tabela$SE, mean, na.rm=TRUE)
  if (varcli=="umid_min") tabelaregional$umidmin <- tapply(tabela$umid_min, tabela$SE, mean, na.rm=TRUE)
  if (varcli=="umid_max") tabelaregional$umidmax <- tapply(tabela$umid_max, tabela$SE, mean, na.rm=TRUE)
  tabelaregional$casos <- tapply(tabela$casos, tabela$SE, sum,na.rm=T)
  tabelaregional$pop <-tapply(tabela$pop, tabela$SE, sum)
  tabelaregional$tweet <-tapply(tabela$tweet, tabela$SE, sum,na.rm=T)
  tabelaregional$tcasesICmin <-tapply(tabela$tcasesICmin, tabela$SE, sum)
  tabelaregional$tcasesmed <-tapply(tabela$tcasesmed, tabela$SE, sum)
  tabelaregional$tcasesICmax <-tapply(tabela$tcasesICmax, tabela$SE, sum)
  tabelaregional$inc <- tabelaregional$casos/tabelaregional$pop*100000
  
  #tabelafinal <- tail(tabelaregional[,c("SE","temp_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
  if (varcli=="temp_min") {
        tabelafinal <- tail(tabelaregional[,c("SE","tempmin","tweet","casos","tcasesmed")])
        names(tabelafinal)<-c("SE","temperatura","tweet","casos notif","casos preditos")
  }
  if (varcli=="umid_min"){
    tabelafinal <- tail(tabelaregional[,c("SE","umidmin","tweet","casos","tcasesmed")])
    names(tabelafinal)<-c("SE","umid.min","tweet","casos notif","casos preditos")
  }
  if (varcli=="umid_max"){
    tabelafinal <- tail(tabelaregional[,c("SE","umidmax","tweet","casos","tcasesmed")])
    names(tabelafinal)<-c("SE","umid.max","tweet","casos notif","casos preditos")
  }
  
  if(tex==TRUE){
    tabelax <-xtable(tabelafinal,align ="cc|cccc",digits = c(0,0,1,0,0,0),size="\\small")
    #digits(tabelax) <- 0
    return(tabelax)
  }else{return(tabelafinal)}
  
}

## fazfiguraregional ----------------------
## Figura regional


fazfiguraregional <- function(ale, municipreg, varcli = "temp_min",tsdur){
  
nmunreg = length(municipreg)
res = tabela_historico(ale[[municipreg[1]]])
for (n in 2:nmunreg) res = rbind(res, tabela_historico(ale[[municipreg[n]]]))

res$tweet[is.na(res$tweet)] <- 0 # colocando 0 onde não há tweets, so para o grafico
serie = aggregate(cbind(tweet,casos)~data_iniSE,data=res,FUN=sum,na.rm=TRUE)

layout(matrix(1), widths = lcm(10),heights = c(lcm(5)))
n = dim(serie)[1]
seriefinal = serie[(n-tsdur):n,]

par(mai=c(0,0,0,0),mar=c(3,0.5,0.5,0.5))
plot(seriefinal$casos, type="l", xlab="", ylab="", axes=FALSE,bty="o")
axis(1, pos=-2, las=2, at=seq(1,length(seriefinal$casos),by=8),
     tcl=-0.25,labels=FALSE) #pos=0 , labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=10)], at=seq(1,length(seriefinal$casos),by=12)
axis(1, pos=0, las=2, at=seq(1,length(seriefinal$casos),by=8), 
     labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=8)],
     cex.axis=0.6,lwd=0,tcl=-0.25) #pos=0 

axis(2,las=1,pos=-0.4,tck=-.05,lab=FALSE)
axis(2,las=1,pos=4,lwd=0,cex.axis=0.6)
mtext(text="casos de dengue", line=1,side=2, cex = 0.7) # line=3.5 (original)
maxy <- max(seriefinal$casos, na.rm=TRUE)
legend(25, maxy, c("casos","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
par(new=T)
plot(seriefinal$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
lines(seriefinal$tweet, col=3, type="h") #*coefs[2] + coefs[1]
axis(4,las=1,pos=106,tck=-.05,lab=FALSE)
axis(4,las=1,pos=103,lwd=0,cex.axis=0.6)
mtext(text="tweets", line=0.5, side=4, cex = 0.7)
}


# fazfiguraresumo.arbo
## Figura series temporais - arbo


fazfiguraresumo.arbo <- function(serieD, serieC, serieZ, tipo = "estadual", tsdur = 104){
  # serieD,C,Z sao series temporais geradas contendo "data_iniSE" , "casos", "casos_est",  "casos_est_min" "casos_est_max"
  # verde", "amarelo", "laranja", "vermelho","ano"    (codigo no ConfigRelatorioEstaudal.Arbo) 
  
  
  # Figura com tres sub-figuras, uma para cada agravo
  layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(13), 
         heights = c(rep(lcm(4),3)))
  
  #  dengue  
  
  n = dim(serieD)[1]
  seriefinalD = serieD[(n-tsdur):n,]
  require(lubridate)
  with(seriefinalD, {
    par(mai=c(0,0,0,0),mar=c(3,0.5,0.5,0.5))
    plot(casos, type="s", xlab="", ylab="", axes=FALSE,bty="n")
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est[((tsdur + 1) - 6):(tsdur + 1)], lty=1, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_min[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_max[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    
    # linhas verticais marcando o inicio de cada ano
    anos <- unique(ano)
    for (a in anos) abline(v = which(ano == a)[1], lty=3)
    axis(1, pos=-2, las=2, at=seq(1,(tsdur+1),by=8),
       tcl=-0.25,labels=FALSE) #pos=0 ,
    axis(1, pos=0, las=2, at=seq(1,(tsdur+1),by=8), 
       labels=data_iniSE[seq(1,length(casos),by=8)],
       cex.axis=0.6,lwd=0,tcl=-0.25) #pos=0 
  
     axis(2,las=1,pos=-0.4,tck=-.05,lab=FALSE)
     axis(2,las=1,pos=4,lwd=0,cex.axis=0.6)
     mtext(text="casos de dengue", line=1,side=2, cex = 0.7) # line=3.5 (original)
     maxy <- max(casos, na.rm=TRUE)
    legend(25, maxy, c("casos","casos estimados","tweets"),col=c(1,2,3), lty=1, bty="n",cex=0.7)
    par(new=T)
    plot(tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
    lines(tweet, col=3, type="h") #*coefs[2] + coefs[1]
    axis(4,las=1,pos=106,tck=-.05,lab=FALSE)
    axis(4,las=1,pos=103,lwd=0,cex.axis=0.6)
    mtext(text="tweets", line=0.5, side=4, cex = 0.7)
  })
  
  #  chik 
  n = dim(serieC)[1]
  seriefinalC = serieC[(n-tsdur):n,]
  
  with(seriefinalC, {
    par(mai=c(0,0,0,0),mar=c(3,0.5,0.5,0.5))
    plot(casos, type="s", xlab="", ylab="", axes=FALSE,bty="n")
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est[((tsdur + 1) - 6):(tsdur + 1)], lty=1, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_min[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_max[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    
    axis(1, pos=-2, las=2, at=seq(1,(tsdur+1),by=8),
         tcl=-0.25,labels=FALSE) #pos=0 , labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=10)], at=seq(1,length(seriefinal$casos),by=12)
    axis(1, pos=0, las=2, at=seq(1,(tsdur+1),by=8), 
         labels=data_iniSE[seq(1,length(casos),by=8)],
         cex.axis=0.6,lwd=0,tcl=-0.25) #pos=0 
    # linhas verticais marcando o inicio de cada ano
    anos <- unique(ano)
    for (a in anos) abline(v = which(ano == a)[1], lty=3)
    
    axis(2,las=1,pos=-0.4,tck=-.05,lab=FALSE)
    axis(2,las=1,pos=4,lwd=0,cex.axis=0.6)
    mtext(text="casos de chikungunya", line=1,side=2, cex = 0.7) # line=3.5 (original)
    maxy <- max(casos, na.rm=TRUE)
    legend(25, maxy, c("casos","casos estimados"),col=c(1,2,3), lty=1, bty="n",cex=0.7)
      })
  
  
  #  zika  
  n = dim(serieZ)[1]
  seriefinalZ = serieZ[(n-tsdur):n,]
  
  with(seriefinalZ, {
    par(mai=c(0,0,0,0),mar=c(3,0.5,0.5,0.5))
    plot(casos, type="s", xlab="", ylab="", axes=FALSE,bty="n")
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est[((tsdur + 1) - 6):(tsdur + 1)], lty=1, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_min[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    lines(((tsdur + 1) - 6):(tsdur + 1),casos_est_max[((tsdur + 1) - 6):(tsdur + 1)], lty=2, col=2)
    
    axis(1, pos=-2, las=2, at=seq(1,(tsdur+1),by=8),
         tcl=-0.25,labels=FALSE) #pos=0 , labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=10)], at=seq(1,length(seriefinal$casos),by=12)
    axis(1, pos=0, las=2, at=seq(1,(tsdur+1),by=8), 
         labels=data_iniSE[seq(1,length(casos),by=8)],
         cex.axis=0.6,lwd=0,tcl=-0.25) #pos=0 
   
     # linhas verticais marcando o inicio de cada ano
    anos <- unique(ano)
    for (a in anos) abline(v = which(ano == a)[1], lty=3)
    
    axis(2,las=1,pos=-0.4,tck=-.05,lab=FALSE)
    axis(2,las=1,pos=4,lwd=0,cex.axis=0.6)
    mtext(text="casos de zika", line=1,side=2, cex = 0.7) # line=3.5 (original)
    maxy <- max(casos, na.rm=TRUE)
    legend(25, maxy, c("casos","casos estimados"),col=c(1,2,3), lty=1, bty="n",cex=0.7)
  })
  
         
         }




# subfigura de baixo: alerta colorido
#p # subfigura do cima
# Receptividade do clima na região
#nvarcli <- which(names(resD) == eval(varcli))
#clima.mean = aggregate(resD[,nvarcli]~data_iniSE,data=resD,FUN=mean,na.rm=TRUE)
#clima.min = aggregate(resD[,nvarcli]~data_iniSE,data=resD,FUN=min,na.rm=TRUE)
#clima.max = aggregate(resD[,nvarcli]~data_iniSE,data=resD,FUN=max,na.rm=TRUE)

#par(mai=c(0,0,0,0),mar=c(1,4,0,3))
#ylims <- (c(0.9*min(clima.min[,2], na.rm=T), min(100,1.1*max(clima.max[,2], na.rm=T))))
#plot(1:(tsdur + 1),clima.mean[(n-tsdur):n,2], type="l", xlab="", ylab =eval(varcli),axes=FALSE,ylim=ylims)
#lines(1:(tsdur + 1),clima.min[(n-tsdur):n,2], col="grey")
#lines(1:(tsdur + 1),clima.max[(n-tsdur):n,2],col="grey")
#axis(2)
#if(eval(varcli) %in% c("temp_min", "temp_med", "temp_max")) abline(h=param[[1]]$tcrit, lty=2, col = "darkgreen")
#if(eval(varcli) %in% c("umid_min", "umid_med", "umid_max")) abline(h=param[[1]]$ucrit, lty=2, col = "darkgreen")
#legend(x="topleft",lty=c(1,1,2),col=c("black", "grey","darkgreen"),
#       legend=c("valor médio","valores extremos","limiar favorável transmissão"),cex=0.85,bty="n")
#par(mai=c(0,0,0,0),mar=c(1,4,0,4))
#plot_alerta(obj, var="inc",ini=min(objc$SE),fim=max(objc$SE))
#abline(h=param$posseas*obj$data$pop[1],lty=2)
#legend(x="topright",lty=c(3,2,2),col=c("red","darkgreen","black"),
#       legend=c("limiar epidêmico","limiar pré-epidêmico","limiar pós-epidêmico"),cex=0.85,bty="n")

#}



