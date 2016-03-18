# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes auxiliadoras para formatacao dados de clima do Alerta dengue
# Claudia Codeco 2015
# -----------------------------------------------------------

# data2SE ---------------------------------------------------------------------
#'@description Find to which epidemiological week belongs a given day (only >=2010)
#'@title Define Epidemiological Week
#'@param date string vector with dates to be converted
#'@param format date format
#'@return data.frame with the epidemiological weeks. Only works for years >= 2010.
#'@examples
#'data2SE("01-02-2010",format="%d-%m-%Y")
#'data2SE(c("03-04-2013","07-01-2014"),format="%d-%m-%Y")

data2SE <- function(days, format = "%d/%m/%Y"){
  sem <- rep(NA,length(days))      
  days<-as.Date(as.character(days),format=format)
  for (i in 1:length(days)) {
    sem[i]<-episem(days[i])      
  }
  sem
}

# episem ---------------------------------------------------------------------
#'@description Find to which epidemiological week belongs a given day (Oswaldo's function)
#'@title Define Epidemiological Week
#'@param date date to be converted (class Date)
#'@param separa symbol between year and week
#'@return epidemiological week 
#'@examples
#'episem(x= as.Date("2015-01-01", format="%Y-%m-%d"))

episem <- function(x, format="%Y-%m-%d") {
      # semana epi 1 de 2000 02/01/2000
      if (class(x)!= "Date") {
            x <- as.Date(x, format = format)
            #warning("Precisa ser do tipo Date - Convertendo de texto")
      }
      
      ##  funcoes auxiliares - poderia usar a lubridate mas achei assim mais simples
      
      year  <- function(dt) {as.numeric(format(dt,"%Y"))}  ## retorna ano
      wday <- function(dt) {as.numeric(format(dt,"%w"))}   ## retorna dia sendo  0 = domingo a 6= sabado
      passado <- function(dt,diff=1) {as.Date(paste(as.numeric(format(dt,"%Y"))-diff,format(dt,"%m-%d"),sep="-"))} ## ano - x
      
      ## Inicio 
      
      ano <- year(x) # extrai ano
      dia1 <- as.Date(paste(ano,'01','01',sep='-')) # primeiro do ano 
      
      diasem <- wday(dia1)  #descobre o dia da semana do dia1 
      fwd <- ifelse (diasem <=3, dia1 - diasem , dia1 + (7 - diasem) ) #se for menor ou igua a 3 (quarta) 
      fwd <- as.Date(fwd,origin = '1970-01-01') # reformata em data pois ela perde a formatacao 
      
      ## caso a data seja menor que a da 1o semana do ano (fwd)
      if (x < fwd) {
            dia1 <- passado(dia1)  # ano -1 
            diasem <- wday(dia1)  #dia da semana 
            fwd <- ifelse (diasem <=3, dia1 - diasem , dia1 + (7 - diasem) )
            fwd <- as.Date(fwd,origin = '1970-01-01')
      }
      
      diafim <- as.Date(paste(ano,'12','31',sep='-')) #Ultimo dia do ano
      diasem <- wday(diafim)                          #dia semana do ultimo dia
      
      ewd <- ifelse (diasem < 3, diafim - diasem , diafim + 6 - diasem) 
      ewd <- as.Date(ewd,origin = '1970-01-01') # ultima semana epi do ano
      
      if (x >= ewd) fwd <- ewd + 1 #caso a data (x) seja maior ou igual a ultiam semaan do ano
      epiweek <- floor(as.numeric(x - fwd) / 7 ) + 1 #numero de semanas e a diff da data e da primeira semana div por 7
      
      if(epiweek==0) epiweek <- 1 ## gatilho se for 0 vira semana 1
      epiyear <- year(fwd + 180) ## ano epidemiologico
      epiyear*100+epiweek
}


# SE2date ---------------------------------------------------------------------
#'@description Return to which epidemiological week belongs a given day (only >=2010)
#'@title Return the first day of the Epidemiological Week
#'@param SE string vector with dates to be converted, format 201420
#'@return data.frame with SE and first day. Only works for years >= 2010.
#'@examples
#'SE2date(201512)
#'SE2date(se = c(201401:201409))

SE2date <- function(se){
      if(!class(se[1]) %in% c("numeric","integer")) stop("se should be numeric or integer")

#      load("R/sysdata.rda")
      SE$sem <- SE$Ano*100 + SE$SE
      res <- data.frame(SE = se, ini = as.Date("1970-01-01"))
      for (i in 1:length(res$SE)) res$ini[i] <- SE$Inicio[SE$sem == res$SE[i]]
      res
}


# seqSE ---------------------------------------------------------------------
#'@description Creates a sequence of epidemiological weeks and respective end and final days
#'@title Sequence of epidemiological weeks
#'@param from first week in format 201401
#'@param to first week in format 201401
#'@return data.frame with the epidemiological weeks and corresponding extreme days. 
#'@examples
#'seqSE(201502, 201510)

seqSE <- function(from, to){
#      load("R/sysdata.rda")
      SE$SE <- SE$Ano*100 + SE$SE
      N <- dim(SE)[1]
      
      if (from < SE$SE[1]){
            from <- SE$SE[1]
            warning(paste("first SE set to", from))
      }
      
      if (to > SE$SE[N]){
            to <- SE$SE[N]
            warning(paste("last SE set to", to))
      }
      
      SE[which(SE$SE==from):which(SE$SE==to),]
}


