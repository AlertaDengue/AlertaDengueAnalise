###############################################
## Graficos e Mapas para relatorios
###############################################

fig.all <- function(obj){
      
      ncidades = length(obj)
      
      for (i in 1:ncidades){
            oobj <- obj[[i]]
            nome = na.omit(unique(oobj$data$nome))
            nick <- gsub(" ", "", nome, fixed = TRUE)
            filename = paste("report/",nick,".png",sep="")
            
            png(filename, width = 16, height = 10.5, units="cm", res=100)
            layout(matrix(1:2, nrow = 2, byrow = TRUE), widths = lcm(15), 
                   heights = c(lcm(3), lcm(7)))
            
            # Grafico superior 
#             par(mai=c(0,0,0,0),mar=c(0,4,0,3))
#             plot(oobj$data$casos, type="l", xlab="", ylab="", axes=FALSE)
#             axis(1, pos=0, lty=0, lab=FALSE)
#             axis(2,las=2)
#             mtext(text="casos de dengue", line=2.5,side=2, cex = 0.7)
#             maxy <- max(oobj$data$casos, na.rm=TRUE)
#             legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
#             par(new=T)
#             plot(oobj$data$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
#             lines(oobj$data$tweet, col=3, type="h") #*coefs[2] + coefs[1]
#             axis(1, pos=0, lty=0, lab=FALSE)
#             axis(4)
#             mtext(text="tweets", line=2.5, side=4, cex = 0.7)
            
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
