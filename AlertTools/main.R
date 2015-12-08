# =============================================================================
# Arquivo de configuracao e excução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
rm(list=c()) # limpar o workspace

library(devtools)
library(foreign)
library("RPostgreSQL", lib.loc="~/R/x86_64-pc-linux-gnu-library/3.0")
devtools::load_all()


# =========================
# Abrindo o banco de dados
# =========================
dbname <- "dengue"
user <- "dengueadmin"
password <- "aldengue"
host <- "localhost"

con <- dbConnect(dbDriver("PostgreSQL"), user=user,
                 password=password, dbname=dbname)

dbListTables(con)

## Verificar a ultima data de notificacao presente no sinan
sql <- paste("SELECT dt_notific from \"Municipio\".\"Notificacao\"")
dd <- dbGetQuery(con,sql)
max(dd$dt_notific)


# Dados fora do banco de dados (ainda direto dos dbfs)
#arqs = c("/Storage/sftp2/alertadengue/DENGNET2010.DBF", "/Storage/sftp2/alertadengue/DENGNET2011.DBF",
#         "/Storage/sftp2/alertadengue/DENGNET2012.DBF","/Storage/sftp2/alertadengue/DENGNET2013.DBF",
#         "/Storage/sftp2/alertadengue/DENGON2014.dbf","/Storage/sftp2/alertadengue/DENGON2015-11-25.dbf")


# ========================================
## PARAMETROS DEFAULT DO MODELO DO ALERTA
# -=======================================

pdig = plnorm((1:20)*7, 2.5016, 1.1013) # prop de notific por semana atraso

# distribuicao do tempo de geracao 
gtdist="normal"
meangt=3
sdgt = 1.2

# (criterio, duracao da condicao para turnon, turnoff)
crity <- c("temp_min > 22 | (temp_min < 22 & p1 > 0.90)", 3, 3) # criterios para alerta amarelo
crito <- c("p1 > 0.95", 3, 2) # criterios para alerta laranja 
critr <- c("inc > 100", 2, 1) # # criterios para alerta vermelho


#==========================================
# ALERTA POR CIDADE
#==========================================
# as funcoes estao definidas para a primeira cidade e repetidas nas outras

#--------------------------
## Campos dos Goytacazes: 
#--------------------------

cidade = 330100
nome = "Campos"
nick = "Campos"
estacoeswu = "SBCP" #Campos
withdivision = FALSE
nlocalidades = 1
pop = 483970

# Run pipeline 
run.pipeline <- function(cidade, nome,nick,estacoeswu,pop){
      dC0 = getCases(city = cidade, withdivision = withdivision, datasource ="db") # consulta dados do sinan
      dT = getTweet(city = cidade, lastday = Sys.Date(),datasource="db") # consulta dados do tweet
      dW = getWU(stations = estacoeswu,var="temp_min",datasource="db") # consulta dados do clima
      
      dC2 <- adjustIncidence(dC0, pdig = pdig) # ajusta a incidencia
      dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt) # calcula Rt
      d <- mergedata(cases = dC3, climate = dW, tweet = dT, ini=201152)  # junta os dados
      alerta <- fouralert(d, cy = crity, co = crito, cr = critr, pop=pop, miss="last") # calcula alerta
      alerta
}

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)

# Generate Figure
figrelatorio <- function(alerta, nick){
      filename = paste("report/",nick,".png",sep="")
      coefs <- coef(lm(alerta$data$casos~alerta$data$tweet))
      
      png(filename, width = 8, height = 15, units="cm", res=300)
      layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(7), 
             heights = c(rep(lcm(4),2), lcm(5)))
      
      par(mai=c(0,0,0,0),mar=c(0,4,1,1))
      plot(alerta$data$casos, type="l", xlab="", ylab="número", axes=FALSE)
      lines(alerta$data$tweet*coefs[2] + coefs[1], col=3, type="l")
      lines(alerta$data$tweet*coefs[2] + coefs[1], col=3, type="h")
      lines(alerta$data$casos)
      axis(2)
      maxy <- max(alerta$data$casos, na.rm=TRUE)
      legend(100, maxy, c("casos de dengue","f(tweets)"),col=c(1,3), lty=1, bty="n",cex=0.7)
      
      plot(alerta$data$temp_min, type="l", xlab="", ylab="temperatura", axes=FALSE)
      axis(2)
      abline(h=22, lty=2)
      
      par(mar=c(4,4,1,1))
      plot.alerta(alerta, var="tcasesmed",ini=201151,fim=max(alerta$data$SE))
      abline(h=100/100000*pop,lty=3)
      dev.off()
      message(paste("Figura salva da cidade", nick))
}


figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#--------------------------
## Cabo Frio
#--------------------------

cidade = 330070
nome = "Cabo Frio"
nick = "Cfrio"
estacoeswu = "SBCB"
withdivision = FALSE
nlocalidades = 1
pop = 208451

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#--------------------------
## Duque de Caxias
#--------------------------
cidade = 330170
nome = "Duque de Caxias"
nick = "Caxias"
estacoeswu = "SBGL"
withdivision = FALSE
nlocalidades = 1
pop = 882729

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#--------------------------
## Macaé
#--------------------------
cidade = 330240 
nome = "Macaé"
nick = "Macae"
estacoeswu = "SBME" #Macae
withdivision = FALSE
nlocalidades = 1
pop = 234628

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#--------------------------
## Nova Iguaçu
#--------------------------
cidade = 330350
nome = "Nova Iguaçu"
nick = "Niguacu"
estacoeswu = "SBAF"
withdivision = FALSE
nlocalidades = 1
pop = 807492

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#--------------------------
## Niteroi
#--------------------------
cidade = 330330
nome = "Niteroi"
nick = "Niteroi"
estacoeswu = "SBRJ"
withdivision = FALSE
nlocalidades = 1
pop = 496696

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Resende
#--------------------------
cidade = 330420
nome = "Resende"
nick = "Resende"
estacoeswu = "SBGW"
withdivision = FALSE
nlocalidades = 1
pop = 125214

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Volta Redonda
#--------------------------
cidade = 330630
nome = "Volta Redonda"
nick = "VRedonda"
estacoeswu = "SBGW"
withdivision = FALSE
nlocalidades = 1
pop = 262970

alerta <- run.pipeline(cidade, nome,nick,estacoeswu,pop)
figrelatorio(alerta, nick)
save(alerta,file=paste("report/",nick,".RData",sep=""))



# ------------------------
# Fechando o banco de dados
# ------------------------
dbDisconnect(con)