# lastDBdate ---------------------------------------------------------------------
#'@description  Useful to check if the database is up-to-date. 
#'@title Returns the most recent date present in the database table. 
#'@param tab table in the database. Either (sinan, clima_wu, tweet ou historico). 
#'@param city city geocode, if empty, whole dataset is considered. Not implemented yet.
#'@param station wu station. Not implemented yet.
#'@return most recent date 
#'@examples
#'lastDBdate(tab="tweet")
#'lastDBdate(tab="tweet", city=330240)
#'lastDBdate(tab="sinan", city=330240)
#'lastDBdate(tab="clima_wu", station="SBAF")  

lastDBdate <- function(tab, city = NULL, station = NULL){
      if (tab == "sinan"){
            if (is.null(city)) {
                  sql <- "SELECT dt_notific from \"Municipio\".\"Notificacao\""
                  print("Nenhuma cidade indicada, data refere-se ao banco todo")
                  } else {
                        if(nchar(city) == 6) city <- sevendigitgeocode(city)
                        sql <- paste("SELECT dt_notific from \"Municipio\".\"Notificacao\" WHERE municipio_geocodigo = ", city)
                        }
            dd <- dbGetQuery(con,sql)
            date <- max(dd$dt_notific)
      }
      
      if (tab == "tweet"){
            if (is.null(city)) {
                  sql <- paste("SELECT data_dia from \"Municipio\".\"Tweet\"")
                  print("Nenhuma cidade indicada, data refere-se ao banco todo")
            } else {
                  if(nchar(city) == 6) city <- sevendigitgeocode(city)
                  sql <- paste("SELECT data_dia from \"Municipio\".\"Tweet\" WHERE \"Municipio_geocodigo\" = ", city)
                  }
            dd <- dbGetQuery(con,sql)
            date <- max(dd$data_dia)
      }
      
      if (tab == "clima_wu"){
            if (!is.null(city)) stop("indique a estacao desejada")
            if (is.null(station)) {
                  sql <- paste("SELECT data_dia from \"Municipio\".\"Clima_wu\"")
                  print("Nenhuma estacao indicada, data e' a mais recente no banco todo")
            } else {
                  sql1 <- paste("'", stations, "'",sep = "")
                  sql <- paste("SELECT * from \"Municipio\".\"Clima_wu\" WHERE \"Estacao_wu_estacao_id\" = ",sql1)
            }
            dd <- dbGetQuery(con,sql)
            date <- max(dd$data_dia)
      }
      
      if (tab == "historico"){
            if (is.null(city)) {
                  sql <- paste("SELECT \"data_iniSE\" from \"Municipio\".\"Historico_alerta\"")
                  print("Nenhuma cidade indicada, data refere-se ao banco todo")
            } else {
                  sql <- paste("SELECT \"data_iniSE\" from \"Municipio\".\"Historico_alerta\" WHERE municipio_geocodigo = ", city)
            }
            dd <- dbGetQuery(con,sql)
            date <- max(dd$data_iniSE)
      }
      date
}



# DenguedbConnect ---------------------------------------------------------------------
#'@description  Opens a connection to the Project database. 
#'@title Returns the connection to the database. 
#'@return "PostgreSQLConnection" object   
#'@examples
#'con <- DenguedbConnect()
#'dbListTables(con) 
#'dbDisconnect(con)

DenguedbConnect <- function(){
      dbname <- "dengue"
      user <- "dengueadmin"
      password <- "aldengue"
      host <- "localhost"
      
      dbConnect(dbDriver("PostgreSQL"), user=user,
                       password=password, dbname=dbname)
      
}


# sevendigitgeocode ---------------------------------------------------------------------
#'@description  calculates the verification digit of brazilian municipalities. Required 
#'to convert 6 digits to 7 digits geocodes. 
#'@title convert 6 to 7 digits geocodes. 
#'@return 7 digits municipality geocode.   
#'@examples
#'sevendigitgeocode(330455)

sevendigitgeocode <- function(dig){
      peso <- c(1, 2, 1, 2, 1, 2, 0)
      soma <- 0
      digchar <- strsplit(as.character(dig),"")[[1]]
      ndig <- length(digchar)

      if (ndig!=6) stop("this funtion receives 6 digits geocodes only")
      
      for (i in 1:6){
            valor <- as.integer(digchar[i]) * peso[i]
            nvalor <- ifelse(valor < 10, valor, trunc(valor/10) + valor%%10)
            soma <- soma + nvalor
      }
      dv <- ifelse(soma%%10 == 0, 0, 10 - (soma%%10))
      dig*10+dv
}
      

# nafill ------------------------------------
#'@description  collection of imputation procedures 
#'@title methods to substitute NAs.Use the function na.approx from package zoo. 
#'@param v vector with missing elements.
#'@param rule rule for filling the missing cells. "zero" just fills them with 0; "linearinterp"
#' interpolate using tzoo::na.approx. In this case, the tails are not filled. 
#'@param maxgap maximum number of consecutive NAs to fill. Longer gaps will be left i=unchanged
#'@return vector with replaced NA.
#'@examples
#'v <- c(1,2,3,NA,5,6,NA,NA,9,10,NA,NA)
#'nafill(v, rule = "zero")
#'nafill(v, rule = "linear")

nafill <- function(v, rule, maxgap = 4){
      if(sum(is.na(v))!=0) {
            miss <- which(is.na(v))
            if (rule == "zero"){v[miss]<-0}
            if (rule == "linear") {v <- zoo::na.approx(v, method = "linear", maxgap = maxgap, na.rm=FALSE)}
      }
      v
}
      
            
      
