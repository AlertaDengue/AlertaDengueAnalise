# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo do alerta 
# Claudia Codeco 2015
# -----------------------------------------------------------


#twoalert --------------------------------------------------------------------
#'@title Define conditions to issue a 2 level alert Green/Yellow.
#'@description This function is meant to be used when case data is absent. 
#'In this scenario, only two levels exist: Yellow if environmental conditions 
#'required for positive mosquito population growth are detected, or if social activity
#'increases. Green otherwise. But clearly, the user can define any rule. 
#'@param obj dataset from the mergedata function containing at least SE, and the 
#'variables used for alert calculation.
#'@param cy criteria to set the yellow alarm, written as a vector with three elements.
#'The first is the condition (see the example), the second is the number of times the
#'condition must be tru to issue the yellow alert, and the third, the number of weeks
#'false to turn off the alert (green).
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw = getTweet(city = c(330455), datasource = "data/tw.rda") 
#'cli = getWU(stations = 'SBRJ', datasource="data/WUdata.rda")
#'d<- mergedata(tweet = tw, climate = cli)
#'crity <- c("temp_min > 22", 3, 3)
#'alerta <- twoalert(d, cy = crity)
#'head(alerta$indices)
#'plot.alerta(alerta, var="temp_min")

twoalert <- function(obj, cy){
      le <- dim(obj)[1] 
      # accumulating condition function
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      # data.frame to store results
      indices <- data.frame(ytrue = rep(NA,le), nytrue = rep(NA,le))
                            
      # calculating each condition (week and accumulated)  

      indices$ytrue <- with(obj, as.numeric(eval(parse(text = cy[1]))))
      indices$nytrue <- with(obj, accumcond(indices$ytrue, as.numeric(cy[2])))
            
      # setting the level
      indices$level <- 1
      indices$level[indices$nytrue == as.numeric(cy[2])] <-2
      for(i in 1:cy[3]){  # delay to turn off
            indices$level[which(indices$nytrue == as.numeric(cy[3])) + i] <-2      
      }
      
      return(list(data=obj, indices=indices, rules=paste(cy), n = 2))      
}


#fouralert ---------------------------------------------------------------------
#'@title Define conditions to issue a 4 level alert Green-Yellow-Orange-Red.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param obj dataset from the mergedata function.
#'@param cy conditions for yellow. 
#'@param co conditions for orange.
#'@param cr conditions for red.
#'@param missing how missing data is treated. "last" if last value is repeated. 
#'It is currently the only option.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw = getTweet(city = c(330455), datasource = "data/tw.rda") 
#'cli = getWU(stations = 'SBRJ', datasource="data/WUdata.rda")
#'cas = getCases(city = c(330455), withdivision = FALSE, datasource="data/sinan.rda")
#'casfit<-adjustIncidence(obj=cas)
#'casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'d<- mergedata(cases = casr, tweet = tw, climate = clima)
#'crity <- c("temp_min > 22", 3, 3)
#'crito <- c("p1 > 0.9", 3, 3)
#'critr <- c("inc > 100", 3, 3)
#'alerta <- fouralert(d, cy = crity, co = crito, cr = critr, pop=1000000)
#'plot.alerta(alerta, var="casos", ylab="casos")
#' # For a more useful output
#'res <- write.alerta(alerta)
#'tail(res)

