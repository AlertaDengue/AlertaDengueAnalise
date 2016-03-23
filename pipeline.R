# =====================================================
# Funcao que roda o pipeline por cidade ou regiao
# =====================================================
# pode rodar para uma cidade: cidade = 330045
# rodar para uma regional: regional = "Litoral Sul" 
# rodar para um estado: estado = "Rio de Janeiro"

run.pipeline <- function(cidade, regional, estado, params, write = escreverBD, sfigs = salvafiguras, smapa = salvamapa, sefinal = datafim){
       
       if(!missing (cidade)) { # lista de cidades
             print(cidade)
            if(nchar(cidade) == 6) cidade <- sevendigitgeocode(cidade) 
            sql = paste("SELECT geocodigo, codigo_estacao_wu
               FROM \"Dengue_global\".\"Municipio\" 
                              INNER JOIN \"Dengue_global\".regional_saude
                              ON municipio_geocodigo = geocodigo
                              where geocodigo = '", cidade, "'", sep="")
            dd <- dbGetQuery(con,sql)
       }
      
      if (!missing(estado)){ # cidades do estado 
                  sql = paste("SELECT geocodigo, codigo_estacao_wu
               FROM \"Dengue_global\".\"Municipio\" 
                              INNER JOIN \"Dengue_global\".regional_saude
                              ON municipio_geocodigo = geocodigo
                              where uf = '", estado, "'", sep="")
            dd <- dbGetQuery(con,sql)
            if (dim(dd)[1]==0) stop(paste("O estado ",estado, "nao foi achado. Verifique se escreveu certo (por extenso)"))
      }
      if (!missing(regional)){ # cidades da regional
            sql = paste("SELECT geocodigo, codigo_estacao_wu
               FROM \"Dengue_global\".\"Municipio\" 
                              INNER JOIN \"Dengue_global\".regional_saude
                              ON municipio_geocodigo = geocodigo
                              where nome_regional = '",regional,"'",sep="")
            dd <- dbGetQuery(con,sql)
            if (dim(dd)[1]==0) stop(paste("A regional",regional, "nao foi achada. Verifique se escreveu certo (por extenso)"))
            
      }
#
      nlugares <- dim(dd)[1]
      print(paste("sera'feita analise de",nlugares,"cidade(s):"))
      print(dd$geocodigo)      
      
      for (i in 1:nlugares){ # para cada cidade ...
            geocidade = dd$geocodigo[i]
            estacao = dd$codigo_estacao_wu[i]
            print(paste("Rodando alerta para ", geocidade, "usando estacao", estacao))
            
            dC0 = getCases(city = geocidade, datasource = con) # consulta dados do sinan
            dT = getTweet(city = geocidade, lastday = Sys.Date(),datasource = con) # consulta dados do tweet
            dW = getWU(stations = estacao,var="temp_min",datasource = con) # consulta dados do clima
            d <- mergedata(cases = dC0, climate = dW, tweet = dT, ini=201352)  # junta os dados
            d$temp_min <- nafill(d$temp_min, rule="linear")  # interpolacao clima NOVO
            d$casos <- nafill(d$casos, "zero") # preenche de zeros o final da serie NOVO
            d <- subset(d,SE<=sefinal)
            d$cidade[is.na(d$cidade)==TRUE] <- geocidade
            d$nome[is.na(d$nome)==TRUE] <- na.omit(unique(d$nome))[1]
            d$pop[is.na(d$pop)==TRUE] <- na.omit(unique(d$pop))[1] 
            pdig <- plnorm((1:20)*7, params$pdig[1], params$pdig[2])[2:20]
            dC2 <- adjustIncidence(d, pdig = pdig) # ajusta a incidencia
            dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt) # calcula Rt
            
            cy = c(gsub("tcrit", params$tcrit, crity[1]), crity[2], crity[3])
            cr = c(gsub("inccrit", params$inccrit, critr[1]), critr[2], critr[3])
            alerta <- fouralert(dC3, cy = cy, co = crito, cr = cr, pop=dC0$pop[1], miss="last") # calcula alerta
            nome = na.omit(unique(dC0$nome))
            nick <- gsub(" ", "", nome, fixed = TRUE)
            
            N = dim(alerta$indices)[1]
            print(paste("nivel do alerta de ",nome,":", alerta$indices$level)[N])
            
            if (write == TRUE) {
                  res <- write.alerta(alerta, write = "db")
                  write.csv(alerta,file=paste("memoria/", nick,hoje,".csv",sep="")) 
            }
            
            if (sfigs == TRUE)  figrelatorio(alerta)      
            #message(paste("alerta gerado para cidade",cidade))
      }
      alerta
}

# ===========================
# Generate Figure
# ===========================

figrelatorio <- function(alerta){
      
      # nome do arquivo para salvar a figura
      nick <- gsub(" ", "", na.omit(unique(alerta$data$nome)), fixed = TRUE)
      filename = paste("report/",nick,".png",sep="")
      #filename = paste(nick,".png",sep="")
      
      # codigo da figura
      png(filename, width = 16, height = 15, units="cm", res=100)
      layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(15), 
             heights = c(rep(lcm(4),2), lcm(5)))
      
      # separação dos eixos para casos de dengue e tweets 
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      
      plot(alerta$data$casos, type="l", xlab="", ylab="", axes=FALSE)
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(2)
      mtext(text="Casos de Dengue", line=2.5,side=2, cex = 0.7)
      maxy <- max(alerta$data$casos, na.rm=TRUE)
      legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
      par(new=T)
      plot(alerta$data$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
      lines(alerta$data$tweet, col=3, type="h") #*coefs[2] + coefs[1]
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(4)
      mtext(text="Tweets", line=2.5, side=4, cex = 0.7)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      plot(alerta$data$temp_min, type="l", xlab="", ylab ="Temperatura",axes=FALSE)
      axis(2)
      abline(h=22, lty=2)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,4))
      #par(mar=c(4,4,1,1))
      plot.alerta(alerta, var="tcasesmed",ini=201352,fim=max(alerta$data$SE))
      abline(h=100/100000*alerta$data$pop[1],lty=3)
      dev.off()
      
      message(paste("Figura salva da cidade", nick))
}
