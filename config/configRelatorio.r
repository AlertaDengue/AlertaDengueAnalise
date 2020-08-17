# Configuracao para os boletins do Alerta


# If a directory does not exist, create one.
#checkDirectory ------------------------------------
checkDirectory <- function(directory){
  calldir <- paste("if [ -d",directory, "]; then echo \"True\"; else mkdir", directory, "; fi")
  system(calldir)
}


# configRelatorio ------------------------------------
configRelatorio <- function(uf, regional, sigla, data, alert, pars, varcli = "temp_min", shape, varid, dir, datasource){
  
  dirfigs = paste(basedir,dir,"figs/",sep="/")
  checkDirectory(dirfigs) # if directory does not exist, creates one

  ## Estado, suas regionais e municipios

  estado = uf
  sigla = sigla
  municipios = getCidades(uf=estado,datasource=con)
  nmunicipios = dim(municipios)[1]
  regs = getRegionais(uf = estado,sortedby = "id") 
  nickregs = abbreviate(iconv(regs, to = "ASCII//TRANSLIT"))
  nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  

  ## As datas

  ano = floor(data/100)
  se = data - ano*100 
  

  # Mapa do estado (funcao basica do alerttools)

  geraMapa(alerta=alert, se=data, shapefile = shape,   
             varid=varid, titulo="", 
             filename=paste("Mapa_E", sigla,".png", sep=""),
             dir=dirfigs, caption=FALSE)
  

  # Mapas de todas as Regionais (funcao customizada, no codigoFiguras.R)

  if(missing(regional)){ # se for estadual, faz para todas as RS
  mapa.regional(alerta=alert, regionais=regs, estado = uf, sigla = sigla,
                data = data, pars=pars, shape=shape, shapeid=varid, dir=dirfigs ,
                datasource=datasource)}
  else{ # faz so para a regional em questao
      mapa.regional(alerta=alert, regionais=regional, estado = uf, sigla = sigla,
                    data = data, pars=pars, shape=shape, shapeid=varid, dir=dirfigs ,
                    datasource=datasource)
    }
  

  # Tabelao com resultado do alerta por municipio e totais 

  totano=0; totultse=0
  nverde=0; namarelo=0;nlaranja=0;nvermelho=0
  nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
      
  # ----- começo do tabelao
  tabelao = data.frame(Municipio = character(),Regional = character(), 
                               Temperatura = numeric(), Tweets=numeric(),
                               Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                               Nivel=character(),stringsAsFactors = FALSE)
     
  for (i in 1:nmunicipios){
    ai <- alert[[i]] 
    
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
                              Regional = as.character(ai$data$nome_regional[1]),
                              Temperatura = ai$data$temp_min[linhase],
                              Tweets = ai$data$tweet[linhase],
                              Casos = ai$data$casos[linhase], 
                              Incidencia=ai$data$inc[linhase],
                              Rt=ai$data$Rt[linhase],
                              Nivel=as.character(cores[ai$indices$level[linhase]]),
                              stringsAsFactors = FALSE)
    if (varcli == "umid_min")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = as.character(ai$data$nome_regional[1]),
                                Umid.min = ai$data$umid_min[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    if (varcli == "umid_max")
      paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                                Regional = as.character(ai$data$nome_regional[1]),
                                Umid.min = ai$data$umid_max[linhase],
                                Tweets = ai$data$tweet[linhase],
                                Casos = ai$data$casos[linhase], 
                                Incidencia=ai$data$inc[linhase],
                                Rt=ai$data$Rt[linhase],
                                Nivel=as.character(cores[ai$indices$level[linhase]]),
                                stringsAsFactors = FALSE)
    if (!(varcli %in% c("temp_min", "umid_min", "umid_max")))message(paste(varcli, "não contemplada na conf do tabelao"))
    tabelao[i,] = paratabelao
    
  }
  
  fname = paste(dirfigs,"/","tabelao",sigla,".tex",sep="")
  tabelaox <-xtable(tabelao, align ="ll|lllllll")
  digits(tabelaox) <- c(0,0,0,1,0,0,1,1,0)
      
  add.to.row <- list(pos = list(0), command = NULL)
  command <- paste0("\\hline\n\\endhead\n",
                        "\\hline\n",
                        "{\\footnotesize Continua na próxima página}\n",
                        "\\endfoot\n",
                        "\\endlastfoot\n")
  add.to.row$command <- command
  print(tabelaox, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
            include.rownames=FALSE, tabular.environment="longtable",hline.after=c(-1),
            add.to.row=add.to.row)
  # -------- fim do tabelao
      
  
  # Gera e salva tabelas regionais (xtable)
  
      
  for (k in regs) {
    cidades = getCidades(regional = k, uf = estado, datasource = datasource)
    cidadessemespaco = gsub(" ","",cidades$nome)
    linhascidades <- which(names(alert) %in% cidadessemespaco)
    N = length(linhascidades)
    
    if (varcli == "temp_min")
    tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                    "tcasesICmin","tcasesmed","tcasesICmax")])
    if (varcli == "umid_min")
      tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","umid_min",
                                                      "tcasesICmin","tcasesmed","tcasesICmax")])
    if (varcli == "umid_max")
      tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","umid_max",
                                                      "tcasesICmin","tcasesmed","tcasesICmax")])
    
    for (n in 2:N){
      if (varcli == "temp_min")
      newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                         "tcasesICmin","tcasesmed","tcasesICmax")])
      
      if (varcli == "umid_min")
        newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","umid_min",
                                                           "tcasesICmin","tcasesmed","tcasesICmax")])
      
      if (varcli == "umid_max")
        newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","umid_max",
                                                           "tcasesICmin","tcasesmed","tcasesICmax")])
      
      tabela[,2:8] <- tabela[,2:8]+newtabela[,2:8]
    }
    
    if(varcli == "temp_min") tabela$temp_min <- tabela$temp_min/N   #media das temperaturas 
    if(varcli == "umid_min") tabela$umid_min <- tabela$umid_min/N   #media das temperaturas 
    if(varcli == "umid_max") tabela$umid_max <- tabela$umid_max/N   #media das temperaturas 
    
    tabela$inc <- tabela$casos/tabela$pop*100000
    
    if(varcli == "temp_min"){
      tabelafinal <- tail(tabela[,c("SE","temp_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
      names(tabelafinal)<-c("SE","temperatura","tweet","casos notif","casos preditos","ICmin","ICmax","incidência")
    }
    if(varcli == "umid_min"){
      tabelafinal <- tail(tabela[,c("SE","umid_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
      names(tabelafinal)<-c("SE","umidade.minima","tweet","casos notif","casos preditos","ICmin","ICmax","incidência")
    }
    if(varcli == "umid_max"){
      tabelafinal <- tail(tabela[,c("SE","temp_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
      names(tabelafinal)<-c("SE","umidade.maxima","tweet","casos notif","casos preditos","ICmin","ICmax","incidência")
    }
    nomesemespaco = gsub(" ","",k)
    nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
    fname = paste(dirfigs,"/","tabregional",sigla,"_",nomesemacento,".tex",sep="")
    
    tabelax <-xtable(tabelafinal,align ="cc|ccccccc",digits = 0,size="\\small")
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
    
    # --- fim das tabelas regionais
    

    # Figuras-resumo das regionais 

            
    res = write.alerta(alert[[1]])
    for (n in 2:N) res = rbind(res, write.alerta(alert[[n]]))
    
    serie = aggregate(cbind(tweet,casos)~data_iniSE,data=res,FUN=sum,na.rm=TRUE)
    
    figname = paste(dirfigs,"tweet",sigla,"_",nomesemacento,".png",sep="")
    png(figname, width = 12, height = 5.5, units="cm", res=200)
    layout(matrix(1), widths = lcm(10),heights = c(lcm(5)))
    
    n = dim(serie)[1]
    seriefinal = serie[(n-104):n,]
    
    par(mai=c(0,0,0,0),mar=c(3,0.5,0.5,0.5))
    plot(seriefinal$casos, type="l", xlab="", ylab="", axes=FALSE,bty="o")
    axis(1, pos=-2, las=2, at=seq(1,length(seriefinal$casos),by=8),
         tcl=-0.25,labels=FALSE) #pos=0 , labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=10)], at=seq(1,length(seriefinal$casos),by=12)
    axis(1, pos=0, las=2, at=seq(1,length(seriefinal$casos),by=8), 
         labels=seriefinal$data_iniSE[seq(1,length(seriefinal$casos),by=8)],
         cex.axis=0.6,lwd=0,tcl=-0.25) #pos=0 
    
    #axis(1, at=c(0:15),tcl=-0.25,line=0,cex.axis=0.5,lab=FALSE) 
    #axis(2,las=1,pos=-0.3,tck=-.01,at=c(5,10,15,20,25,30,35,40,45),lab=FALSE)
    #axis(2,las=1,pos=0,lwd=0,cex.axis=0.75,at=c(5,10,15,20,25,30,35,40,45),lab=FALSE)
    #axis(4,las=1,pos=15.5,tck=-.01,at=c(0,10,20,30,40,50,60,70,80,90,100),lab=FALSE,col='blue')
    #axis(4,las=1,pos=15.2,lwd=0,cex.axis=0.6,at=c(0,10,20,30,40,50,60,70,80,90,100),col.axis='blue')
    
    
    #axis(2,las=2,cex.axis=0.7) ORIGINAL
    axis(2,las=1,pos=-0.4,tck=-.05,lab=FALSE)
    axis(2,las=1,pos=4,lwd=0,cex.axis=0.6)
    mtext(text="casos de dengue", line=1,side=2, cex = 0.7) # line=3.5 (original)
    maxy <- max(seriefinal$casos, na.rm=TRUE)
    legend(25, maxy, c("casos","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
    par(new=T)
    plot(seriefinal$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
    lines(seriefinal$tweet, col=3, type="h") #*coefs[2] + coefs[1]
    #axis(1, pos=0, lty=0, lab=FALSE)
    #axis(4,las=2, cex.axis=0.7)
    axis(4,las=1,pos=106,tck=-.05,lab=FALSE)
    axis(4,las=1,pos=103,lwd=0,cex.axis=0.6)
    mtext(text="tweets", line=0.5, side=4, cex = 0.7)
    dev.off()
    
  }      
  filename = ifelse(missing(regional), paste(dir,"params",sigla,".RData",sep=""),
                    paste(dir,"paramsRS",regional,".RData",sep=""))
  
  # ----- fim das tabelas-resumo das regionais
  
  
  res = list(estado=estado, sigla=sigla, se=se, ano=ano, municipios=municipios,
                 nmunicipios=nmunicipios, regs=regs,nickregs=nickregs, totano=totano, 
                 totultse=totultse, tabelao=tabelao, nickmun=nickmun, nverde=nverde, namarelo=namarelo,
                 nlaranja=nlaranja, nvermelho=nvermelho, nverde1=nverde1, namarelo1=namarelo1, 
                 nlaranja1=nlaranja1, nvermelho1=nvermelho1, data_relatorio=data, dir=filename)
  
  message(paste("salvando RData em",filename))
  save(estado, sigla, se, ano, municipios, nmunicipios, regs,nickregs, totano, totultse, tabelao,
           nickmun, nverde, namarelo, nlaranja, nvermelho, nverde1, namarelo1, nlaranja1, nvermelho1, data,
           file=filename)
  res
}


# 
# Gera objetos para o Boletim Regional 
# 
# configRelatorioRegional -----------------
configRelatorioRegional <- function(tipo = "completo", uf, regional, sigla, varcli = "temp_min", data, tsdur=104, alert,  
                                    shape, varid, dir, datasource, dirb=basedir,geraPDF=TRUE){
  setwd("~/")
  
  dirfigs = paste(dirb, dir,"figs/",sep="/")
  
 
  ## Dados da regional
 
  municipios = getCidades(uf=uf, regional = regional)
  nmunicipios = dim(municipios)[1]
  nomeregfiguras = iconv(gsub(" ","",regional),to = "ASCII//TRANSLIT")
  nomemunfiguras = iconv(gsub(" ","",municipios$nome),to = "ASCII//TRANSLIT")
  nickreg = abbreviate(iconv(regional, to = "ASCII//TRANSLIT"))
  municipios$nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  
 
  ## As datas
 
  ano = floor(data/100)
  se = data - ano*100 
  
 
  # Mapa da Regional
 
   nomemapareg=mapa.regional(alerta=alert, regionais=regional, estado = uf, sigla = sigla,
                  data = data, shape=shape, shapeid=varid, dir=dirfigs ,
                  datasource=datasource)
  
 
  # Descritores gerais (nverde, namarelo, totultse, etc) 
 
  descrgerais <- faztabelaoRS(ale = alert,ano = ano, uf = uf, varcli = varcli,data = data,tex=FALSE)
  print("descrgerais")
 
  # Tabelao com resultado do alerta por municipio da Regional e totais (funcao no configfiguras)
 
  
  nometabelao = paste(dirfigs,"/","tabelaoMun_",nomeregfiguras,".tex",sep="")
  
  tabelaox <- faztabelaoRS(ale = alert,ano = ano,varcli = varcli, uf = uf, data = data,tex=TRUE)
  print("tabelao")
  add.to.row <- list(pos = list(0), command = NULL)
  command <- paste0("\\hline\n\\endhead\n",
                    "\\hline\n",
                    "{\\footnotesize Continua na próxima página}\n",
                    "\\endfoot\n",
                    "\\endlastfoot\n")
  add.to.row$command <- command
  
  print(tabelaox, type="latex", file=nometabelao, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE, tabular.environment="longtable",hline.after=c(-1),
        add.to.row=add.to.row)
  
  

  # tabela resumo

  nometabreg = paste(dirfigs,"/","tabregional_",nomeregfiguras,".tex",sep="")
    
  tabelax <- faztabelaresumo(alert = alert,municipios = municipios, varcli = varcli, nmunicipios = nmunicipios,tex=TRUE)
  print(tabelax, type="latex", file=nometabreg, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  print("faztabelaresumo")  

    # Figura-resumo da regional 

  
  munreg = which(municipios$nome_regional == regional)
  figregname = paste(dirfigs,"figuraRS_",nomeregfiguras,".png",sep="")
  png(figregname, width = 12, height = 5.5, units="cm", res=200)
  fazfiguraregional(ale = alert, municipreg = munreg, varcli = varcli, tsdur=104)
  dev.off()  
        
  filename = paste(dirfigs,"paramsRS_",nomeregfiguras,".RData",sep="")
  print("fazfiguraregional") 

  # Figuras dos municipios da Regional (3 subfiguras)

  
  municipios$figname <- "NA"
  for(cid in 1:nmunicipios){ 
    cidadessemespaco = gsub(" ","",municipios$nome[cid])
    figname = paste(dirfigs,"figMun_",nomemunfiguras[cid],".png",sep="")
    gg <- as.character(municipios$municipio_geocodigo[cid]) 
    png(figname, width = 14, height = 16, units="cm", res=300)  # inicio da figura 
    figuramunicipio(alert[[gg]], varcli=varcli)
    municipios$figname[cid] <- figname
    dev.off()  
  }
  
  print("figs mun")
  # Tabelas dos municipios da Regional 
  
  municipios$tabname <- "NA"
  if (varcli == "temp_min") varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesICmax","p1")
  if (varcli == "umid_min") varstab <- c("SE","umid_min","tweet", "casos", "inc", "tcasesICmax","p1")
  if (varcli == "umid_max") varstab <- c("SE","umid_max","tweet", "casos", "inc", "tcasesICmax","p1")
  
  for(cid in 1:nmunicipios){ 
    gg <- municipios$municipio_geocodigo[cid] 
    tab <- tail(alert[[cid]]$data[,varstab])
    tab$p1 <- tab$p1*100
    if (varcli == "temp_min")    names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "incidência max","pr(aumento)")
    if (varcli == "umid_min")    names(tab) <- c("SE","umidade.min","tweet", "casos notif", "incidência", "incidência max","pr(aumento)")
    if (varcli == "umid_max")    names(tab) <- c("SE","umid.max","tweet", "casos notif", "incidência", "incidência max","pr(aumento)")
    municipios$tabnome[cid] <- paste(dirfigs,"tabelaMun_",nomemunfiguras[cid],".tex",sep="")
    tabelax <-xtable(tab,align ="cc|cccccc",digits = 0)
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=municipios$tabnome[cid], floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
  
  res = list(estado=uf, sigla=sigla, se=se, ano=ano, municipios=municipios,
             nmunicipios=nmunicipios, regional=regional,nomeregiconv=nomeregfiguras, 
             nomemuniconv=nomemunfiguras, totano=descrgerais$totano, nickreg=nickreg,
             totultse=descrgerais$totultse, nverde=descrgerais$nverde, 
             namarelo=descrgerais$namarelo, nlaranja=descrgerais$nlaranja, 
             nvermelho=descrgerais$nvermelho, nverde1=descrgerais$nverde1, 
             namarelo1=descrgerais$namarelo1, nlaranja1=descrgerais$nlaranja1, 
             nvermelho1=descrgerais$nvermelho1, data_relatorio=data, dir=filename,
             nomemapareg = nomemapareg, nometabreg = nometabreg, nometabelao = nometabelao,
             tabelao = descrgerais$tabelao, figreg = figregname)
  
 
  # salvando o boletim
 
  nomebol = NULL
  if (geraPDF==TRUE){
    message("gerando PDF...")
    if(missing(tipo)) message("indique se o tipo = simples ou completo. Simples se for municipio isolado.")
    if(tipo == "completo") nomebol=geraPDF(tipo="regional", obj = res, dir.boletim =paste(dir,"boletins",sep="/")) 
    if(tipo == "simples") nomebol=geraPDF(tipo="regionalsimples", obj = res, dir.boletim = paste(dir,"boletins",sep="/"))
  } 
  
  #message(paste("salvando RData em",filename))
  #save(estado, sigla, se, ano, municipios, nmunicipios, regional,nickreg, totano, totultse, tabelao, nverde, namarelo, nlaranja, nvermelho, nverde1, namarelo1, nlaranja1, nvermelho1, data,
  #     file=filename)
  nomebol
}



# configRelatorioEstadual -----------------

# data = data final do relatorio, tsdur = tamanho da serie plotada
configRelatorioEstadual <- function(uf, sigla, data, tsdur=104 , 
                                    varcli = "temp_min", alert, 
                                    pars, shape, varid, dir, dini=201401,
                                    datasource, dirb=basedir,geraPDF=TRUE){
  setwd("~/")
  
  dirfigs = paste(dirb,dir,"figs/",sep="/")
  print(paste("dirfigs:", dirfigs))
 
  ## Dados do estado
 
  estado = uf
  sigla = sigla
  municipios = getCidades(uf=estado,datasource=con)
  nmunicipios = dim(municipios)[1]
  regs = getRegionais(uf = estado, sortedby = 'id') 
  nickregs = abbreviate(iconv(regs, to = "ASCII//TRANSLIT"))
  nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  
  
  nomeregfiguras = iconv(gsub(" ","",regs),to = "ASCII//TRANSLIT")
  nomemunfiguras = iconv(gsub(" ","",municipios$nome),to = "ASCII//TRANSLIT")
  nickreg = abbreviate(iconv(regs, to = "ASCII//TRANSLIT"))
  municipios$nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  
 
  ## As datas
 
  ano = floor(data/100)
  se = data - ano*100 
  
   
  relatorio <- "infodengue"  # default, substituido por infoarbo se for pertinente
 
  # Mapa de alerta de dengue do estado (funcao basica do alerttools)
  shap <- paste(dirb,shape,sep="/")
  print(paste("shape:",shap))
  geraMapa(alerta=alert, se=data, shapefile = shap,   
           varid=varid, titulo="", 
           filename=paste("Mapa_E", sigla,".png", sep=""),
           dir=dirfigs, caption=FALSE)
  
  
  # Mapas de alerta de degue de todas as Regionais (funcao customizada, no codigoFiguras.R)
 
  
  nomemapareg = c()
  
  for (regional in regs) nomemapareg = c(nomemapareg, 
                  mapa.regional(alerta=alert, regionais=regional, estado = uf, 
                                sigla = sigla,data = data, shape=shape, 
                                shapeid=varid, dir=dirfigs,datasource=datasource))
  
  # Faz tabela historico
  restab <- tabela_historico(alert)
 
  # Descritores gerais (nverde, namarelo, totultse, etc) 
 
  descrgerais <- faztabelaoRS(ale = alert, ano = ano ,varcli = varcli, 
                              uf = estado, data = data,tex=FALSE)
  
 
  # Descritores gerais regionais (nverde, namarelo, totultse, etc) 
 
  tabelasomatorios <- tabSomatorio(ale = alert,ano = ano,data = data, uf=uf,
                                   varcli = varcli,agregaregional = TRUE)
  
 
  # Tabelao com resultado do alerta por municipio e totais (funcao no configfiguras)
 
  
  nometabelao = paste(dirfigs,"tabelaoMun_",sigla,".tex",sep="")
  
  tabelaox <- faztabelaoRS(ale = alert,ano = ano,data = data, uf = uf, varcli = varcli,tex=TRUE)
  
  add.to.row <- list(pos = list(0), command = NULL)
  command <- paste0("\\hline\n\\endhead\n",
                    "\\hline\n",
                    "{\\footnotesize Continua na próxima página}\n",
                    "\\endfoot\n",
                    "\\endlastfoot\n")
  add.to.row$command <- command
  
  print(tabelaox, type="latex", file=nometabelao, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE, tabular.environment="longtable",hline.after=c(-1),
        add.to.row=add.to.row)
  message(paste("tabelao criado:",nometabelao))
  
 
  # tabela resumo das regionais
 
  
  nomestabreg = c()
  for (i in 1:length(regs)){
    nometabreg = paste(dirfigs,"tabregional_",nomeregfiguras[i],".tex",sep="")
    nomestabreg <- c(nomestabreg, nometabreg)
    munreg = which(municipios$nome_regional == regs[i])
    nmunreg = length(munreg)
    tabelax <- faztabelaresumo(alert = alert,municipios = municipios[munreg,], 
                               nmunicipios = nmunreg,varcli = varcli, tex=TRUE)
  print(tabelax, type="latex", file=nometabreg, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  }
  message("tabelas regionais criadas...")
  
 
  # Figura-resumo da regional 
 
  
  nomesfigreg = c()
  for (i in 1:length(regs)){
    nomefigreg = paste(dirfigs,"figuraRS_",nomeregfiguras[i],".png",sep="")
    nomesfigreg <- c(nomesfigreg, nomefigreg)
    munreg = which(municipios$nome_regional == regs[i])
    
    png(nomefigreg, width = 12, height = 5.5, units="cm", res=200)
    fazfiguraregional(ale = alert,municipreg = munreg, varcli = varcli, tsdur=104)
    dev.off()  
  }
  message("figuras regionais criadas")
  
   # objeto com variaveis do estado para serem usadas pelos municipios e regionais
  filename = paste(dirfigs,"params",sigla,".RData",sep="")
  
  message(paste("salvando RData em",filename))
  
  
  res = list(estado=estado, sigla=sigla, se=se, ano=ano, municipios=municipios,
                      nmunicipios=nmunicipios, regional=regs,nickregs = nickregs,
             nomeregiconv=nomeregfiguras, 
                      nomemuniconv=nomemunfiguras, dir=dirfigs,
                      nomemapareg = nomemapareg,nomestabreg = nomestabreg, totano=descrgerais$totano,
             totultse=descrgerais$totultse, nverde=descrgerais$nverde, 
             namarelo=descrgerais$namarelo, nlaranja=descrgerais$nlaranja, tabelao=tabelaox, 
             nomesfigreg = nomesfigreg,nometabelao=nometabelao,tabelasomatoriosRS=tabelasomatorios,
             nvermelho=descrgerais$nvermelho, nverde1=descrgerais$nverde1, 
             namarelo1=descrgerais$namarelo1, nlaranja1=descrgerais$nlaranja1, 
             nvermelho1=descrgerais$nvermelho1)
  
  save(res, file=filename)
  

  # salvando o boletim

  nomebol = NULL
  if (geraPDF==TRUE){
    message("gerando PDF...")
    nomebol=geraPDF(tipo="Estadual", obj = res, dir.boletim =paste(dir,"boletins",sep="/")) 
    return(nomebol)
  } else {return(res)}
  
}


## configRelatorioMunicipal -------

# gera objetos necessarios para o boletim Municipal
# alert - objeto gerado pelo update.alerta, siglaUF = "RJ", dir.out = pasta mestre do municipio,
# data - data do relatorio. Duas opcoes, relatorio completo ou simples
configRelatorioMunicipal <- function(tipo="completo", alert, estado, siglaUF, dir.out, data,  
                                     alechik, alezika, varcli = "temp_min", datasource=con,
                                     dirb=basedir, tamanhotabela = 16, geraPDF=TRUE){
  dirfigs = paste(dirb,"/",dir.out,"/figs",sep="")
  
  # Identificacao da cidade
  ale <- alert[[1]]
  nomecidade = ale$data$nome[1]
  geocodigo = ale$data$cidade[1]
  
  # Identificacao da regional a qual ela pertence
  regionalmun = as.character(dbGetQuery(datasource, paste("SELECT nome_regional 
                                             FROM \"Dengue_global\".regional_saude 
                                             where municipio_geocodigo = ", geocodigo, sep="")))   
  # relacao dos municipios na mesma reg
  municip.reg <- getCidades(uf=estado,regional = regionalmun, datasource=datasource)
  
  # Data do relatorio
  ano = floor(data/100)
  se = data - ano*100 
  linhasdoano = which(floor(ale$data$SE/100)==ano) # posicao do dataframe para essa data
  linhase = which(ale$data$SE==data)
  linhase1 = which(ale$data$SE==data)-1 # posicao referente a semana anterior
  
 
  relatorio <- "infodengue"  # default, substituido por infoarbo se for pertinente
  # Total de casos no municipio nas ultimas 2 semanas (dengue)
  totanomun = sum(ale$data$casos[linhasdoano],na.rm=TRUE)
  totultsemun = ale$data$casos[linhase]
  
  # Cor do alerta na ultima semana
  cores = c("verde","amarelo","laranja","vermelho")
  nivelmun = cores[ale$indices$level[linhase] ]  
  
  # Gera nome do arquivo de saida paramsNomedaCidade.RData
  nomesemespaco = gsub(" ","",nomecidade)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  fname = paste(dirb,"/",dir.out,"/figs/params",nomesemacento,".RData",sep="")
  
  # Gera figura chamada figuraNomedaCidade.png com 3 subfiguras
  figname = paste(dirb,"/",dir.out,"/figs/figura",nomesemacento,".png",sep="")
  
  png(figname, width = 14, height = 16, units="cm", res=300)  # inicio da figura 
  figuramunicipio(ale,varcli = varcli)
  dev.off()  # fim da figura 
  message(paste("figura",figname,"salva. Objetos criados para o relatorio."))
  # Gera tabela resumo das ultimas semanas

  if (!missing(alechik))  tamanhotabela = 8 # fazer tabelas mais curtas no infoarbo
  
  if (varcli== "temp_min") varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesmed","p1")
  if (varcli== "umid_min") varstab <- c("SE","umid_min","tweet", "casos", "inc", "tcasesmed","p1")
  if (varcli== "umid_max") varstab <- c("SE","umid_max","tweet", "casos", "inc", "tcasesmed","p1")
  tab <- tail(ale$data[,varstab], n=tamanhotabela)
  tab$p1 <- tab$p1*100
  cores <- c("verde","amarelo","laranja","vermelho")
  tab <- cbind(tab,cores[tail(ale$indices$level,n=tamanhotabela)])
  if (varcli== "temp_min") names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
  if (varcli== "umid_min") names(tab) <- c("SE","umid.min","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
  if (varcli== "umid_max") names(tab) <- c("SE","umid.max","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
  tabname <- paste(dirb,"/",dir.out,"/figs/tabela",nomesemacento,".tex",sep="")
  tabelax <-xtable(tab,align ="cc|ccccccc",digits = 0)
  digits(tabelax) <- 0
  print(tabelax, type="latex", file=tabname, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  
  
  ### Chik
  if (!missing(alechik)){
    relatorio <- "infoarbo"
    alechik <- alechik[[1]]
    
    # Total de casos no municipio nas ultimas 2 semanas (dengue)
    totanomunC = sum(alechik$data$casos[linhasdoano],na.rm=TRUE)
    totultsemunC = alechik$data$casos[linhase]
    
    # Cor do alerta na ultima semana
    nivelmunC = cores[alechik$indices$level[linhase] ]  
    
    # Gera nome do arquivo de saida paramsNomedaCidade_chik.RData
    fnameC = paste(dirb,"/",dir.out,"/figs/params",nomesemacento,"Chik.RData",sep="")
    
    # Gera figura chamada figuraNomedaCidade_chik.png com 3 subfiguras
    fignameC = paste(dirb,"/",dir.out,"/figs/figura",nomesemacento,"Chik.png",sep="")
    
    png(fignameC, width = 14, height = 16, units="cm", res=300)  # inicio da figura 
    figuramunicipio(alechik,varcli = varcli, cid = "A92.0")
    dev.off()  # fim da figura
    message(paste("figura",fignameC,"salva. Objetos criados para o relatorio."))
    # Gera tabela resumo das ultimas semanas

    tamanhotabela = 16  # n. linhas na tabela

    if (varcli== "temp_min") varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesmed","p1")
    if (varcli== "umid_min") varstab <- c("SE","umid_min","tweet", "casos", "inc", "tcasesmed","p1")
    if (varcli== "umid_max") varstab <- c("SE","umid_max","tweet", "casos", "inc", "tcasesmed","p1")
    tab <- tail(alechik$data[,varstab], n=tamanhotabela)
    tab$p1 <- tab$p1*100
    tab <- cbind(tab,cores[tail(alechik$indices$level,n=tamanhotabela)])
    if (varcli== "temp_min") names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    if (varcli== "umid_min") names(tab) <- c("SE","umid.min","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    if (varcli== "umid_max") names(tab) <- c("SE","umid.max","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    tabnameC <- paste(dirb,"/",dir.out,"/figs/tabela",nomesemacento,"Chik.tex",sep="")
    tabelax <- xtable(tab,align ="cc|ccccccc",digits = 0)
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=tabnameC, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
  ### Zika
  if (!missing(alezika)){
    alezika <- alezika[[1]]
    # Total de casos no municipio nas ultimas 2 semanas (dengue)
    totanomunZ = sum(alezika$data$casos[linhasdoano],na.rm=TRUE)
    totultsemunZ = alezika$data$casos[linhase]
    
    # Cor do alerta na ultima semana
    nivelmunZ = cores[alezika$indices$level[linhase] ]  
    
    # Gera nome do arquivo de saida paramsNomedaCidade_zika.RData
    fnameZ = paste(dirb,"/",dir.out,"/figs/params",nomesemacento,"Zika.RData",sep="")
    
    # Gera figura chamada figuraNomedaCidade_zika.png com 3 subfiguras
    fignameZ = paste(dirb,"/",dir.out,"/figs/figura",nomesemacento,"Zika.png",sep="")
    
    png(fignameZ, width = 14, height = 16, units="cm", res=300)  # inicio da figura 
    figuramunicipio(alezika,varcli = varcli, cid = "A92.8")
    dev.off()  # fim da figura
    message(paste("figura",fignameZ,"salva. Objetos criados para o relatorio."))
    # Gera tabela resumo das ultimas semanas
    
    tamanhotabela = 16  # n. linhas na tabela
    if (varcli== "temp_min") varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesmed","p1")
    if (varcli== "umid_min") varstab <- c("SE","umid_min","tweet", "casos", "inc", "tcasesmed","p1")
    if (varcli== "umid_max") varstab <- c("SE","umid_max","tweet", "casos", "inc", "tcasesmed","p1")
    tab <- tail(alezika$data[,varstab], n=tamanhotabela)
    tab$p1 <- tab$p1*100
    tab <- cbind(tab,cores[tail(alezika$indices$level,n=tamanhotabela)])
    if (varcli== "temp_min") names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    if (varcli== "umid_min") names(tab) <- c("SE","umid.min","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    if (varcli== "umid_max") names(tab) <- c("SE","umid.max","tweet", "casos notif", "incidência", "casos estimados","pr(incid. subir)","nivel")
    tabnameZ <- paste(dirb,"/",dir.out,"/figs/tabela",nomesemacento,"Zika.tex",sep="")
    tabelax <- xtable(tab,align ="cc|ccccccc",digits = 0)
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=tabnameZ, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
  
 
  # Salvando objeto para o PDF
 
  # objeto que e' retornado pela funcao e lido pelo geraPDF (tambem e salvo como RData)
  if(relatorio == "infodengue") res = list(nomecidade=nomecidade, estado=estado, nomecidadeiconv = nomesemacento, regionalmun=regionalmun, sigla = siglaUF, alert=alert, totanomun=totanomun,
             totultsemun=totultsemun, nivelmun=nivelmun, se=se, ano=ano, data=data, figname=figname, dir.out = dir.out,
             municip.reg=municip.reg,nometabmun=tabname)
  if(relatorio == "infoarbo") res = list(nomecidade=nomecidade, estado=estado, nomecidadeiconv = nomesemacento, regionalmun=regionalmun, sigla = siglaUF, alert=alert, totanomun=totanomun,
               totultsemun=totultsemun, nivelmun=nivelmun, se=se, ano=ano, data=data, figname=figname, dir.out = dir.out,
               municip.reg=municip.reg,nometabmun=tabname, 
               totanomunC=totanomunC,totultsemunC=totultsemunC,nivelmunC=nivelmunC, fnameC=fnameC, fignameC=fignameC,
             tabnameC=tabnameC,alechik=alechik,
             totanomunZ=totanomunZ,totultsemunZ=totultsemunZ,nivelmunZ=nivelmunZ, fnameZ=fnameZ, fignameZ=fignameZ,
             tabnameZ=tabnameZ,alezika=alezika)
  
  #print(names(res))
  
  save(res, file=fname)
  
  
 
  # salvando o boletim
 
nomebol = NULL  
  if (geraPDF==TRUE){
    message("gerando PDF...")
    dirdoboletim = paste(dir.out,"boletins",sep="/")
    if(missing(tipo)) message("indique se o tipo = simples ou completo. Simples se for municipio isolado.")
    if(tipo == "completo") nomebol=geraPDF(tipo="municipal", obj = res, relatorio = relatorio, dir.boletim =dirdoboletim) 
    if(tipo == "simples") nomebol=geraPDF(tipo="municipalsimples", obj = res, relatorio = relatorio, dir.boletim = dirdoboletim)
  return(nomebol)
    }  else {
    return(res)
    }
  
}


## Relatorio do Rio de Janeiro ---------------------


configRelatorioRio<-function(alert, alertC, dirout, data, shape, datasource=con,  chik= FALSE, 
                             bdir=basedir, geraPDF=FALSE, inid = 201201){
  
  assert_that(inid < data, msg = "configRelatorioRio: check argument inid, it should be less
              than data_relatorio")
  
  # Dados da regional
 
  municip.reg <- getCidades(regional = "Metropolitana I",uf="Rio de Janeiro",datasource=con)$nome
  ano = floor(data/100)
  se = data - ano*100
  print(data)
  # Diretorio para salvar figs e tabs
 
  dirfigs = paste(bdir,dirout,"figs/",sep="/")
  print(dirfigs)
 
  # Mapa da Cidade : dengue
 
  nomemapario = paste(dirfigs, "mapaRio.png", sep="")
  message("nome do mapa:",nomemapario)
  map_Rio(alert, data=data, filename="mapaRio.png", dir=dirfigs, 
          shapefile = shape)
  
 
  # Mapa da Cidade: chik
 
  nomemaparioChik = paste(dirfigs, "mapaRioChik.png", sep="")
  message("nome do mapa:",nomemaparioChik)
  map_Rio(alertC, data=data, filename="mapaRioChik.png", dir=dirfigs, 
          shapefile = shape)
  
 
  # Dados da Cidade : dengue
 
  tres <- write_alertaRio(alert, write = "no") %>%
    filter(se > data) %>%   # esse filtro parece funcionar ao contrario , verificar 
    mutate(ano = floor(se/100),
           SE = se - 100*ano)
  
  # dados semanais
  totcrude <- aggregate(tres$casos,by=list(tres$se),sum)
  totest<-aggregate(tres$casos_est,by=list(tres$se),sum)
  totmin<-aggregate(tres$casos_estmin,by=list(tres$se),sum)
  totmax<-aggregate(tres$casos_estmax,by=list(tres$se),sum)
  
  # agregados anuais
  ano <- max(ano)
  anoprev <- ano - 1
  totanoprev <- sum(tres$casos[tres$ano == anoprev]) # total do ano anterior
  totanoprevse <- sum(tres$casos[(tres$ano == anoprev & tres$SE <=se)] ) # total do ano anterior até a semana equivalente do atual
  totano <- sum(tres$casos[tres$ano == ano]) # total do ano atual ate agora
  totanoult <- sum(tres$casos[tres$se == data]) # total da semana
  
  
  # Dados da Cidade : chik
 
  tresC <- write_alertaRio(alertC, write = "no") %>%
    filter(se > data) %>%
    mutate(ano = floor(se/100),
           SE = se - 100*ano)
  
  
  # semanais
  totcrudeC <- aggregate(tresC$casos,by=list(tresC$se),sum) # dados por semana
  totestC<-aggregate(tresC$casos_est,by=list(tresC$se),sum)
  totminC<-aggregate(tresC$casos_estmin,by=list(tresC$se),sum)
  totmaxC<-aggregate(tresC$casos_estmax,by=list(tresC$se),sum)
  
  # anuais
  totChikanoprev <- sum(tresC$casos[tresC$ano == anoprev]) # total de anoprev
  totChikanoprevse <- sum(tresC$casos[(tresC$ano == anoprev & tresC$SE <=se)]) # total de anoprev ate agora
  totChikano <- sum(tresC$casos[tresC$ano == ano]) # total de anoprev ate agora
  totChikanoult <- sum(tresC$casos[tresC$se == data]) # 
 
  # Grafico da cidade : dengue
 
  figname = paste(dirfigs,"figcidade.png",sep="")
  png(figname, width = 12, height = 16, units = "cm",res=200)
  
  cidade<-cbind(totcrude,totest$x,totmin$x,totmax$x)
  names(cidade)<-c("se","casos","casos.estimados","ICmin","ICmax")
  cidade$inc <- cidade$casos/6.5e6*100000
  dt<-subset(tres,aps=="1.0")[,c("se","tweets")]  # tweets
  dc <- aggregate(tres[,"tmin"],by=list(se=tres$se),FUN=mean,na.rm=TRUE) #clima
  names(dc)[2]<-"tmin"
  cidade<- merge(cidade,dt,by="se")
  cidade<- merge(cidade,dc,by="se")
  
  figuraRio(cidade)
  dev.off()
  
 
  # Grafico da cidade : chik
 
  fignameChik = paste(dirfigs,"figcidadeChik.png",sep="")
  png(fignameChik, width = 12, height = 8, units = "cm",res=200)
  
  cidadeC<-cbind(totcrudeC,totestC$x,totminC$x,totmaxC$x)
  names(cidadeC)<-c("se","casos","casos.estimados","ICmin","ICmax")
  cidadeC$inc <- cidadeC$casos/6.5e6*100000
  dt<-subset(tresC,aps=="1.0")[,c("se","tweets")]  # tweets
  dc <- aggregate(tresC[,"tmin"],by=list(se=tresC$se),FUN=mean,na.rm=TRUE) #clima
  names(dc)[2]<-"tmin"
  cidadeC<- merge(cidadeC,dt,by="se")
  cidadeC<- merge(cidadeC,dc,by="se")
  figuraRioChik(cidadeC)
  dev.off()
  

  # Grafico das APS : dengue

  
  ### grafico APS 1/2 
  png(paste(dirfigs,"figaps1.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  
  
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 1:5) {
    plot_alertaRio(alert,var="inc",ini=inid,fim=max(alert[[i]]$data$SE))
    mtext(names(alert)[i],line=-1, cex=0.7)
  }
  dev.off()
  
  ### grafico APS 2/2 
  png(paste(dirfigs,"figaps2.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 6:10) {
    plot_alertaRio(alert,var="inc",ini=inid,fim=max(alert[[i]]$data$SE))
    mtext(names(alert)[i],line=-1, cex=0.7)
  }
  dev.off()
  

  # Grafico das APS : chik

  ### grafico APS 1/2 
  png(paste(dirfigs,"figaps1Chik.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 1:5) {
    plot_alertaRio(alertC,var="inc",ini=inid,fim=max(alertC[[i]]$data$SE))
    mtext(names(alertC)[i],line=-1, cex=0.7)
  }
  dev.off()
  
  ### grafico APS 2/2 
  png(paste(dirfigs,"figaps2Chik.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 6:10) {
    plot_alertaRio(alertC,var="inc",ini=inid,fim=max(alertC[[i]]$data$SE))
    mtext(names(alertC)[i],line=-1, cex=0.7)
  }
  dev.off()
  
  
  # Gera e salva tabela da cidade
  
  nometab = paste(dirfigs,"tabelaRio.tex",sep="") 
  message("tabela", nometab, "salva")
  tabelax <-xtable(tail(cidade),align ="cc|ccccccc",digits = c(0,0,0,0,0,0,1,0,1))
  print(tabelax, type="latex", file=nometab, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  
  
  # Gera e salva tabelas das APS : dengue
  
  cores = c("verde","amarelo","laranja","vermelho")
  listaaps <- unique(tres$aps)
  
  for(ap in 1:10){
    tabapname = paste(dirfigs,"tabela",ap,".tex",sep="")
    tab<-tail(tres[tres$aps==listaaps[ap],c("se","casos","casos_est","tmin","rt","prt1","inc","nivel")],n=4)
    names(tab)[6]<-"pr(inc. subir)"
    tab$nivel<-cores[tab$nivel]
    
    tabelay <- xtable(tab,align="cc|ccccccc",digits = c(0,0,0,0,1,1,2,1,0))
    print(tabelay, type="latex", file=tabapname, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
 
  # Gera e salva tabelas das APS : chik
 
  for(ap in 1:10){
    tabapnameC = paste(dirfigs,"tabelaC",ap,".tex",sep="")
    tabC<-tail(tresC[tresC$aps==listaaps[ap],c("se","casos","casos_est","tmin","rt","prt1","inc","nivel")],n=4)
    names(tabC)[6]<-"pr(inc. subir)"
    tabC$nivel<-cores[tabC$nivel]
    
    tabelaCy <- xtable(tabC,align="cc|ccccccc",digits = c(0,0,0,0,1,1,2,1,0))
    print(tabelaCy, type="latex", file=tabapnameC, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
 
  # objeto que e' retornado pela funcao e lido pelo geraPDF (tambem e salvo como RData)
 
  res = list(nomecidade="Rio de Janeiro", estado="Rio de Janeiro", nomecidadeiconv = "RiodeJaneiro", 
             regionalmun="Metropolitana I", sigla = "RJ", se=se, ano=ano, anoprev = anoprev, alert=alert, alertC = alertC, 
             nomemapario = nomemapario,nomemaparioChik=nomemaparioChik,totChikanoprev=totChikanoprev, totChikano=totChikano,
             totChikanoult = totChikanoult,  totChikanoprevse = totChikanoprevse,
             totanoprev=totanoprev, totano=totano, totanoult = totanoult,  totanoprevse = totanoprevse,
             nometab = nometab, municip.reg=municip.reg, dirout=dirout, tabaps=tres, tabapsChik = tresC, datarel=data)
  
  message(paste("figura",figname,"salva. Objetos criados para o relatorio."))
  #save(res, file=fname)
  
  
  # salvando o boletim
  
  nomebol = NULL  
  if (geraPDF==TRUE){
    message("gerando PDF...")
    dirdoboletim = paste(dirout,"boletins",sep="/")
    nomebol=geraPDF(tipo="Rio", obj = res, dir.boletim = dirdoboletim)
  } 
  
  nomebol
  
}



## FUN geraPDF -------------------

# executa o Sweave com o Rnw selecionado (municipal, regional, estadual) alimentado com os objetos gerados
# pelo alerta encapsulados em obj 
# obj - lista gerada pelo configRelatorioMunicipal (por enquanto)
# tipo = um de "municipal", "regional", "estadual"
# dir.report = diretorio onde esta a pasta report


geraPDF<-function(tipo, obj, dir.boletim, data = data_relatorio, dir.report="AlertaDengueAnalise/report", relatorio = "infodengue",
                  bdir = basedir){  
  message(paste("Criando PDF", relatorio))

  # Identifica o .Rnw a ser executado e onde pdf vai ser salvo

  dir.rnw = paste(bdir,dir.report,"reportconfig",sep="/")
  setwd(dir.rnw)
  
  dirboletim = paste(bdir,dir.boletim,sep="/")
  
  checkDirectory(dirboletim) # if directory does not exist, creates one
  
  # tipo = municipal, regional, estadual
  if(tipo == "municipal") {
    rnwfile = "BoletimMunicipal_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-mn-",obj$nomecidadeiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "municipalsimples") {
    if(relatorio == "infodengue") rnwfile = "BoletimMunicipalSimples_InfoDengue.Rnw"
    if(relatorio == "infoarbo") rnwfile = "BoletimMunicipalSimples_InfoArbo.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-mn-",obj$nomecidadeiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "regional") {
    rnwfile = "BoletimRegional_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-RS-",obj$nomeregiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "regionalsimples") {
    rnwfile = "BoletimRegionalSimples_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-RS-",obj$nomeregiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "Estadual") {
    rnwfile = "BoletimEstadual_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/E",obj$sigla,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "Rio"){
    rnwfile = "BoletimRio_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-mn-",obj$nomecidadeiconv,"-",Sys.Date(),".pdf",sep="")
  }
  print(paste("usando template", rnwfile))
 
  # Cria Ambiente com objetos para o relatorio
 
  env <<- new.env() # ambiente que vai ser usado no relatorio, imprescindivel para o sweave funcionar
  
 
  # Carrega parametros estaduais que todos os relatorios usam, exceto os simples
 
  if(tipo!="municipalsimples"&tipo!="regionalsimples"){
    # PS. Guardar inicialmente esses parametros no ambiente envUF, porque nem todos vao para os municipios
    envUF <- new.env() # ambiente para guardar todos os objetos do estado
    dir.estado = paste(bdir,"AlertaDengueAnalise/report",obj$sigla,"figs/",sep="/") # diretorio da UF
    load(paste(dir.estado,"params",obj$sigla,".RData",sep=""),envir = envUF) # carrega dados da UF
    
    env$figmapaestado = paste(dir.estado,"Mapa_E",obj$sigla,".png", sep="") # mapa estadual
    
  
    # Alimenta env com parametros estaduais que serao (eventualmente) usados
 
    env$estado <- envUF$res$estado  # nome do estado
    env$regionaisUF <- envUF$res$regs # lista de regionais
  
 # dengue
    env$totanoUF <- envUF$res$totano  # total de casos no ano
    env$totultseUF <- envUF$res$totultse  # total de casos na ultima semana
    #env$figmapaestado <- envUF$res$figmapaestado
    env$nmunicipios <- envUF$res$nmunicipios # n. municipios no estado
    env$nverdeUF <- envUF$res$nverde  # numero de municipios verdes na ultima semana
    env$namareloUF <- envUF$res$namarelo
    env$nlaranjaUF <- envUF$res$nlaranja
    env$nvermelhoUF <- envUF$res$nvermelho
    env$namarelo1UF <- envUF$res$namarelo1  # numero de munic. amarelos na semana anterior
    env$nlaranja1UF <- envUF$res$nlaranja1
    env$nvermelho1UF <- envUF$res$nvermelho1
    env$seUF <- envUF$res$se # ultima semana em que rodou o alerta estadual
    env$anoUF <- envUF$res$ano # ano em que rodou o alerta estadual
    env$tabelao <- envUF$res$tabelao  # tabela com alertas municipais (todos os municipios da UF)
    
    
    # alimenta env com parametros especifiocs do relatorio estadual
    if (tipo =="Estadual"){
      env$nickregs <- obj$nickregs
      env$regionais <- obj$regional
      env$nomesmapareg <- obj$nomemapareg
      env$nomestabreg <- obj$nomestabreg
      env$nomesfigreg <- obj$nomesfigreg
      env$nometabelao <- obj$nometabelao
      env$municipios <- obj$municipios
      env$somasregionais <- obj$tabelasomatorios
      
    }
    
    # alimenta env com os parametros da Regional de Saude (if regional) 
 
    
    if(tipo == "regional"){
      env$regional <- obj$regional  
      env$se <- obj$se
      env$ano <- obj$ano
      env$mapareg <- obj$nomemapareg
      env$tabreg <- obj$nometabreg
      env$figreg <- obj$figreg 
      env$municipiosRS <- obj$municipios
      env$nmunicipiosRS <- obj$nmunicipios
      env$nometabelaoRS <- obj$nometabelao
      env$tabelaoRS <- obj$tabelao
      env$nomemunfigurasRS <- obj$nomemunfiguras
      env$totanoRS <- obj$totano
      env$totultseRS <- obj$totultse
      env$nverdeRS <- obj$nverde 
      env$namareloRS <- obj$namarelo
      env$nlaranjaRS <- obj$nlaranja
      env$nvermelhoRS <- obj$nvermelho
      env$namarelo1RS <- obj$namarelo1
      env$nlaranja1RS <- obj$nlaranja1
      env$nvermelho1RS <- obj$nvermelho1
      
    }
    
    # alimenta env com os parametros municipais (if municipal completo) 
 
    print(obj$tabnameC)
    if(tipo == "municipal"){
      env$se <- obj$se
      env$ano <- obj$ano
      env$nomecidade <- obj$nomecidade
      # --- dengue 
      env$totanomun <- obj$totanomun   # total de casos no ano no municipio
      env$totultsemun <-obj$totultsemun # casos na ultima semana
      env$nivelmun <- obj$nivelmun # nivel atual
      env$figmunicipio <- obj$figname  # Figura do alerta municipal
      env$tabmun <- obj$nometabmun
      print("dengue")
      print(obj$tabname)
      print(env$tabmun)
      # ---- chik 
      if (relatorio == "infoarbo"){
        # chik
        env$totanomunC <- obj$totanomunC   # total de casos no ano no municipio
        env$totultsemunC <-obj$totultsemunC # casos na ultima semana
        env$nivelmunC <- obj$nivelmunC # nivel atual
        env$figmunicipioC <- obj$fignameC  # Figura do alerta municipal
        env$tabmunC <- obj$tabnameC
        print("chik")
        print(env$tabmunC)
        # zika
        env$totanomunZ <- obj$totanomunZ   # total de casos no ano no municipio
        env$totultsemunZ <-obj$totultsemunZ # casos na ultima semana
        env$nivelmunZ <- obj$nivelmunZ # nivel atual
        env$figmunicipioZ <- obj$fignameZ  # Figura do alerta municipal
        env$tabmunZ <- obj$tabnameZ
    
        
      }      
      
      # Dados da regional a que ele pertence
      env$regionalmun <- obj$regionalmun # nome da regional
      env$linkregional <- as.character(envUF$nickregs[[env$regionalmun]]) # nickname da regional para usar como link
      env$municip.reg <- obj$municip.reg # municipios na mesma regional 
      
      # Mapa da regional 
      regsemespaco = gsub(' ','', env$regionalmun)
      regsemacento = iconv(regsemespaco, to = 'ASCII//TRANSLIT')
      env$mapareg=paste(dir.estado,"Mapa",obj$sigla,"_",regsemacento,'.png',sep='') # mapa
      env$tabreg=paste(dir.estado,'tabregional_',regsemacento, '.tex',sep='') #tabela
    }
  }
  
 
  # Caso especifico do municipal simples, que nao tem dados de estadual ou regional
 
  if(tipo == "municipalsimples"){
    env$ano <- obj$ano
    env$se <- obj$se
    env$estado <- obj$estado
    env$sigla <- obj$sigla
    env$nomecidade <- obj$nomecidade
    # --- dengue 
    env$totanomun <- obj$totanomun   # total de casos no ano no municipio
    env$totultsemun <-obj$totultsemun # casos na ultima semana
    env$nivelmun <- obj$nivelmun # nivel atual
    env$figmunicipio <- obj$figname  # Figura do alerta municipal
    env$tabmun <- obj$nometabmun
    # ---- chik 
    if (relatorio == "infoarbo"){
      env$totanomunC <- obj$totanomunC   # total de casos no ano no municipio
      env$totultsemunC <-obj$totultsemunC # casos na ultima semana
      env$nivelmunC <- obj$nivelmunC # nivel atual
      env$figmunicipioC <- obj$fignameC  # Figura do alerta municipal
      env$tabmunC <- obj$tabnameC
      
      env$totanomunZ <- obj$totanomunZ   # total de casos no ano no municipio
      env$totultsemunZ <-obj$totultsemunZ # casos na ultima semana
      env$nivelmunZ <- obj$nivelmunZ # nivel atual
      env$figmunicipioZ <- obj$fignameZ  # Figura do alerta municipal
      env$tabmunZ <- obj$tabnameZ
      
    }   
    
    
  }
  
 
  # caso especifico em que a regional esta sozinha
 
  
  if(tipo == "regionalsimples"){
    env$regional <- obj$regional  
    env$se <- obj$se
    env$ano <- obj$ano
    env$mapareg <- obj$nomemapareg
    env$tabreg <- obj$nometabreg
    env$figreg <- obj$figreg
    env$municipiosRS <- obj$municipios
    env$nmunicipiosRS <- obj$nmunicipios
    env$nometabelaoRS <- obj$nometabelao
    env$tabelaoRS <- obj$tabelao
    env$nomemunfigurasRS <- obj$nomemunfiguras
    env$totanoRS <- obj$totano
    env$totultseRS <- obj$totultse
    env$nverdeRS <- obj$nverde 
    env$namareloRS <- obj$namarelo
    env$nlaranjaRS <- obj$nlaranja
    env$nvermelhoRS <- obj$nvermelho
    env$namarelo1RS <- obj$namarelo1
    env$nlaranja1RS <- obj$nlaranja1
    env$nvermelho1RS <- obj$nvermelho1
  }
    
   # Rio de Janeiro
 
  if(tipo == "Rio"){
    env$se <- obj$se
    env$ano <- obj$ano
    env$anoprev <- obj$anoprev
    env$datarel <- obj$datarel
    dir.estadoRIO = paste(bdir,"AlertaDengueAnalise/report/RJ/figs/")
    # objetos da regional
    load(paste(dir.estado,"/paramsRJ.RData",sep=""),envir = envUF)
    
    # Dados da regional a que ele pertence
    env$regionalmun <- "Metropolitana I" # nome da regional
    env$linkregional <- "MetI" # nickname da regional para usar como link
    env$municip.reg <-  obj$municip.reg # municipios na mesma regional
    env$nmunicipiosRS <- length(env$municip.reg)
    env$tabelaoRS <- envUF$res$tabelao[envUF$res$tabelao$Regional=="Metropolitana I",]
    
    # Mapa da regional 
    env$mapareg=paste(dir.estado,"/MapaRJ_MetropolitanaI.png",sep='') # mapa
    env$tabreg=paste(dir.estado,"/tabregional_MetropolitanaI.tex",sep='') #tabela
    
    # Objetos da Cidade
    env$nomemapario <- obj$nomemapario # mapa de dengue
    env$nomemaparioChik <- obj$nomemaparioChik # mapa de chik
    env$tabelaRio <- obj$nometab # dengue
    env$totanoprev <- obj$totanoprev # dengue
    env$totanoprevse <- obj$totanoprevse # dengue em anoprev, ate a semana epide do relatorio
    env$totano <- obj$totano # dengue em ano
    env$totanoult <- obj$totanoult # dengue em ano na ultima semana
    env$totChikanoprev <- obj$totChikanoprev  # mesmo para chik
    env$totChikanoprevse <- obj$totChikanoprevse # idem
    env$totChikano <- obj$totChikano # idem
    env$totChikanoult <- obj$totChikanoult # idem
    env$tabaps = obj$tabaps 
    env$tabapsChik = obj$tabapsChik
    dirfigs <- paste(bdir,obj$dirout,"figs",sep="/")
    env$figcidade <- paste(dirfigs,"/figcidade.png",sep="")
    env$figcidadeChik <- paste(dirfigs,"/figcidadeChik.png",sep="")
    env$figaps1 <- paste(dirfigs,"/figaps1.png",sep="")
    env$figaps2 <- paste(dirfigs,"/figaps2.png",sep="")
    env$figaps1Chik <- paste(dirfigs,"/figaps1Chik.png",sep="")
    env$figaps2Chik <- paste(dirfigs,"/figaps2Chik.png",sep="")
    # tabelas APS dengue
    env$tabela1 <- paste(dirfigs,"/tabela",1,".tex",sep="")
    env$tabela2 <- paste(dirfigs,"/tabela",2,".tex",sep="")
    env$tabela3 <- paste(dirfigs,"/tabela",3,".tex",sep="")
    env$tabela4 <- paste(dirfigs,"/tabela",4,".tex",sep="")
    env$tabela5 <- paste(dirfigs,"/tabela",5,".tex",sep="")
    env$tabela6 <- paste(dirfigs,"/tabela",6,".tex",sep="")
    env$tabela7 <- paste(dirfigs,"/tabela",7,".tex",sep="")
    env$tabela8 <- paste(dirfigs,"/tabela",8,".tex",sep="")
    env$tabela9 <- paste(dirfigs,"/tabela",9,".tex",sep="")
    env$tabela10<- paste(dirfigs,"/tabela",10,".tex",sep="")
    
    # tabelas APS chik
    env$tabelaC1 <- paste(dirfigs,"/tabelaC",1,".tex",sep="")
    env$tabelaC2 <- paste(dirfigs,"/tabelaC",2,".tex",sep="")
    env$tabelaC3 <- paste(dirfigs,"/tabelaC",3,".tex",sep="")
    env$tabelaC4 <- paste(dirfigs,"/tabelaC",4,".tex",sep="")
    env$tabelaC5 <- paste(dirfigs,"/tabelaC",5,".tex",sep="")
    env$tabelaC6 <- paste(dirfigs,"/tabelaC",6,".tex",sep="")
    env$tabelaC7 <- paste(dirfigs,"/tabelaC",7,".tex",sep="")
    env$tabelaC8 <- paste(dirfigs,"/tabelaC",8,".tex",sep="")
    env$tabelaC9 <- paste(dirfigs,"/tabelaC",9,".tex",sep="")
    env$tabelaC10<- paste(dirfigs,"/tabelaC",10,".tex",sep="")
    
  }
  
  require(tools)  
  #env <<- environment() # necessario para o Sweave ler os objetos criados na funcao
  Sweave(paste(dir.rnw,"/",rnwfile,sep=""))
  
  # identifica o nome do arquivo tex gerado
  texfile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".tex",sep="")
  texi2dvi(file = texfile, pdf = TRUE, quiet=TRUE, clean=TRUE) # tex -> pdf 
  pdffile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".pdf",sep="") # nome do pdf
  system(paste("mv", pdffile, nomeboletim))
  system(paste("rm", texfile))
  system("rm *concordance.tex")
  message(paste(nomeboletim, "created"))
  
  setwd(bdir)
  remove(list=ls(),envir = env)
  return(nomeboletim)
  }




## publicarAlerta ------------------

publicarAlerta <- function(ale, pdf, dir, bdir = basedir, writebd = TRUE){
  # A função write_alerta sabe se e para salvar na tabela de chik ou de dengue

  if(writebd)  message("atualizando a tabela do historico...")
  
  # Se é cidade do Rio ou outros 
    if("APS 1" %in% names(ale)) {
      restab  <- ifelse(writebd, write_alertaRio(ale, write = "db"),
                        write_alertaRio(ale, write = "no"))
        }else{
          restab <- tabela_historico(ale)
          if(writebd) restab <- write_alerta(restab) 
          }
        

  message("Copia o boletim para a pagina do site...")
  strip <- strsplit(pdf,"/")[[1]]
  nomeb = strip[length(strip)] # nome do boletim
  bolpath <- paste(bdir,dir,nomeb,sep="/") # boletim com path completo
  comando <- paste ("cp", pdf, bolpath) 
  print(comando)
  system(comando) 
}