fouralert <- function(obj, cy, co, cr, pop, miss="last"){
      le <- dim(obj)[1]
      
      # calculate incidence")
      if("tcasesmed" %in% names(obj)){
            obj$inc <- obj$tcasesmed / pop * 100000      
      } else{
            obj$inc <- obj$casos / pop * 100000      
      }
      
      # accumulating condition function")
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      
      # data.frame to store results")
      indices <- data.frame(cytrue = rep(NA,le), nytrue = rep(NA,le),
                            cotrue = rep(NA,le), notrue = rep(NA,le),
                            crtrue = rep(NA,le), nrtrue = rep(NA,le)
                            )
      
      # calculating each condition (week and accumulated)  
      
      assertcondition <- function(dd, cond){
            condtrue <- with(dd, as.numeric(eval(parse(text = cond[1]))))
            if (miss == "last"){
                  mi <- which(is.na(condtrue))
                  for (i in mi[mi!=1]) condtrue[i] <- condtrue[i-1]
            }
            ncondtrue <- with(dd, accumcond(condtrue, as.numeric(cond[2])))
            cbind(condtrue, ncondtrue)
      }
      
      indices[,c("cytrue", "nytrue")] <- assertcondition(obj , cy)
      indices[,c("cotrue", "notrue")] <- assertcondition(obj , co)
      indices[,c("crtrue", "nrtrue")] <- assertcondition(obj, cr)
            
      # setting the level")
      indices$level <- 1
      indices$level[indices$nytrue == as.numeric(cy[2])] <-2
      indices$level[indices$notrue == as.numeric(co[2])] <-3
      indices$level[indices$nrtrue == as.numeric(cr[2])] <-4
      
      
      # delay turnoff")
      delayturnoff <- function(cond, level, d=indices){
            delay = as.numeric(as.character(cond[3]))
            N = dim(d)[1]
            if(delay > 0){
                  cand <- c()
                  for(i in 1:delay){
                        cand <- c(cand, which(d$level==level) + i)
                        cand <- cand[cand<=N]
                  }
                  for (j in cand){
                        d$level[j] <- max(d$level[j], level)
                  }
            }
            d
      } 
      indices <- delayturnoff(cond=cr,level=4)
      indices <- delayturnoff(cond=co,level=3)
      indices <- delayturnoff(cond=cy,level=2)
      return(list(data=obj, indices=indices, rules=paste("cy", ";", "co", ";",
                                                         "cr"),n = 4))      
}


#alertaRio ---------------------------------------------------------------------
#'@title 4 level alert Green-Yellow-Orange-Red for Rio de Janeiro.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param pars parameters of the alert.
#'@param naps subset of vector 0:9 corresponding to the id of the APS. Default is all of them.
#'@param datasource it is the name of the sql connecation.
#'@return list with an alert object for each APS.
#'@examples
#'alerio2 <- alertaRio(naps = c(0,1), datasource=con)
#'names(alerio2)

alertaRio <- function(naps = 0:9, pars = list(meanlog = 2.5016,sdlog=1.1013,
                      crity=c("temp_min > 22", 3, 3), crito=c("p1 > 0.9", 3, 3),
                      critr=c("inc > 100", 3, 2)), datasource){
      
      message("obtendo dados de clima e tweets ...")
      tw = getTweet(city = 3304557, datasource = datasource) 
      cli.SBRJ = getWU(stations = 'SBRJ', datasource=datasource)
      cli.SBJR = getWU(stations = 'SBJR', datasource=datasource)
      cli.SBGL = getWU(stations = 'SBGL', datasource=datasource)
      
      APS <- c("APS 1", "APS 2.1", "APS 2.2", "APS 3.1", "APS 3.2", "APS 3.3"
               , "APS 4", "APS 5.1", "APS 5.2", "APS 5.3")[(naps + 1)]
      
      p <- rev(plnorm(seq(7,20,by=7), pars$meanlog, pars$sdlog))
      
      res <- vector("list", length(APS))
      names(res) <- APS
      for (i in 1:length(APS)){
            message(paste("rodando", APS[i],"..."))
            cas = getCasesinRio(APSid = naps[i], datasource=datasource)
            d <- merge(cas, cli.SBRJ, by.x = "SE", by.y = "SE")
            d <- merge(d, tw, by.x = "SE", by.y = "SE")
            
            casfit<-adjustIncidence(obj=d, pdig = p)
            casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)      
            res[[i]] <- fouralert(casr, cy = pars$crity, co = pars$crito,
                                          cr = pars$critr, pop=cas$pop[1])
      }
            
      res
}


#plot.alert --------------------------------------------------------------------
#'@title Plot the time series of warnings.
#'@description Function to plot the output of 
#'@param obj object created by the twoalert and fouralert functions.
#'@param var to be ploted in the graph, usually cases when available.  
#'@param cores colors corresponding to the levels 1, 2, 3, 4.
#'@return a plot
#'@examples
#'  # See fouralert function


