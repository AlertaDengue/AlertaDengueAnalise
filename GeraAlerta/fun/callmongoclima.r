# Funcao que retorna dados de temperatura minima do Weatherunderground armazenados
# no mongo. Sao 4 estacoes:  

callmongoclima<-function(estacao){
  if(estacao=="galeao") db = "clima.SBGL"
  if(estacao=="santosdumont") db = "clima.SBRJ"
  if(estacao=="afonsos") db = "clima.SBAF"
  if(estacao=="jacarepagua") db = "clima.SBJR"
  
  mongo<-mongo.create()
  query = mongo.bson.empty()
  clima<-mongo.find.all(mongo,db,query, 
                                      sort=list(DateUTC=1), fields=list(DateUTC=1L, Tmin=1L),  )
  n = dim(clima)[1]
  
  data <- as.Date(clima[1,2][[1]])
  for (i in 2:n) data = c(data,as.Date(clima[i,2][[1]]))
  
  Tmin<-clima[1,3][[1]]
  for (i in 2:n) Tmin = c(Tmin,clima[i,3][[1]])
  
  d <- data.frame(estacao=estacao,data=data,tempmin=Tmin)
  d$tempmin[d$tempmin==-9999]<-NA
  
  mongo.disconnect(mongo)
  d 
}

#d<-callmongoclima("galeao")
#head(d)
