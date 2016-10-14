###############################################
## Graficos e Mapas para relatorios
###############################################

fig.all <- function(obj){
      
      ncidades = length(obj)
      
      for (i in 1:ncidades){
            oobj <- obj[[i]]
            nome = na.omit(unique(oobj$data$nome))
            nick <- gsub(" ", "", nome, fixed = TRUE)
            filename = paste("../report",nick,".png",sep="")
            
            png(filename, width = 16, height = 10.5, units="cm", res=100)
            layout(matrix(1:2, nrow = 2, byrow = TRUE), widths = lcm(15), 
                   heights = c(lcm(3), lcm(7)))
            
            # Grafico superior - tweeter
             par(mai=c(0,0,0,0),mar=c(0,4,0,3))
             plot(oobj$data$casos, type="l", xlab="", ylab="", axes=FALSE)
             daxis(1, pos=0, lty=0, lab=FALSE)
             axis(2,las=2)
             mtext(text="casos de dengue", line=2.5,side=2, cex = 0.7)
             maxy <- max(oobj$data$casos, na.rm=TRUE)
             legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
             par(new=T)
             plot(oobj$data$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
             lines(oobj$data$tweet, col=3, type="h") #*coefs[2] + coefs[1]
             axis(1, pos=0, lty=0, lab=FALSE)
             axis(4,las=2)
             mtext(text="tweets", line=2.5, side=4, cex = 0.7)
            
            # Grafico meio
            par(mai=c(0,0,0,0),mar=c(0,4,0,3))
            plot(oobj$data$temp_min, type="l", xlab="", ylab ="temperatura",axes=FALSE,col="darkgreen")
            axis(2, las=2)
            clip(1,length(oobj$data$temp_min),oobj$rules$tcrit,100)
            lines(oobj$data$temp_min, col='yellow', type='l')
            abline(h=obj$rules$tcrit, lty=2)
             
            
            # Grafico baixo
            par(mai=c(0,0,0,0),mar=c(1,4,0,4))
            plot.alerta(oobj, var="inc",ini=201352,fim=max(oobj$data$SE))
            dev.off()
            message(paste("Figura salva da cidade", nick))
      }
}

# -----------------------------------------------
fig.cores <- function(obj){
      
      ncidades = length(obj)
      
      for (i in 1:ncidades){
            oobj <- obj[[i]]
            nome = na.omit(unique(oobj$data$nome))
            nick <- gsub(" ", "", nome, fixed = TRUE)
            filename = paste("report/cores_",nick,".png",sep="")
            
            png(filename, width = 16, height = 5.5, units="cm", res=100)
            layout(matrix(1), widths = lcm(15), 
                   heights = c(lcm(5)))
            # Grafico baixo
            par(mai=c(0,0,0,0),mar=c(1,4,0,4))
            plot.alerta(oobj, var="inc",ini=201352,fim=max(oobj$data$SE))
            dev.off()
            message(paste("Figura salva da cidade", nick))
      }
}

# --------- Mapa das regionais --------------------------------------
mapa.regional <- function(alerta, regionais, estado, sigla, pars, shape, 
                          shapeid, data, dir="",
                          datasource){
  for (i in regionais) {
    cidades = getCidades(regional = i, uf = estado,datasource = datasource)["nome"]
    titu = paste(sigla,":",i,"\n")
    nomesemespaco = gsub(" ","",i)
    nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
    fname = paste(dir,"Mapa",sigla,"_",nomesemacento,".png",sep="")
    message("mapa criado:", fname)
    geraMapa(alerta=alerta, subset=cidades, se=data, legpos = pars[[i]]$legpos,  
             shapefile=shape, varid=shapeid, 
             titulo=titu ,filename=fname, dir="")
  }
  fname
}


# ------------ Figuras municipios ------------------------------------
## figuramunicipio: codigo da figura com 3 subfiguras que e usada para os municipios
# obj é o alerta do municipio gerado pelo update.alerta
# USO: figuramunicipio(alePR_RS_Cascavel[["CéuAzul"]])

figuramunicipio <- function(obj, tsdur=104){
  layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(13), 
         heights = c(rep(lcm(4),2), lcm(5)))
  
  n = dim(obj$data)[1]
  objc = obj$data[(n-tsdur):n,]
  
  #objc <- obj$data[obj$data$SE>=201301,] 
  # Subfigura do topo (serie temporal dengue e tweets)
  par(mai=c(0,0,0,0),mar=c(1,4,0,3))
  plot(objc$casos, type="l", xlab="", ylab="", axes=FALSE)
  axis(1, pos=0, lty=0, lab=FALSE)
  axis(2)
  mtext(text="Casos de Dengue", line=2.5,side=2, cex = 0.7)
  maxy <- max(objc$casos, na.rm=TRUE)
  legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
  par(new=T)
  if(sum(is.na(objc$tweet))==nrow(objc)) objc$tweet = 0 # 
  plot(objc$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
  lines(objc$tweet, col=3, type="h") #*coefs[2] + coefs[1]
  axis(1, pos=0, lty=0, lab=FALSE)
  axis(4)
  mtext(text="Tweets", line=2.5, side=4, cex = 0.7)
  
  # subfigura do meio: temperatura
  par(mai=c(0,0,0,0),mar=c(1,4,0,3))
  plot(objc$temp_min, type="l", xlab="", ylab ="Temperatura",axes=FALSE)
  legend(x="topleft",lty=c(2),col=c("black"),
         legend=c("limiar favorável transmissão"),cex=0.85,bty="n")
  axis(2)
  abline(h=22, lty=2)
  
  # subfigura de baixo: alerta colorido
  par(mai=c(0,0,0,0),mar=c(1,4,0,4))
  plot.alerta(obj, var="tcasesmed",ini=min(objc$SE),fim=max(objc$SE))
  abline(h=100/100000*obj$data$pop[1],lty=3)
  legend(x="topright",lty=c(3,2,2),col=c("black","red","darkgreen"),
         legend=c("limiar epidêmico","limiar pré-epidêmico","limiar pós-epidêmico"),cex=0.85,bty="n")
  
}

# -----------------------------
# figuraRio

figuraRio <- function(cid){
  par(mfrow=c(3,1),mar=c(4,4,1,1))
  ymax <- max(110,max(cid$inc))
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

# -------------------------------
# fazTabelao com dados da ultima semana das Regionais ou do estado
# -------------------------------

faztabelaoRS <- function(ale,ano,data){
  totano=0; totultse=0
  nverde=0; namarelo=0;nlaranja=0;nvermelho=0
  nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
  
  # ----- começo do tabelao
  tabelao = data.frame(Municipio = character(),Regional = character(), 
                       Temperatura = numeric(), Tweets=numeric(),
                       Casos = integer(), Incidencia=numeric(),Rt=numeric(),
                       Nivel=character(),stringsAsFactors = FALSE)
  N = length(names(ale))
  for (i in 1:N){
    ai <- ale[[i]] 
    
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
  tabelao
}