plot.alerta<-function(obj, var, cores = c("#0D6B0D","#C8D20F","orange","red"), ini=201001, fim=202001, ylab=var){
      
      stopifnot(names(obj) == c("data", "indices", "rules","n"))
      stopifnot(var %in% names(obj$data))
      
      datapos <- which(obj$data$SE <= fim & obj$data$SE >= ini)
      data <- obj$data[datapos,]
      indices <- obj$indices[datapos,]
      
      par(mai=c(0,0,0,0),mar=c(4,4,1,1))
      x <- 1:length(data$SE)
      ticks <- seq(1, length(data$SE), length.out = 8)
      
      if (obj$n == 2 | obj$n == 4){
            plot(x, data[,var], xlab = "", ylab = ylab, type="l", axes=FALSE)
            axis(2)
            axis(1, at = ticks, labels = data$SE[ticks], las=3)
            for (i in 1:obj$n) {
                  onde <- which(indices$level==i) 
                  if (length(onde))
                        segments(x[onde],0,x[onde],(data[onde,var]),col=cores[i],lwd=3)
            }
            
            }
}
      

#write.alerta --------------------------------------------------------------------
#'@title Write the alert into the database.
#'@description Function to write the alert results into the database. It only writes one city at a time. It is recommended that the end data is specified.
#'If this is the first time a city is included in the dataset, than use newcity = TRUE. This will force to insert from the beginning. Or if you want to update,
#'you can define the ini-end dates or define the last n weeks.   
#'@param obj object created by the twoalert and fouralert functions.
#'@param write use "db" if data.frame should be inserted into the project database,
#' or "no" (default) if nothing is saved. 
#'@return data.frame with the data to be written. 
#'@examples
#'cli = getWU(stations = 'SBCB', datasource=con)
#'cas = getCases(city = 330020, withdivision = FALSE, datasource=con)
#'casfit<-adjustIncidence(obj=cas)
#'casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'d<- mergedata(cases = casr, tweet = tw, climate = cli)
#'crity <- c("temp_min > 22", 3, 3)
#'crito <- c("p1 > 0.9", 3, 3)
#'critr <- c("inc > 100", 3, 3)
#'alerta <- fouralert(d, cy = crity, co = crito, cr = critr, pop=1000000)
#'res <- write.alerta(alerta, write="no")
#'tail(res)

