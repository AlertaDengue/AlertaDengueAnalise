# Funcao que retorna dados de temperatura minima do Weatherunderground armazenados
# no mongo. Sao 4 estacoes:  

callmongoclima<-function(estacao){
  if(estacao=="galeao") db = "clima.SBGL"
  if(estacao=="santosdumont") db = "clima.SBRJ"
  if(estacao=="afonsos") db = "clima.SBAF"
  if(estacao=="jacarepagua") db = "clima.SBJR"
  
  mongo<-mongo.create()
  query = mongo.bson.empty()
  
  #clima<-mongo.find.all(mongo,db,query, sort=list(DateUTC=1), fields=list(DateUTC=1L, Tmin=1L),  )
  clima<-mongo.find.all(mongo,db,query, sort=list(DateUTC=1))
  
  n = length(clima)
  
  data <- as.Date(clima[[1]]$DateUTC)
  for (i in 2:n) data = c(data,as.Date(clima[[i]]$DateUTC))
  tmin<-clima[[1]]$Tmin
  for (i in 2:n) tmin = c(tmin,clima[[i]]$Tmin)
  tmed<-clima[[1]]$Tmed
  for (i in 2:n) tmed = c(tmed,clima[[i]]$Tmed)
  tmax<-clima[[1]]$Tmax
  for (i in 2:n) tmax = c(tmax,clima[[i]]$Tmax)
  umin<-clima[[1]]$Umid_min
  for (i in 2:n) umin = c(umin,clima[[i]]$Umid_min)
  umed<-clima[[1]]$Umid_med
  for (i in 2:n) umed = c(umed,clima[[i]]$Umid_med)
  umax<-clima[[1]]$Umid_max
  for (i in 2:n) umax = c(umax,clima[[i]]$Umid_max)
  pressaomin<-clima[[1]]$Pressao_min
  for (i in 2:n) pressaomin = c(pressaomin,clima[[i]]$Pressao_min)
  pressaomed<-clima[[1]]$Pressao_med
  for (i in 2:n) pressaomed = c(pressaomed,clima[[i]]$Pressao_med)
  pressaomax<-clima[[1]]$Pressao_max
  for (i in 2:n) pressaomax = c(pressaomax,clima[[i]]$Pressao_max)
  
    
  d <- data.frame(estacao=estacao,data=data,tmin=tmin,tmed=tmed,tmax=tmax,umin=umin,umed=umed,umax=umax,
                  pressaomin=pressaomin,pressaomed=pressaomed,pressaomax=pressaomax)
  d$tmin[d$tmin==-9999]<-NA
  d$tmed[d$tmed==-9999]<-NA
  d$tmax[d$tmin==-9999]<-NA
  d$umin[d$umin==-9999]<-NA
  d$umed[d$umed==-9999]<-NA
  d$umax[d$umax==-9999]<-NA
  d$pressaomin[d$pressaomin==-9999]<-NA
  d$pressaomed[d$pressaomed==-9999]<-NA
  d$pressaomax[d$pressaomax==-9999]<-NA
  
  
  message("dados de clima:")
  print(tail(d,n=7))
  
  mongo.disconnect(mongo)
  d
}

#TESTE
#d<-callmongoclima("galeao")
#head(d)
#tail(d)
