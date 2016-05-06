# ========================================================
# Configuracao para o boletim do Estado do Rio de Janeiro
# ========================================================

configRelatorio <- function(uf, sigla, data, alert, dir, datasource){
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
      
      linhasdoano = which(floor(alert[[1]]$data$SE/100)==ano)
      linhase = which(alert[[1]]$data$SE==data)
      linhase1 = which(alert[[1]]$data$SE==data)-1
      
      # tabelao
      tabelao = data.frame(Municipio = character(),Regional = character(), 
                               Temperatura = numeric(), Tweets=numeric(),
                               Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                               Nivel=character(),stringsAsFactors = FALSE)
     
      for (i in 1:nmunicipios){
            ai <- alert[[i]] 
            totano = totano + sum(ai$data$casos[linhasdoano],na.rm=TRUE)
            totultse = sum(c(totultse, ai$data$casos[linhase]),na.rm=TRUE)
            
            nverde = sum(c(nverde,as.numeric(ai$indices$level[linhase]==1)),na.rm=TRUE)
            namarelo = sum(c(nverde,as.numeric(ai$indices$level[linhase]==2)),na.rm=TRUE)
            nlaranja = sum(c(nverde,as.numeric(ai$indices$level[linhase]==3)),na.rm=TRUE)
            nvermelho = sum(c(nverde,as.numeric(ai$indices$level[linhase]==4)),na.rm=TRUE)
            
            nverde1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==1)),na.rm=TRUE)
            namarelo1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==2)),na.rm=TRUE)
            nlaranja1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==3)),na.rm=TRUE)
            nvermelho1 = sum(c(nverde1,as.numeric(ai$indices$level[linhase1]==4)),na.rm=TRUE)
            
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