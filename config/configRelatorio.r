# ========================================================
# Configuracao para os boletins do Alerta
# ========================================================

configRelatorio <- function(uf, regional, sigla, data, alert, pars, shape, varid, dir, datasource){
  
  dirfigs = paste(basedir,dir,sep="/") 
  # ------------
  ## Estado, suas regionais e municipios
  # ------------
  estado = uf
  sigla = sigla
  municipios = getCidades(uf=estado,datasource=con)
  nmunicipios = dim(municipios)[1]
  regs = getRegionais(uf = estado) 
  nickregs = abbreviate(iconv(regs, to = "ASCII//TRANSLIT"))
  nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  
  # -----------
  ## As datas
  # -----------
  ano = floor(data/100)
  se = data - ano*100 
  
  # ----------------------------------------------- 
  # Mapa do estado (funcao basica do alerttools)
  # -----------------------------------------------
  if(missing(regional)){ # se for estadual
    geraMapa(alerta=alert, se=data, shapefile = shape,   
             varid=varid, titulo="", 
             filename=paste("Mapa_E", sigla,".png", sep=""),
             dir=dirfigs, caption=FALSE)
  }    
  
  # -----------------------------------------------
  # Mapas de todas as Regionais (funcao customizada, no codigoFiguras.R)
  # -----------------------------------------------
  if(missing(regional)){ # se for estadual, faz para todas as RS
  mapa.regional(alerta=alert, regionais=regs, estado = uf, sigla = sigla,
                data = data, pars=pars, shape=shape, shapeid=varid, dir=dirfigs ,
                datasource=datasource)}
  else{ # faz so para a regional em questao
      mapa.regional(alerta=alert, regionais=regional, estado = uf, sigla = sigla,
                    data = data, pars=pars, shape=shape, shapeid=varid, dir=dirfigs ,
                    datasource=datasource)
    }
  
  # ------------------------    
  # Tabelao com resultado do alerta por municipio e totais 
  # ------------------------
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
    paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                              Regional = as.character(ai$data$nome_regional[1]),
                              Temperatura = ai$data$temp_min[linhase],
                              Tweets = ai$data$tweet[linhase],
                              Casos = ai$data$casos[linhase], 
                              Incidencia=ai$data$inc[linhase],
                              Rt=ai$data$Rt[linhase],
                              Nivel=as.character(cores[ai$indices$level[linhase]]),
                              stringsAsFactors = FALSE)
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
      
  # --------------------------------
  # Gera e salva tabelas regionais (xtable)
  # --------------------------------
      
  for (k in regs) {
    cidades = getCidades(regional = k, uf = estado, datasource = datasource)
    cidadessemespaco = gsub(" ","",cidades$nome)
    linhascidades <- which(names(alert) %in% cidadessemespaco)
    N = length(linhascidades)
    
    tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                    "tcasesICmin","tcasesmed","tcasesICmax")])
    
    for (n in 2:N){
      
      newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                         "tcasesICmin","tcasesmed","tcasesICmax")])
      tabela[,2:8] <- tabela[,2:8]+newtabela[,2:8]
    }
    
    tabela$temp_min <- tabela$temp_min/N   #media das temperaturas 
    tabela$inc <- tabela$casos/tabela$pop*100000
    
    tabelafinal <- tail(tabela[,c("SE","temp_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
    names(tabelafinal)<-c("SE","temperatura","tweet","casos notif","casos preditos","ICmin","ICmax","incidência")
    
    nomesemespaco = gsub(" ","",k)
    nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
    fname = paste(dirfigs,"/","tabregional",sigla,"_",nomesemacento,".tex",sep="")
    
    tabelax <-xtable(tabelafinal,align ="cc|ccccccc",digits = 0,size="\\small")
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
    
    # --- fim das tabelas regionais
    
    # --------------------------------
    # Figuras-resumo das regionais 
    # --------------------------------
            
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



configRelatorioRegional <- function(uf, regional, sigla, data, alert, pars, shape, varid, dir, datasource, dirb=basedir,geraPDF=TRUE){
  
  # ------------
  ## Dados da regional
  # ------------
  estado = uf
  sigla = sigla
  municipios = getCidades(uf=estado, regional = regional, datasource=datasource)
  nmunicipios = dim(municipios)[1]
  nomeregfiguras = iconv(gsub(" ","",regional),to = "ASCII//TRANSLIT")
  nomemunfiguras = iconv(gsub(" ","",municipios$nome),to = "ASCII//TRANSLIT")
  nickreg = abbreviate(iconv(regional, to = "ASCII//TRANSLIT"))
  municipios$nickmun = abbreviate(iconv(municipios$nome, to = "ASCII//TRANSLIT"))
  
  # -----------
  ## As datas
  # -----------
  ano = floor(data/100)
  se = data - ano*100 
  
  # ----------------
  # Mapa da Regional
  # ----------------
  dirfigs = paste(basedir,dir,"figs/",sep="/")
  
  nomemapareg=mapa.regional(alerta=alert, regionais=regional, estado = uf, sigla = sigla,
                  data = data, pars=pars, shape=shape, shapeid=varid, dir=dirfigs ,
                  datasource=datasource)
  
  # ------------------------    
  # Tabelao com resultado do alerta por municipio da Regional e totais 
  # ------------------------
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
    paratabelao <- data.frame(Municipio = as.character(ai$data$nome[1]), 
                              Regional = as.character(ai$data$nome_regional[1]),
                              Temperatura = ai$data$temp_min[linhase],
                              Tweets = ai$data$tweet[linhase],
                              Casos = ai$data$casos[linhase], 
                              Incidencia=ai$data$inc[linhase],
                              Rt=ai$data$Rt[linhase],
                              Nivel=as.character(cores[ai$indices$level[linhase]]),
                              stringsAsFactors = FALSE)
    tabelao[i,] = paratabelao
    
  }
  
  nometabelao = paste(dirfigs,"/","tabelaoMun_",nomeregfiguras,".tex",sep="")
  tabelaox <-xtable(tabelao, align ="ll|lllllll")
  digits(tabelaox) <- c(0,0,0,1,0,0,1,1,0)
  
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
  # -------- fim do tabelao
  
  # --------------------------------
  # tabela resumo da Regional (xtable)
  # --------------------------------
  
  cidadessemespaco = gsub(" ","",municipios$nome)
  linhascidades <- which(names(alert) %in% cidadessemespaco)
  
  tabela = tail(alert[[linhascidades[1]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                    "tcasesICmin","tcasesmed","tcasesICmax")])
  for (n in 2:nmunicipios){
    
    newtabela = tail(alert[[linhascidades[n]]]$data[,c("SE","casos","pop","tweet","temp_min",
                                                         "tcasesICmin","tcasesmed","tcasesICmax")])
      tabela[,2:8] <- tabela[,2:8]+newtabela[,2:8]
    }
  tabela$temp_min <- tabela$temp_min/nmunicipios   #media das temperaturas 
  tabela$inc <- tabela$casos/tabela$pop*100000
  tabelafinal <- tail(tabela[,c("SE","temp_min","tweet","casos","tcasesmed","tcasesICmin","tcasesICmax","inc")])
  names(tabelafinal)<-c("SE","temperatura","tweet","casos notif","casos preditos","ICmin","ICmax","incidência")
    
  nometabreg = paste(dirfigs,"/","tabregional_",nomeregfiguras,".tex",sep="")
    
  tabelax <-xtable(tabelafinal,align ="cc|ccccccc",digits = 0,size="\\small")
  digits(tabelax) <- 0
  print(tabelax, type="latex", file=nometabreg, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
    
    # --- fim das tabelas regionais
    
    # --------------------------------
    # Figura-resumo da regional 
    # --------------------------------
    
    res = write.alerta(alert[[1]])
    for (n in 2:nmunicipios) res = rbind(res, write.alerta(alert[[n]]))
    
    serie = aggregate(cbind(tweet,casos)~data_iniSE,data=res,FUN=sum,na.rm=TRUE)
    
    figname = paste(dirfigs,"figuraRS_",nomeregfiguras,".png",sep="")
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
    dev.off()
    
        
  filename = paste(dirfigs,"paramsRS_",nomeregfiguras,".RData",sep="")
  
  # ----- fim da figura-resumo da Regional
  
  # --------------------------------
  # Figuras dos municipios da Regional (3 subfiguras)
  # --------------------------------
  municipios$figname <- "NA"
  for(cid in 1:nmunicipios){ 
    cidadessemespaco = gsub(" ","",municipios$nome[cid])
    figname = paste(dirfigs,"figMun_",nomemunfiguras[cid],".png",sep="")
  
    png(figname, width = 14, height = 16, units="cm", res=300)  # inicio da figura -----
    figuramunicipio(alert[[cidadessemespaco]])
    municipios$figname[cid] <- figname
    dev.off()  
  }# fim da figura ----------
  
  # --------------------------------
  # Tabelas dos municipios da Regional 
  # --------------------------------
  municipios$tabname <- "NA"
  varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesICmax","p1")
  
  for(cid in 1:nmunicipios){ 
    tab <- tail(alert[[cid]]$data[,varstab])
    tab$p1 <- tab$p1*100
    names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "incidência max","pr(aumento)")
    municipios$tabnome[cid] <- paste(dirfigs,"tabelaMun_",nomemunfiguras[cid],".tex",sep="")
    tabelax <-xtable(tab,align ="cc|cccccc",digits = 0)
    digits(tabelax) <- 0
    print(tabelax, type="latex", file=municipios$tabnome[cid], floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
  
  res = list(estado=estado, sigla=sigla, se=se, ano=ano, municipios=municipios,
             nmunicipios=nmunicipios, regional=regional,nomeregiconv=nomeregfiguras, 
             nomemuniconv=nomemunfiguras, totano=totano, nickreg=nickreg,
             totultse=totultse, tabelao=tabelao, nverde=nverde, namarelo=namarelo,
             nlaranja=nlaranja, nvermelho=nvermelho, nverde1=nverde1, namarelo1=namarelo1, 
             nlaranja1=nlaranja1, nvermelho1=nvermelho1, data_relatorio=data, dir=filename,
             nomemapareg = nomemapareg, nometabreg = nometabreg, nometabelao = nometabelao,
             tabelao = tabelao)
  
  if (geraPDF==TRUE){
    message("gerando PDF...")
    geraPDF(tipo="regional", obj = res, dir.boletim = paste(dir,"boletins",sep="/"))
  } 
  
  #message(paste("salvando RData em",filename))
  #save(estado, sigla, se, ano, municipios, nmunicipios, regional,nickreg, totano, totultse, tabelao, nverde, namarelo, nlaranja, nvermelho, nverde1, namarelo1, nlaranja1, nvermelho1, data,
  #     file=filename)
  res
}


## -----------------------------------------------
## FUN configRelatorioMunicipal

# gera objetos necessarios para o boletim Municipal
# alert - objeto gerado pelo update.alerta, siglaUF = "RJ", dir.out = pasta mestre do municipio,
# data - data do relatorio

configRelatorioMunicipal <- function(alert, siglaUF, dir.out, data, datasource=con,
                                     dirb=basedir,geraPDF=TRUE){
  
  # Identificacao da cidade
  nomecidade = alert$data$nome[1]
  geocodigo = alert$data$cidade[1]
  estado = as.character(dbGetQuery(datasource, paste("SELECT uf 
                                             FROM \"Dengue_global\".\"Municipio\" 
                                             where geocodigo = ", geocodigo, sep="")))
  
  # Identificacao da regional a qual ela pertence
  regionalmun = as.character(dbGetQuery(datasource, paste("SELECT nome_regional 
                                             FROM \"Dengue_global\".regional_saude 
                                             where municipio_geocodigo = ", geocodigo, sep="")))   
  # relacao dos municipios na mesma reg
  municip.reg <- getCidades(uf=estado,regional = regionalmun, datasource=datasource)
  
  # Data do relatorio
  ano = floor(data/100)
  se = data - ano*100 
  linhasdoano = which(floor(alert$data$SE/100)==ano) # posicao do dataframe para essa data
  linhase = which(alert$data$SE==data)
  linhase1 = which(alert$data$SE==data)-1 # posicao referente a semana anterior
  
  # Total de casos no municipio nas ultimas 2 semanas
  totanomun = sum(alert$data$casos[linhasdoano],na.rm=TRUE)
  totultsemun = alert$data$casos[linhase]
  
  # Cor do alerta na ultima semana
  cores = c("verde","amarelo","laranja","vermelho")
  nivelmun = cores[alert$indices$level[linhase] ]  
  
  # Gera nome do arquivo de saida paramsNomedaCidade.RData
  nomesemespaco = gsub(" ","",nomecidade)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  fname = paste(dir.out,"/figs/params",nomesemacento,".RData",sep="")
  
  # Gera figura chamada figuraNomedaCidade.png com 3 subfiguras
  figname = paste(dirb,"/",dir.out,"/figs/figura",nomesemacento,".png",sep="")
  
  png(figname, width = 14, height = 16, units="cm", res=300)  # inicio da figura -----
  figuramunicipio(alert)
  dev.off()  # fim da figura ----------
  
  # Gera tabela resumo das ultimas semanas
  varstab <- c("SE","temp_min","tweet", "casos", "inc", "tcasesICmax","p1")
  tab <- tail(alert$data[,varstab])
  tab$p1 <- tab$p1*100
  names(tab) <- c("SE","temperatura","tweet", "casos notif", "incidência", "incidência max","pr(aumento)")
  tabname <- paste(dirb,"/",dir.out,"/figs/tabela",nomesemacento,".tex",sep="")
  tabelax <-xtable(tab,align ="cc|cccccc",digits = 0)
  digits(tabelax) <- 0
  print(tabelax, type="latex", file=tabname, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  
  # objeto que e' retornado pela funcao e lido pelo geraPDF (tambem e salvo como RData)
  res = list(nomecidade=nomecidade, estado=estado, nomecidadeiconv = nomesemacento, regionalmun=regionalmun, sigla = siglaUF, alert=alert, totanomun=totanomun,
             totultsemun=totultsemun, nivelmun=nivelmun, se=se, ano=ano, data=data, figname=figname, dir.out = dir.out,
             municip.reg=municip.reg,nometabmun=tabname)
    
  message(paste("figura",figname,"salva. Objetos criados para o relatorio."))
  save(res, file=fname)
  res
  }


## -----------------------------------------------
## FUN geraPDF

# executa o Sweave com o Rnw selecionado (municipal, regional, estadual) alimentado com os objetos gerados
# pelo alerta encapsulados em obj 
# obj - lista gerada pelo configRelatorioMunicipal (por enquanto)
# tipo = um de "municipal", "regional", "estadual"
# dir.report = diretorio onde esta a pasta report


geraPDF<-function(tipo, obj, dir.boletim, dir.report="AlertaDengueAnalise/report",
                  bdir = basedir){  
  
  # -----------------------------------
  # Identifica o .Rnw a ser executado e onde pdf vai ser salvo
  # -----------------------------------
  dir.rnw = paste(bdir,dir.report,"reportconfig",sep="/")
  setwd(dir.rnw)
  
  # tipo = municipal, regional, estadual
  if(tipo == "municipal") {
    rnwfile = "BoletimMunicipal_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-mn-",obj$nomecidadeiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "regional") {
    rnwfile = "BoletimRegional_InfoDengue.Rnw"
    nomeboletim = paste(bdir,"/",dir.boletim, "/",obj$sigla,"-RS-",obj$nomeregiconv,"-",Sys.Date(),".pdf",sep="")
  }
  if(tipo == "estadual") {
    rnwfile = "BoletimEstadual_InfoDengue_v01.Rnw"
    nomeboletim = paste(dir.boletim, "/E",obj$sigla,"-",Sys.Date(),".pdf",sep="")
  }
  
  #-------------------------
  # Carrega parametros estaduais (todos os relatorios usam)
  # -------------------------
  # PS. Guardar inicialmente esses parametros no ambiente envUF, porque nem todos vao para os municipios
  envUF <- new.env() # ambiente para guardar todos os objetos do estado
  dir.estado = paste(bdir,dir.report,obj$sigla,"figs",sep="/") # diretorio da UF
  load(paste(dir.estado,"/params",obj$sigla,".RData",sep=""),envir = envUF) # carrega dados da UF 
  envUF$figmapaestado = paste(dir.estado,"/Mapa_E",obj$sigla,".png", sep="") # mapa estadual
  
  # -------------------------------------------
  # Cria Ambiente com objetos para o relatorio
  # -------------------------------------------
  env <<- new.env() # ambiente que vai ser usado no relatorio, imprescindivel para o sweave funcionar

  # Alimenta env com parametros estaduais que serao (eventualmente) usados
  # ------------------------------------------------------
  env$estado <- envUF$estado  # nome do estado
  env$regionaisUF <- envUF$regs # lista de regionais
  env$totanoUF <- envUF$totano  # total de casos no ano
  env$totultseUF <- envUF$totultse  # total de casos na ultima semana
  env$figmapaestado <- envUF$figmapaestado
  env$nmunicipios <- envUF$nmunicipios # n. municipios no estado
  env$nverdeUF <- envUF$nverde  # numero de municipios verdes na ultima semana
  env$namareloUF <- envUF$namarelo
  env$nlaranjaUF <- envUF$nlaranja
  env$nvermelhoUF <- envUF$nvermelho
  env$namarelo1UF <- envUF$namarelo1  # numero de munic. amarelos na semana anterior
  env$nlaranja1UF <- envUF$nlaranja1
  env$nvermelho1UF <- envUF$nvermelho1
  env$seUF <- envUF$se # ultima semana em que rodou o alerta estadual
  env$anoUF <- envUF$ano # ano em que rodou o alerta estadual
  env$tabelao <- envUF$tabelao  # tabela com alertas municipais (todos os municipios da UF)
  
  # alimenta env com os parametros da Regional de Saude (if regional) 
  # ---------------------------------------------------------
  if(tipo == "regional"){
  env$regional <- obj$regional  
  env$se <- obj$se
  env$ano <- obj$ano
  env$mapareg <- obj$nomemapareg
  env$tabreg <- obj$nometabreg
  env$municipiosRS <- obj$municipios
  env$nmunicipiosRS <- obj$nmunicipios
  env$nometabelaoRS <- obj$nometabelao
  env$tabelaoRS <- obj$tabelao
  env$nomemunfigurasRS <- obj$nomemunfiguras
    
    
  }
  
  # alimenta env com os parametros municipais (if municipal) 
  # ---------------------------------------------------------
  if(tipo == "municipal"){
    env$nomecidade <- obj$nomecidade
    env$totanomun <- obj$totanomun   # total de casos no ano no municipio
    env$totultsemun <-obj$totultsemun # casos na ultima semana
    env$nivelmun <- obj$nivelmun # nivel atual
    env$figmunicipio <- obj$figname  # Figura do alerta municipal
    env$tabmun <- obj$nometabmun
    
    # Dados da regional a que ele pertence
    env$regionalmun <- obj$regionalmun # nome da regional
    env$linkregional <- as.character(envUF$nickregs[[env$regionalmun]]) # nickname da regional para usar como link
    env$municip.reg <- obj$municip.reg # municipios na mesma regional 
    
   # Mapa da regional 
    regsemespaco = gsub(' ','', env$regionalmun)
    regsemacento = iconv(regsemespaco, to = 'ASCII//TRANSLIT')
    env$mapareg=paste(dir.estado,"/Mapa",obj$sigla,"_",regsemacento,'.png',sep='') # mapa
    env$tabreg=paste(dir.estado,'/tabregional',obj$sigla,'_',regsemacento, '.tex',sep='') #tabela
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
  }





configRelatorioRio<-function(alert, tres, dir, datasource=con, data, dirout){
  
  map.Rio(alerio, data=data_relatorio, filename="mapaRio.png", dir=dirout, shapefile = "AlertaDengueAnalise/report/Rio_de_Janeiro/shape/CAPS_SMS.shp")
  
  totcrude <- aggregate(tres$casos,by=list(tres$se),sum)
  totest<-aggregate(tres$casos_est,by=list(tres$se),sum)
  totmin<-aggregate(tres$casos_est_min,by=list(tres$se),sum)
  totmax<-aggregate(tres$casos_est_max,by=list(tres$se),sum)
  
  # Grafico da cidade ------------------------
  cidade<-cbind(totcrude,totest$x,totmin$x,totmax$x)
  names(cidade)<-c("se","casos","casos.estimados","ICmin","ICmax")
  cidade$inc <- cidade$casos/6.5e6*100000
  dt<-subset(tres,aps=="1.0")[,c("se","tweet")]  # tweets
  dc <- aggregate(tres[,"tmin"],by=list(se=tres$se),FUN=mean,na.rm=TRUE) #clima
  names(dc)[2]<-"tmin"
  cidade<- merge(cidade,dt,by="se")
  cidade<- merge(cidade,dc,by="se")
  cidade <- subset(cidade,se>=201101)
  ymax <- max(110,max(cidade$inc))
  
  png(paste(dirout,"figcidade.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  par(mfrow=c(3,1),mar=c(4,4,1,1))
  plot(1:dim(cidade)[1],cidade$tweet,type="h",ylab="",axes=FALSE,xlab="",main="Tweets sobre dengue")
  axis(2)
  plot(1:dim(cidade)[1],cidade$inc, type="l", xlab="",ylab="incidência (por 100.000)",axes=FALSE,main="Dengue",ylim=c(0,ymax))
  abline(h=14, lty=2, col="blue")
  abline(h=100, lty=2, col="red")
  text(mean(1:dim(cidade)[1]),14,"limiar pré epidêmico",col="blue",cex=0.8)
  text(mean(1:dim(cidade)[1]),100,"limiar alta atividade",col="red",cex=0.8)
  axis(2)
  
  plot(1:dim(cidade)[1],cidade$tmin,type="l",ylab="temperatura",axes=FALSE,xlab="",main="Temperatura mínima")
  abline(h=22, lty=2, col=2)
  axis(2)
  le=dim(cidade)[1]
  axis(1,at=rev(seq(le,1,by=-12)),labels=cidade$se[rev(seq(le,1,by=-12))],las=2)
  text(mean(1:dim(cidade)[1]),22,"temp crítica",col=2, cex=0.8)
  dev.off()
  # fim do grafico da cidade -------------
  
  ### grafico APS 1/2 ------------------
  png(paste(dirout,"figaps1.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  inid = 201224
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 1:5) {
    plot.alerta(alert[[i]],var="inc",ini=inid,fim=max(alert[[i]]$data$SE))
    mtext(names(alert)[i],line=-1, cex=0.7)
  }
  dev.off()
  
  ### grafico APS 2/2 ------------------
  png(paste(dirout,"figaps2.png",sep=""),width = 12, height = 16, units = "cm",res=200)
  inid = 201224
  par(mfrow=c(5,1),mar=c(5,0,0,5))
  for (i in 6:10) {
    plot.alerta(alert[[i]],var="inc",ini=inid,fim=max(alert[[i]]$data$SE))
    mtext(names(alert)[i],line=-1, cex=0.7)
  }
  dev.off()
  
  # --------------------------------
  # Gera e salva tabela da cidade
  # --------------------------------
  fname = paste(dirout,"tabelaRio.tex",sep="")
  tabelax <-xtable(tail(cidade),align ="cc|ccccccc",digits = 0)
  digits(tabelax) <- 0
  print(tabelax, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  
  # --------------------------------
  # Gera e salva tabelas das APS
  # --------------------------------
  listaaps <- unique(res$aps)
  
  for(ap in 1:10){
    fname = paste(dirout,"tabela",ap,".tex",sep="")
    tab<-tail(res[res$aps==listaaps[ap],c("se","casos","casos_est","tmin","rt","p_rt1","inc","nivel")],n=4)
    tabelay <- xtable(tab,align="cc|ccccccc",digits = 0)
    digits(tabelay) <- 0
    print(tabelay, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
          include.rownames=FALSE)
  }
  
}
