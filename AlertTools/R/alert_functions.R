# PROJETO ALERTA DENGUE -------------------------------------
# Funcoes de calculo do alerta 
# Claudia Codeco 2015
# -----------------------------------------------------------


#fouralert ---------------------------------------------------------------------
#'@title Define conditions to issue a 4 level alert Green-Yellow-Orange-Red.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param obj dataset from the mergedata function.
#'@param pars list with criteria for each color. See example.  
#'@param missing how missing data is treated. "last" if last value is repeated. 
#'It is currently the only option.
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'tw = getTweet(city = c(330455), datasource = "data/tw.rda") 
#'cli = getWU(stations = 'SBRJ', datasource="data/WUdata.rda")
#'cas = getCases(city = c(330455), datasource="data/sinan.rda")
#'casfit<-adjustIncidence(obj=cas)
#'casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)
#'d<- mergedata(cases = casr, tweet = tw, climate = cli)
#'crit <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 14.15, posseas = 18,
#'               crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 0),
#'               crito = c("p1 > 0.9 & inc > preseas", 2, 2),
#'               critr = c("inc > inccrit", 1, 2))
#'ale <- fouralert(d, pars = crit, pop = 1000000)
#' # For a more useful output
#'res <- write.alerta(ale)
#'tail(res)

fouralert <- function(obj, pars, crit, pop, miss="last"){
      le <- dim(obj)[1]
      
      vars = names(pars)

      cyellow = crit[[1]]; corange = crit[[2]]; cred = crit[[3]]
      for (k in vars) {
            if (k != "pdig"){ 
                  cyellow = gsub(k,pars[[k]],cyellow)
                  corange = gsub(k,pars[[k]],corange)
                  cred = gsub(k,pars[[k]],cred)
            }
      }
      incpos = pars$posseas
      
      # calculate incidence"
      if("tcasesmed" %in% names(obj)){
            obj$inc <- obj$tcasesmed / pop * 100000      
      } else{
            obj$inc <- obj$casos / pop * 100000      
      }
      
      # accumulating condition function
      accumcond <- function(vec, lag) {
            le <- length(vec)
            ac <- vec[lag:le]
            for(j in 1:(lag-1)) ac <- rowSums(cbind(ac, vec[(lag-j):(le-j)]), na.rm = TRUE)
            c(rep(NA,(lag-1)), ac)
      }
      
      
      # data.frame to store results"
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
            accun <- as.numeric(cond[2])
            if (accun > 1){
                  ncondtrue <- with(dd, accumcond(condtrue, as.numeric(cond[2])))      
            } else {
                  ncondtrue <- condtrue
            }
            
            cbind(condtrue, ncondtrue)
      }
      
      indices[,c("cytrue", "nytrue")] <- assertcondition(obj , cyellow)
      indices[,c("cotrue", "notrue")] <- assertcondition(obj , corange)
      indices[,c("crtrue", "nrtrue")] <- assertcondition(obj, cred)
            
      # setting the level
      indices$level <- 1
      indices$level[indices$nytrue == as.numeric(cyellow[2])] <-2
      indices$level[indices$notrue == as.numeric(corange[2])] <-3
      indices$level[indices$nrtrue == as.numeric(cred[2])] <-4
      
      # making it orange if now is pRt>crit and in the past 3 weeks, alert was orange at least once 
      for (k in 5:dim(indices)[1]){
            if (indices$level[k] != 4 & indices$cotrue[k] == 1 & 
                any(indices$level[(k-2):k]==3)) indices$level[k]<-3
      }
      
      # making it yellow if inc > posinc, and rt was orange or red at least once in the last 8 weeks 
      for (k in 10:dim(indices)[1]){
                  if (indices$level[k] %in% c(1,2) & obj$inc[k] > incpos & any(indices$level[(k-8):k] >= 3)) indices$level[k]<-2
      }
      # delay turnoff
      delayturnoff <- function(cond, level, d=indices){
            delay = as.numeric(as.character(cond[3]))
            N = dim(d)[1]
            if(delay > 0){
                  cand <- c()
                  for(i in 1:delay){
                        cand <- unique(c(cand, which(d$level==level) + i))
                        cand <- cand[cand<=N]
                  }
                  for (j in cand){
                        d$level[j] <- max(d$level[j], 2) # fica amarelo no delay
                  }
            }
            d
      } 
      indices <- delayturnoff(cond=cred,level=4)
      indices <- delayturnoff(cond=corange,level=3)
      indices <- delayturnoff(cond=cyellow,level=2)
      return(list(data=obj, indices=indices, rules=pars, n=4))      
}

