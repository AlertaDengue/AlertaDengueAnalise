# ========================================================
# Configuracao para o boletim do Estado do Rio de Janeiro
# ========================================================

configRelatorio <- function(uf, sigla, data, alert, shape, varid, dir, datasource){
      # ------------
      ## Parte fixa
      # ------------
      
      estado = uf
      sigla = sigla
      municipios = getCidades(uf=estado,datasource=con)
      nmunicipios = dim(municipios)[1]
      regs = getRegionais(uf = estado) 
      nickregs = abbreviate(iconv(regs, to = "ASCII//TRANSLIT"))
      
      # -----------
      ## Parte que muda
      # -----------
      ano = floor(data/100)
      se = data - ano*100 
      
      # Dados a nivel de estado
      totano=0; totultse=0
      nverde=0; namarelo=0;nlaranja=0;nvermelho=0
      nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
      
      # -------- Mapa do estado (funcao basica do alerttools)
      geraMapa(alerta=alert, se=data, shapefile = shape,   
               varid=varid, titulo="", 
               filename=paste("Mapa_E", sigla,".png", sep=""),
               dir=dir, caption=FALSE)
               
      # ---------Mapa Regionais (funcao customizada, no codigoFiguras.R)
      mapa.regional(alerta=alert, regionais=nomesregs, estado = uf, sigla = sigla,
                    data = data, shape=shape, shapeid=varid, dir=dir ,datasource=datasource)
               
      # tabelao
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
            
            # Tabelao dos municipios
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
      
      fname = paste(RJ.out,"tabelao",sigla,".tex",sep="")
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
      
      # --------------------------------
      # Gera e salva tabelas regionais (xtable)
      # --------------------------------
      
      for (k in regs) {
            cidades = getCidades(regional = k, uf = estado, datasource = datasource)
            linhascidades <- which(names(alert) %in% cidades$nome)
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
            fname = paste(RJ.out,"tabregional",sigla,"_",nomesemacento,".tex",sep="")
            
            tabelax <-xtable(tabelafinal,align ="cc|ccccccc",digits = 0)
            digits(tabelax) <- 0
            print(tabelax, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
                  include.rownames=FALSE)
            
            
            # --------------------------------
            # Gera e salva figuras-resumo das regionais 
            # --------------------------------
            
            res = write.alerta(alert[[1]])
            for (n in 2:N) res = rbind(res, write.alerta(alert[[n]]))
            
            serie = aggregate(cbind(tweet,casos)~data_iniSE,data=res,FUN=sum,na.rm=TRUE)
            
            figname = paste(RJ.out,"tweet",sigla,"_",nomesemacento,".png",sep="")
            png(figname, width = 12, height = 5.5, units="cm", res=200)
            layout(matrix(1), widths = lcm(10),heights = c(lcm(5)))
            
            par(mai=c(0,0,0,0),mar=c(4,3,1,3))
            plot(serie$casos, type="l", xlab="", ylab="", axes=FALSE,bty="o")
            axis(1, pos=0, las=2, at=seq(1,length(serie$casos),by=12), 
                 labels=serie$data_iniSE[seq(1,length(serie$casos),by=12)],
                 cex.axis=0.7)
            
            axis(2,las=2,cex.axis=0.7)
            mtext(text="casos de dengue", line=3.5,side=2, cex = 0.8)
            maxy <- max(serie$casos, na.rm=TRUE)
            legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
            par(new=T)
            plot(serie$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
            lines(serie$tweet, col=3, type="h") #*coefs[2] + coefs[1]
            axis(1, pos=0, lty=0, lab=FALSE)
            axis(4,las=2, cex.axis=0.7)
            mtext(text="tweets", line=2.5, side=4, cex = 0.8)
            dev.off()
            
      }      
      
      
      
      save(estado, sigla, se, ano, municipios, nmunicipios, regs,nickregs, totano, totultse, tabelao,
           nverde, namarelo, nlaranja, nvermelho, nverde1, namarelo1, nlaranja1, nvermelho1,
           file=paste(RJ.out,"params",sigla,".RData",sep=""))
}

configRelatorioMunicipal <- function(alert, dir.out, data, datasource=con){
      nomecidade = alert$data$nome[1]
      geocodigo = alert$data$cidade[1]
      
      regionalmun = dbGetQuery(datasource, paste("SELECT nome_regional 
                  FROM \"Dengue_global\".regional_saude 
                  where municipio_geocodigo = ", geocodigo, sep=""))    
      
      ano = floor(data/100)
      se = data - ano*100 
      linhasdoano = which(floor(alert$data$SE/100)==ano)
      linhase = which(alert$data$SE==data)
      linhase1 = which(alert$data$SE==data)-1
            
      totanomun = sum(alert$data$casos[linhasdoano],na.rm=TRUE)
      totultsemun = alert$data$casos[linhase]
      
      cores = c("verde","amarelo","laranja","vermelho")
      nivelmun = cores[alert$indices$level[linhase] ]  
      
      # cria nome do arquivo de saida
      dirmun = gsub("/figs","",dir.out)
      nomesemespaco = gsub(" ","",nomecidade)
      nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
      fname = paste(dirmun,nomesemacento,"/","params",nomesemacento,".RData",sep="")
      
      # Figura
      figname = paste(dirmun,nomesemacento,"/","figura",nomesemacento,".png",sep="")
      png(figname, width = 14, height = 16, units="cm", res=300)
      layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(13), 
             heights = c(rep(lcm(4),2), lcm(5)))
      
      # separação dos eixos para casos de dengue e tweets 
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      
      plot(alert$data$casos, type="l", xlab="", ylab="", axes=FALSE)
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(2)
      mtext(text="Casos de Dengue", line=2.5,side=2, cex = 0.7)
      maxy <- max(alert$data$casos, na.rm=TRUE)
      legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
      par(new=T)
      plot(alert$data$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
      lines(alert$data$tweet, col=3, type="h") #*coefs[2] + coefs[1]
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(4)
      mtext(text="Tweets", line=2.5, side=4, cex = 0.7)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      plot(alert$data$temp_min, type="l", xlab="", ylab ="Temperatura",axes=FALSE)
      legend(x="topleft",lty=c(2),col=c("black"),
             legend=c("limiar favorável transmissão"),cex=0.85,bty="n")
      axis(2)
      abline(h=22, lty=2)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,4))
      #par(mar=c(4,4,1,1))
      plot.alerta(alert, var="tcasesmed",ini=201301,fim=max(alert$data$SE))
      abline(h=100/100000*alert$data$pop[1],lty=3)
      legend(x="topright",lty=c(3,2,2),col=c("black","red","darkgreen"),
             legend=c("limiar epidêmico","limiar pré-epidêmico","limiar pós-epidêmico"),cex=0.85,bty="n")
      dev.off()
      
      message(paste("figura",figname,"salva"))
      save(nomecidade, regionalmun, alert, totanomun, totultsemun, nivelmun, se, file=fname)
}


geraRelatorioMunicipal<-function(dir, alert, rnwfile = "BoletimMunicipal_InfoDengue_v01.Rnw",
                                 dirbase=diralerta, data=data_relatorio){  
      
      rnwdir = paste(dirbase, "report/reportconfig/",sep="")
      # parametros estaduais
      load(paste(dir,"/paramsRJ.RData",sep=""))
      
      # diretorio do municipio
      nomecidade = alert$data$nome[1]
      dirmun = gsub("/figs","",dir)
      nomesemespaco = gsub(" ","",nomecidade)
      nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
      dirmun = paste(dirmun,nomesemacento,sep="")
      
      load(paste(dirmun,'/params',nomesemacento,'.RData',sep=""))
      figmapaestado = paste(dir,'Mapa_E',sigla,'.png',sep="")
      figmunicipio = paste(dirmun,'/figura',nomesemacento,'.png',sep="")
      temp <<- environment()
      Sweave(paste(rnwdir,rnwfile,sep=""), encoding = "UTF8")     
      require(tools)  
      
      # arquivo tex gerado
      texfile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".tex",sep="")
      texi2dvi(file = texfile, pdf = TRUE, quiet=TRUE, clean=TRUE) 
}