write.alerta<-function(obj, write = "no", version = Sys.Date()){
      
      stopifnot(names(obj) == c("data", "indices", "rules","n"))
      
      data <- obj$data
      indices <- obj$indices
      
      cidade <- na.omit(unique(obj$data$cidade))
      if (length(cidade) > 1) stop("so posso gravar no bd uma cidade por vez.")
      
      # creating the data.frame with the required columns
      d <- data.frame(SE = data$SE)
      d$data_iniSE <- SE2date(d$SE)$ini
      d$casos_est <- data$tcasesmed
      d$casos_est_min <- data$tcasesICmin
      d$casos_est_max <- data$tcasesICmax
      d$casos <- data$casos
      d$municipio_geocodigo <- na.omit(unique(data$cidade)) # com 7 digitos
      d$p_rt1 <- data$p1
      d$p_rt1[is.na(d$p_rt1)] <- 0
      d$p_inc100k <- data$inc
      d$Localidade_id <- data$localidade
      d$nivel <- indices$level
      d$versao_modelo <- as.character(version)
      
      d$Localidade_id[is.na(d$Localidade_id)] <- 0
      
      # defining the id (SE+julian(versaomodelo)+geocodigo+localidade)
      d$id <- NA
      for (i in 1:dim(d)[1]) {
            versaojulian <- as.character(julian(as.Date(d$versao_modelo[i])))
            d$id[i] <- paste(d$municipio_geocodigo[i], d$Localidade_id[i], d$SE[i], 
                             versaojulian, sep="")
      }
      
      if(write == "db"){
            # se tiver ja algum registro com mesmo geocodigo e SE, esse sera substituido pelo atualizado.
            
            varnames <- "(\"SE\", \"data_iniSE\", casos_est, casos_est_min, casos_est_max, casos,
            municipio_geocodigo,p_rt1,p_inc100k,\"Localidade_id\",nivel,versao_modelo,id)"
            
            sepvarnames <- c("\"SE\"", "\"data_iniSE\"", "casos_est", "casos_est_min", "casos_est_max",
                             "casos","municipio_geocodigo","p_rt1","p_inc100k","\"Localidade_id\"",
                             "nivel","versao_modelo","id")
            
            updates <- paste(sepvarnames[1],"=excluded.",sepvarnames[1],sep="")
            for(i in 2:13) updates <- paste(updates, paste(sepvarnames[i],"=excluded.",
                                                           sepvarnames[i],sep=""),sep=",") 
            
            stringvars = c(2,12)            
            for (li in 1:dim(d)[1]){
                  linha = as.character(d[li,1])
                  for (i in 2:dim(d)[2]) {
                        if (i %in% stringvars & !is.na(as.character(d[li,i]))) {
                              value = paste("'", as.character(d[li,i]), "'", sep="")
                              linha = paste(linha, value, sep=",")
                        }
                        else {linha = paste(linha, as.character(d[li,i]),sep=",")}
                  }
                  linha = gsub("NA","NULL",linha)
                  insert_sql = paste("INSERT INTO \"Municipio\".\"Historico_alerta\" " ,varnames, 
                                     " VALUES (", linha, ") ON CONFLICT ON CONSTRAINT alertas_unicos 
                                     DO UPDATE SET ",updates, sep="")
                  
                  try(dbGetQuery(con, insert_sql))      
            }
      }
      d
}


#write.alertaRio --------------------------------------------------------------------
#'@title Write the Rio de janeiro alert into the database.
#'@description Function to write the alert results into the database. 
#'@param obj object created by the alertRio function and contains alerts for each APS.
#'@param write use "db" if data.frame should be inserted into the project database,
#' or "no" (default) if nothing is saved. 
#'@return data.frame with the data to be written. 
#'@examples
#'alerio2 <- alertaRio(naps = c(1,2), datasource=con)
#'res <- write.alertaRio(alerio2, write="db")
#'tail(res)

write.alertaRio<-function(obj, write = "no", version = Sys.Date()){
      
      listaAPS <- c("APS 1", "APS 2.1", "APS 2.2", "APS 3.1", "APS 3.2", "APS 3.3"
                    , "APS 4", "APS 5.1", "APS 5.2", "APS 5.3")
      APSlabel <- c("1.0", "2.1", "2.2", "3.1", "3.2", "3.3","4.0","5.1","5.2","5.3")
      stopifnot(names(obj) %in% listaAPS)
      
      n <- length(obj)
      dados <- data.frame()
      
      for (i in 1:n){
            data <- obj[[i]]$data
            indices <- obj[[i]]$indices   
            cidade <- data$nome[1]
            # creating the data.frame with the required columns
            d <- data.frame(se = data$SE)
            d$aps <- APSlabel[(data$localidadeid[1]+1)]
            d$data <- SE2date(d$se)$ini
            d$tweet <- data$tweet
            d$casos <- data$casos
            d$casos_est <- data$tcasesmed
            d$casos_est_min <- data$tcasesICmin
            d$casos_est_max <- data$tcasesICmax
            d$tmin <- data$temp_min
            d$rt <- data$Rt
            d$p_rt1 <- data$p1
            d$p_rt1[is.na(d$p_rt1)] <- 0
            d$inc <- data$inc
            d$nivel <- indices$level

            if(write == "db"){
                  
                  # se tiver ja algum registro com mesmo aps e SE, esse sera substituido pelo atualizado.
                  
                  varnames <- "(se,aps,data,tweets,casos,casos_est,casos_estmin,casos_estmax,tmin,rt,prt1,
                  inc,nivel)"
                  
                  sepvarnames <- c("se","aps","data","tweets","casos","casos_est","casos_estmin","casos_estmax",
                                   "tmin","rt","prt1","inc","nivel")
                  
                  updates <- paste(sepvarnames[1],"=excluded.",sepvarnames[1],sep="")
                  for(i in 2:length(sepvarnames)) updates <- paste(updates, paste(sepvarnames[i],"=excluded.",
                                                                                  sepvarnames[i],sep=""),sep=",") 
                  
                  
                  stringvars = c(2,3)            
                  for (li in 1:dim(d)[1]){
                        linha = as.character(d[li,1])
                        for (i in 2:length(sepvarnames)) {
                              if (i %in% stringvars & !is.na(as.character(d[li,i]))) {
                                    value = paste("'", as.character(d[li,i]), "'", sep="")
                                    linha = paste(linha, value, sep=",")
                              }
                              else {linha = paste(linha, as.character(d[li,i]),sep=",")}
                        }
                        linha = gsub("NA","NULL",linha)
                        linha = gsub("NaN","NULL",linha)
                        insert_sql2 = paste("INSERT INTO \"Municipio\".\"alerta_mrj\" " ,varnames, 
                                            " VALUES (", linha, ") ON CONFLICT ON CONSTRAINT unique_aps_se DO
                               UPDATE SET ",updates, sep="")
                        
                        try(dbGetQuery(con, insert_sql2))
                  }
            }
            dados <- rbind(dados,d)
      }
      dados
}
      
      

#isOrange --------------------------------------------------------------------
#'@title Raise orange alert if sustained transmission is detected.
#'@description "Orange" is defined by effective reproductive number greater than 1. 
#'Rt must be computed before using this function.
#'@param obj object created by the Rt function.
#'@param pvalue probability of wrongly rejecting the hypothesis Rt > 1   
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'cas = getCases(city = c(330455), withdivision = FALSE, datasource="data/sinan.rda")
#'casfit<-adjustIncidence(obj=cas)
#'casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'ora = isOrange(obj = casr, pvalue = 0.9, lag= 3) 
#'head(ora)
#'x = 1:length(ora$SE)
#'plot(x, ora$Rt, type="l", xlab= "weeks", ylab = "Rt")
#'lines(x, ora$upr, lty = 3)
#'lines(x, ora$lwr, lty = 3)
#'abline(h = 1, col =2)
#'points(x[ora$oweek==1], ora$Rt[ora$oweek==1], col="orange", pch=16)

isOrange <- function(obj, pvalue = 0.9, lag=3){
  
  if(!("p1" %in% names(obj))) stop("obj must be created by an Rt function")
  
  obj$oweek <- as.numeric(obj$p1 > pvalue)
  
  # lag weeks accumulated condition
  le <- dim(obj)[1]
  ac <- obj$oweek[lag:le]
  for(i in 1:(lag-1)) ac <- ac+obj$oweek[(lag-i):(le-i)]
  obj$oacc <- c(rep(NA,(lag-1)),ac)
  
  return(obj)
}


#isRed --------------------------------------------------------------------
#'@title Raise red alert if incidence reaches above a threshold. 
#'@description "Red" indicates high dengue incidence, defined by a threshold provided 
#'by the user. The WHO recommends 300 per 100.000. 
#'@param obj case count dataset generated by the getcase (ajusted or not).
#'@param pop population of the area.
#'@param adjust TRUE if adjusting incidence is required. FALSE if not.   
#'@param ccrit incidence threshold (per 100.000).
#'@param lag count the number of weeks within the last lag weeks with conditions = TRUE.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE
#'@examples
#'cas = getCases(city = c(330455), withdivision = FALSE, datasource="data/sinan.rda")
#'casfit<-adjustIncidence(obj=cas)
#'red = isRed(casfit, pop = 30000, ccrit = 30, lag=3)
#'x = 1:length(red$SE)
#'plot(x, red$inc, type="l", xlab= "weeks", ylab = "incidence")
#'abline(h = 30, col =2)
#'points(x[red$rweek==1], red$inc[red$rweek==1], col="red", pch=16)

isRed <- function(obj, pop, ccrit=100, lag=3){
  
  if("tcasesICmin" %in% names(obj)) {}
  else stop("please carry out the incidence adjustment first.")
      
  inc <- obj$tcasesICmin / pop * 100000
  i1 <- inc > ccrit
  # 3 weeks accumulated condition
  le <- length(i1)
  ac <- i1[lag:le]
  for(i in 1:(lag-1)) ac <- ac+i1[(lag-i):(le-i)]
  
  obj$inc <- inc
  obj$rweek <- as.numeric(i1)
  obj$racc <- c(rep(NA,(lag-1)),ac)
  
  return(obj)
  }



# ####### pedaço de codigo para testar limiar
# pred<- prediction(predictions = alerta$data$temp_min, labels = alerta$data$p1d,
#                   label.ordering = c(0,1))
# perf<- performance(pred, "ppv")
# cuts <- perf@x.values[[1]][which.max(perf@y.values[[1]])]
# plot(perf,ylim=c(0,0.45), xlab = "Temperature cutoff",axes=FALSE) # 22.5
# abline(v=21)
# perf<- performance(pred, "spec")
# plot(perf)
# perf<- performance(pred, "sens")
# plot(perf)