#update.alerta ---------------------------------------------------------------------
#'@title Define conditions to issue a 4 level alert Green-Yellow-Orange-Red for any city or region.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param city city's geocode (6 or 7 digits).
#'@param region full name of 'regional' or state (same name present in the database).
#'@param pars list of parameters for the alerta, defined in config.R
#'@param crit criteria for the alert colors, defined in config.R
#'@param writedb TRUE if it should write into the database, default is FALSE.
#'@param sefinal if given, it stops at that week
#'@return data.frame with the week condition and the number of weeks within the 
#'last lag weeks with conditions = TRUE.
#'@examples
#'res <- update.alerta(city = 330240, pars = pars.RJ, crit = criteria, datasource = con)
#'res <- update.alerta(region = names(pars.RJ), pars = pars.RJ, crit = criteria, datasource = con,sefinal=201613)
#'tail(res$data)

update.alerta <- function(city, region, state, pars, crit, writedb = FALSE, datasource, sefinal){
      
      # update of a single city
      if(!missing (city)) { 
            if(nchar(city) == 6) city <- sevendigitgeocode(city) 
            sql = paste("SELECT geocodigo, codigo_estacao_wu
                        FROM \"Dengue_global\".\"Municipio\" 
                        INNER JOIN \"Dengue_global\".regional_saude
                        ON municipio_geocodigo = geocodigo
                        where geocodigo = '", city, "'", sep="")
            dd <- dbGetQuery(con,sql)
            
      }
      
      if (!missing(region)){ # uma ou mais regionais
            regionais = region
            sql1 = paste("'", regionais[1], sep = "")
            ns = length(regionais)
            if (ns > 1) for (i in 2:ns) sql1 = paste(sql1, regionais[i], sep = "','")
            sql1 <- paste(sql1, "'", sep = "")
            
            sql = paste("SELECT geocodigo, nome, populacao, uf, codigo_estacao_wu, nome_regional
                        FROM \"Dengue_global\".\"Municipio\" 
                        INNER JOIN \"Dengue_global\".regional_saude
                        ON municipio_geocodigo = geocodigo
                        where nome_regional IN (",sql1,")",sep="")
            dd <- dbGetQuery(con,sql)
            if (dim(dd)[1]==0) stop(paste("A regional",region, "nao foi achada. 
                                          Verifique se escreveu certo (por extenso)"))
            
            if(length(unique(dd$uf)) > 1){
                  if (missing(estado)) stop(paste("Existe mais de uma regional com esse nome. 
                                          Especifique o estado (por extenso):", unique(dd$uf)))
                  dd <- subset(dd, uf == estate)
            }
            
      }
      #
      nlugares = dim(dd)[1]
      if (nlugares == 0) stop("A cidade ou regiao nao foi encontrada")
      
      print(paste("sera'feita analise de",nlugares,"cidade(s):"))
      print(dd$geocodigo)      
      
      message("obtendo dados de clima ...")
      estacoes <- unique(dd$codigo_estacao_wu)
      cli <- list()
      for (k in 1:length(estacoes)) cli[[k]] = getWU(stations = estacoes[k],var="temp_min"
                                                   ,datasource = datasource) 
      names(cli) <-estacoes
      
      alertas <- list()
      for (i in 1:nlugares){ # para cada cidade ...

            geocidade = dd$geocodigo[i]
            estacao = dd$codigo_estacao_wu[i]
            print(paste("(Cidade ",i,"de",nlugares,")","Rodando alerta para ", geocidade, "usando estacao", estacao))
            
            dC0 = getCases(city = geocidade, datasource=datasource) # consulta dados do sinan
            dT = getTweet(city = geocidade, lastday = Sys.Date(),datasource=datasource) # consulta dados do tweet
            dW = cli[[estacao]]
            
            d <- mergedata(cases = dC0, climate = dW, tweet = dT)  # junta os dados
            if (!missing(sefinal)) d <- subset(d,SE<=sefinal)
            d$temp_min <- nafill(d$temp_min, rule="linear")  # interpolacao clima NOVO
            d$casos <- nafill(d$casos, "zero") # preenche de zeros o final da serie NOVO
            
            # parsi e' pars de uma unica cidade. 
            # E'preciso extrair no caso de region 
            if (nlugares > 1) {
                  d$nome_regional <- dd$nome_regional[dd$geocodigo==geocidade]
                  parsi <- pars[[d$nome_regional[1]]]
            } else {
                  parsi <- pars
            }
            
#             if(!all(names(parsi) %in% c("pdig","tcrit","inccrit","preseas","posseas",
#                                        "crity","crito","critr"))) {
#                   stop("Verifique o config dessa cidade. Está faltando parametros em pars para rodar o alerta")} 
#             
            
            d <- subset(d,SE<=sefinal)
            # preenchendo potenciais missings
            d$cidade[is.na(d$cidade)==TRUE] <- geocidade
            d$nome[is.na(d$nome)==TRUE] <- na.omit(unique(d$nome))[1]
            d$pop[is.na(d$pop)==TRUE] <- na.omit(unique(d$pop))[1]
            
            pdig <- plnorm((1:20)*7, parsi$pdig[1], parsi$pdig[2])[2:20]
            dC2 <- adjustIncidence(d, pdig = pdig) # ajusta a incidencia
            dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt) # calcula Rt
            
            alerta <- fouralert(dC3, pars = parsi, crit = criteria, pop=dC0$pop[1], miss="last") # calcula alerta
            nome = na.omit(unique(dC0$nome))
            nick <- gsub(" ", "", nome, fixed = TRUE)
            #names(alerta) <- nick
            N = dim(alerta$indices)[1]
            print(paste("nivel do alerta de ",nome,":", alerta$indices$level)[N])
            
            if (nlugares > 1) {
                  alertas[[i]]<-alerta
                  names(alertas)[i]<-nick
            } 
            if (writedb == TRUE) {
                  res <- write.alerta(alerta, write = "db")
                  #write.csv(alerta,file=paste("memoria/", nick,hoje,".csv",sep="")) 
            }
      }
      
      res = alerta
      if(nlugares > 1) res = alertas
      res
}

#alertaRio ---------------------------------------------------------------------
#'@title 4 level alert Green-Yellow-Orange-Red for Rio de Janeiro.
#'@description Yellow is raised when environmental conditions required for
#'positive mosquito population growth are detected, green otherwise.Orange 
#'indicates evidence of sustained transmission, red indicates evidence of 
#'an epidemic scenario.  
#'@param pars parameters of the alert.
#'@param naps subset of vector 0:9 corresponding to the id of the APS. Default is all of them.
#'@param datasource it is the name of the sql connection.
#'@param se last epidemiological week (format = 201401) 
#'@param verbose FALSE
#'@return list with an alert object for each APS.
#'@examples
#'params <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 14.15, posseas = 18)
#'criter <- criteria = list(
#'crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 0),
#'crito = c("p1 > 0.9 & inc > preseas", 2, 2),
#'critr = c("inc > inccrit", 1, 2)
#')
#'alerio2 <- alertaRio(naps = c(0,1), pars=params, crit = criter, datasource=con, se=201604)
#'names(alerio2)


alertaRio <- function(naps = 0:9, pars, crit, datasource, se, verbose = TRUE){
      
      message("obtendo dados de clima e tweets ...")
      tw = getTweet(city = 3304557, datasource = datasource) 
      cli.SBRJ = getWU(stations = 'SBRJ', datasource=datasource)
      cli.SBJR = getWU(stations = 'SBJR', datasource=datasource)
      cli.SBGL = getWU(stations = 'SBGL', datasource=datasource)
      
      if (verbose){
            message("As ultimas datas no banco são:")
            print(paste("Ultimos registros de dengue:",lastDBdate("sinan", city=330455)))
            print(paste("Ultimos registros de tweets:",lastDBdate("tweet", city=330455)))
            print(paste("Ultimos registros de temp em SBRJ:",lastDBdate("clima_wu", station = "SBRJ")))
            print(paste("Ultimos registros de temp em SBJR:",lastDBdate("clima_wu", station = "SBJR")))
            print(paste("Ultimos registros de temp em SBGL:",lastDBdate("clima_wu", station = "SBGL")))
            
            out = readline("deseja continuar (y/n)?")
            if(out == "n") stop("alerta interrompido pelo usuario")
      }
      
      APS <- c("APS 1", "APS 2.1", "APS 2.2", "APS 3.1", "APS 3.2", "APS 3.3"
               , "APS 4", "APS 5.1", "APS 5.2", "APS 5.3")[(naps + 1)]
      
      p <- rev(plnorm(seq(7,20,by=7), pars$pdig[1], pars$pdig[2]))
      
      res <- vector("list", length(APS))
      names(res) <- APS
      for (i in 1:length(APS)){
            message(paste("rodando", APS[i],"..."))
            cas = getCasesinRio(APSid = naps[i], datasource=datasource)
            d <- merge(cas, cli.SBRJ, by.x = "SE", by.y = "SE")
            d <- merge(d, tw, by.x = "SE", by.y = "SE")
            
            casfit<-adjustIncidence(obj=d, pdig = p)
            casr<-Rt(obj = casfit, count = "tcasesmed", gtdist="normal", meangt=3, sdgt = 1)   
            
              
            res[[i]] <- fouralert(obj = casr[casr$SE <= se,], pars = pars, crit = crit, pop=cas$pop[1])
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


plot.alerta<-function(obj, var, cores = c("#0D6B0D","#C8D20F","orange","red"), 
                      ini=201001, fim=202001, ylab=var, yrange){
      
      stopifnot(names(obj) == c("data", "indices", "rules","n"))
      stopifnot(var %in% names(obj$data))
      
      datapos <- which(obj$data$SE <= fim & obj$data$SE >= ini)
      data <- obj$data[datapos,]
      indices <- obj$indices[datapos,]
      pop = obj$data$pop[1]
            
      par(mai=c(0,0,0,0),mar=c(4,4,0,4))
      x <- 1:length(data$SE)
      ticks <- seq(1, length(data$SE), length.out = 8)
      
      if(!missing(yrange)){
            limy = yrange
      } else {
            limy = range(data[,var])
      }
      
      if (obj$n == 2 | obj$n == 4){
            plot(x, data[,var], xlab = "", ylab = "incidência", type="l", ylim= limy, axes=FALSE)
            axis(1, at = ticks, labels = data$SE[ticks], las=3, cex=0.8)
            axis(2, las=2, cex=0.8)
            abline(h=obj$rules$preseas, lty=2, col="darkgreen")
            abline(h=obj$rules$inccrit, lty=2, col="red")
            
            yrange <- range(data[,var])
            for (i in 1:obj$n) {
                  onde <- which(indices$level==i) 
                  if (length(onde))
                        segments(x[onde],0,x[onde],(data[onde,var]),col=cores[i],lwd=3)
            }
            par(new=T)
            plot(data[,"casos"], col="white", type="l",axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
            axis(1, pos=0, lty=0, lab=FALSE)
            axis(4, las=2, cex=0.6 ,col.axis="darkgrey")
            mtext("casos",4, line=3,col="darkgrey", cex=0.7)
            }
}
      
#map.Rio --------------------------------------------------------------------
#'@title Plot the alert map for Rio de Janeiro city.
#'@description Function to plot a map of the alert 
#'@param obj object created by the twoalert and fouralert functions.
#'@param var to be ploted in the graph, usually cases when available.  
#'@param cores colors corresponding to the levels 1, 2, 3, 4.
#'@return a map
#'@examples
#'map.Rio(alerio)

map.Rio<-function(obj, cores = c("green","yellow","orange","red"), data, datasource=con,
                  shapefile = "../CAPS_SMS.shp"){
      
      stopifnot(names(obj[[1]]) == c("data", "indices", "rules","n"))
      
      require(maptools,quietly = TRUE,warn.conflicts = FALSE)
      mapa <- readShapeSpatial(shapefile,ID="COD_AP_SMS")
      d2 <- obj[[1]]$data
      
      # definindo a data do mapa (se nao for dada na funcao, usar a ultima)
      if(missing(data)) {
            ultima_se <- sort(d2$SE,decreasing =TRUE)[1]
      } else {
            ultima_se <- data
            stopifnot (which(d2$SE==ultima_se)>0)
            }
      
      nomesAPS = names(obj)
      lastab <- data.frame(APS = nomesAPS, cor = "grey")
      lastab$cor <- as.character(lastab$cor)
      for (i in 1:10){
            i2 <- obj[[i]]$indices
            lastab$cor[i] <- cores[i2[which(d2$SE==ultima_se),c("level")]]      
      }
      
      lastab$APS2 <-  as.numeric(gsub("APS ","",lastab$APS))
      mapa@data$COD_AP_SMS <- as.numeric(as.character(mapa@data$COD_AP_SMS))
      mapa@data <- merge(mapa@data,lastab,by.x="COD_AP_SMS",by.y="APS2",all=TRUE)
      par(mfrow=c(1,1),mai=c(0,0,0,0),mar=c(4,1,1,1))
      
      plot(mapa,col=mapa@data$cor)
      coords <- coordinates(mapa)
      coords[1,1] <- -43.19
      coords[2,2] <- -22.945
      #text(coords,label=mapa@data$COD_AP_SMS,cex=0.6)
      legend("bottom",fill=cores,c("atividade baixa","condições favoraveis transmissão","transmissão sustentada","atividade alta"),bty="n",cex=0.6)
      par(cex.main=0.7)
      title(paste0( "Mapa MRJ por APs \n"," Semana ",substr(ultima_se,5,6)," de ",
                    substr(ultima_se,1,4)),line=-1)
      
}

#geraMapa --------------------------------------------------------------------
#'@title Plot the alert map for any state.
#'@description Function to plot a map of the alert 
#'@param regionais vector of alerts created by update.alerta.
#'@param se epidemiological week (format = 201610).  
#'@param cores colors corresponding to the levels 1, 2, 3, 4.
#'@param legpos legend position. Default is bottomright. Check the other options in the function legend.
#'@param titulo title of the map
#'@param filename if present, the map is saved.
#'@param dir directory where map will be saved 
#'@param shapefile shapefile containing polygons for the municipalities
#'@param varid shapefile variable indicating the geocode of the municipalities  
#'@param varname name of the variable to be plotted
#'@param resol dpi png resolution, default is 200
#'@return a map
#'@examples
#'reg1 <- update.alerta(region="Noroeste", pars = pars.RJ, datasource = con, sefinal=201613)
#'geraMapa(reg1, data=201613, shapefile="../report/RJ/shape/33MUE250GC_SIR.shp",
#'se = 201613, varid="CD_GEOCMU", titulo="Regionais Norte e Nordeste \n", legpos="topright")

geraMapa<-function(alerta, subset, cores = c("green","yellow","orange","red"), legpos="bottomright", se, datasource=con,
                   shapefile, varid, varname, titulo="", filename, dir="",caption=TRUE, resol = 200){
      
      require(maptools,quietly = TRUE,warn.conflicts = FALSE)
      
      N = length(alerta) # numero de cidades presentes no objeto alerta.
      
      # subset de cidades para o mapa
      if (!missing(subset)){
            ale <- alerta[which(names(alerta) %in% gsub(" ","", subset$nome))]
      } else {ale <- alerta}
      
      # table com as cidades e cores
      lastab <- data.frame(cidade = names(ale), geocodigo = NA, cor = "grey"
                           , nome=NA, short = NA)
      lastab$cor <- as.character(lastab$cor)
      n = length(ale)
      for (i in 1:n){ # por cidade
            ciddata <- ale[[i]]$data
            inddata <- ale[[i]]$indices
            lastab[i,2:5] <- c(ciddata$cidade[1],
                               cores[inddata[which(ciddata$SE==se),c("level")]],
                               ciddata$nome[1], substring(ciddata$nome[1],1,3))
      }
      
      mapa <- readShapeSpatial(shapefile,ID=varid)
      meumapa <- mapa[as.character(mapa@data$CD_GEOCMU) %in% lastab$geocodigo,]
      meumapa@data <- merge(meumapa@data,lastab,by.x=varid,by.y="geocodigo")
      
      if(!missing(filename)){#salvar
            png(paste(dir,filename,sep="")
                , width = 16, height = 15, units="cm", res=resol)
      }
      
      par(mfrow=c(1,1),mai=c(0,0,0,0),mar=c(4,1,1,1))
      plot(meumapa,col=meumapa@data$cor)
      coords <- coordinates(meumapa)
      if (caption == TRUE) text(coords,label=meumapa@data$short,cex=0.6)
      legend(legpos,fill=cores,c("Atividade baixa","Alerta de transmissão","Transmissão sustentada",
                                        "Atividade alta"),bty="n",cex=0.8)
      par(cex.main=0.7)
      title(paste0(titulo, "Semana ",substr(se,5,6)," de ",substr(se,1,4)),line=-1)
      
      if(!missing(filename)) {dev.off()} #salvar
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
      
      d$tweet <- data$tweet
      d$temp_min <- data$temp_min
      
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
                  for (i in 2:length(sepvarnames)) {
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