### Rio de Janeiro - cidade ###
# por razoes historicas, temos funcoes separadas para a cidade do Rio de Janeiro

# geraRelatorioRio<-function(dir, alert, rnwfile = "BoletimMunicipal_InfoDengue_v01.Rnw",
#                                  dirbase=diralerta, data=data_relatorio){  
#       
#       rnwdir = paste(dirbase, "report/reportconfig/",sep="")
#       # parametros estaduais
#       load(paste(dir,"/paramsRJ.RData",sep=""))
#       
#       # diretorio do municipio
#       nomecidade = alert$data$nome[1]
#       dirmun = gsub("/figs","",dir)
#       nomesemespaco = gsub(" ","",nomecidade)
#       nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
#       dirmun = paste(dirmun,nomesemacento,sep="")
#       
#       load(paste(dirmun,'/params',nomesemacento,'.RData',sep=""))
#       figmapaestado = paste(dir,'Mapa_E',sigla,'.png',sep="")
#       figmunicipio = paste(dirmun,'/figura',nomesemacento,'.png',sep="")
#       temp <<- environment()
#       Sweave(paste(rnwdir,rnwfile,sep=""), encoding = "UTF8")     
#       require(tools)  
#       
#       # arquivo tex gerado
#       texfile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".tex",sep="")
#       texi2dvi(file = texfile, pdf = TRUE, quiet=TRUE, clean=TRUE) 
# }



configRelatorioRio<-function(alert, tres, dir, datasource=con, data,dirbase=diralerta){
      
      dirout=paste(diralerta, "report/Rio_de_Janeiro/",sep="")
      map.Rio(alerio, data=data_relatorio, filename="mapaRio.png", dir=dirout)
      
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
