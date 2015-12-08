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
  load("R/sysdata.rda")
  days<-as.Date(as.character(days),format=format)
  for (i in 1:length(days)) {
    week <- SE$SE[days[i] >= SE$Inicio & days[i] <= SE$Termino]
    ano <-  SE$Ano[days[i] >= SE$Inicio & days[i] <= SE$Termino] 
    se = ano*100+week
    sem[i]<-ifelse(length(sem)==0,NA,se)      
  }
  sem
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

      load("R/sysdata.rda")
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
      load("R/sysdata.rda")
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

# 

# write.alerta ---------------------------------------------------------------------
#'@description Internal function used to convert from the two or four alert output
#'to a data.frame to be exported to the server
#'@title Create data.frame to export to the server
#'@param cidade geocode of the city
#'@param localidade name of the locality, if exists, NA otherwise
#'@param alerta output of the twoalert or fouralert functions 
#'@return a data.frame with columns compatible with the SQL table Historico_Alerta  

write.alerta <- function(cidade, localidade, alerta){
      d <- data.frame(SE = alerta$data$SE, nivel = alerta$indices$level)
      d$municipio <- cidade
      d$localidade <- localidade 
      d$data_iniSE <- SE2date(d$SE)[,2] 
      if(!is.null(alerta$data$casos)) d$casos <- alerta$data$casos
      if(!is.null(alerta$data$tcasesmed)) d$casos_est <- alerta$data$tcasesmed
      if(!is.null(alerta$data$tcasesmin)) d$casos_est_min <- alerta$data$tcasesmin
      if(!is.null(alerta$data$tcasesmax)) d$casos_est_max <- alerta$data$tcasesmax
      if(!is.null(alerta$data$p1)) d$pr_rt1 <- alerta$data$p1
      if(!is.null(alerta$data$inc)) d$pr_inc100K <- alerta$data$inc
      d    
}


