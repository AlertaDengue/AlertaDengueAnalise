# Funcao que retorna dados de temperatura minima do Weatherunderground armazenados
# no mongo. Sao 4 estacoes:  

callmongoclima<-function(estacao){
  if(estacao=="galeao") db = "clima.SBGL"
  if(estacao=="santosdumont") db = "clima.SBRJ"
  if(estacao=="afonsos") db = "clima.SBAF"
  if(estacao=="jacarepagua") db = "clima.SBJR"
  
  mongo<-mongo.create()
  query = mongo.bson.empty()
  clima<-mongo.find.all(mongo,db,query, sort=list(DateUTC=1), fields=list(DateUTC=1L, Tmin=1L),  )
  n = length(clima)
  
  data <- as.Date(clima[[1]]$DateUTC)
  for (i in 2:n) data = c(data,as.Date(clima[[i]]$DateUTC))
  
  tmin<-clima[[1]]$Tmin
  for (i in 2:n) tmin = c(tmin,clima[[i]]$Tmin)
  
  d <- data.frame(estacao=estacao,data=data,tmin=tmin)
  d$tmin[d$tmin==-9999]<-NA
  
  message("dados de clima:")
  print(tail(d,n=7))
  
  mongo.disconnect(mongo)
  d
}

#TESTE
#d<-callmongoclima("galeao")
#head(d)
#tail(d)
