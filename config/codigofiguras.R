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

figuramunicipio <- function(obj){
  layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(13), 
         heights = c(rep(lcm(4),2), lcm(5)))
  
  objc <- obj$data[obj$data$SE>=201301,] 
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
  lines(obj$tweet, col=3, type="h") #*coefs[2] + coefs[1]
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
  plot.alerta(obj, var="tcasesmed",ini=201301,fim=max(obj$data$SE))
  abline(h=100/100000*obj$data$pop[1],lty=3)
  legend(x="topright",lty=c(3,2,2),col=c("black","red","darkgreen"),
         legend=c("limiar epidêmico","limiar pré-epidêmico","limiar pós-epidêmico"),cex=0.85,bty="n")
  
}
