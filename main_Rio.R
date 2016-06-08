# ================================================================================
# Arquivo de execução do Alerta Dengue: Municipio do Rio de Janeiro
# ================================================================================
diralerta = "../" # trocar por "alerta/" para usar com o pacote AlertTools
source(paste(diralerta,"/config/config.R",sep="")) # criterios em uso
data_relatorio = 201622

# --Calcula alerta--
con = DenguedbConnect()
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, 
                    se = data_relatorio, verbose=TRUE)
res <- write.alertaRio(alerio, write="no") 
save(alerio,res,data_relatorio, file="../report/Rio_de_Janeiro/paramsRio.RData")
map.Rio(alerio,shapefile = "../report/Rio_de_Janeiro/shape/CAPS_SMS.shp") 

# configura o relatorio municipal e gera pdf NEW - falta terminar deencapsular figura
configRelatorioRio<-function(alert=alerio, tres = res, dir=RJ.out, datasource=con, data=data_relatorio,
                             dirbase=diralerta){
      
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
            digits(tabelax) <- 0
            print(tabelax, type="latex", file=fname, floating=FALSE, latex.environments = NULL,
                        include.rownames=FALSE)
      }
      
}
      
configRelatorioRio(alert=alerio, dir=RJ.out, datasource=con, data=data_relatorio)

geraRelatorioMunicipal(dir=RJ.out, alert=aleCampos) # ignore as mensagens de erro

## FIM NEW
knit(input="../report/matriz_relatorioMRJ.Rmd",quiet=TRUE,envir=new.env())

# Quer salvar o resultado do Alerta no Banco de Dados? 
res <- write.alertaRio(alerio, write="db")


