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

