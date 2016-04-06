# =============================================================================
# Arquivo de configuracao e execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
rm(list=c()) # limpar o workspace

library(foreign)
library("RPostgreSQL")
library(AlertTools)
mapadados <- read.csv("report/ERJdata.csv")
mapadados$nivel <- 0
hoje = Sys.Date()

mapadados <- read.csv("../../AlertaDengueAnalise/EPRdata.csv")
head(mapadados)
mapadados$cor="grey"
write.csv(mapadados,file="../../AlertaDengueAnalise/EPRdata.csv")
# =========================
# Abrindo o banco de dados
# =========================
con <- DenguedbConnect()
dbListTables(con)


# -------------------------------------------
## Verificacoes: os dados estao atualizados?
# -------------------------------------------

## Ultima data de notificacao presente no sinan
lastDBdate("sinan")
## Ultima data de notificacao presente no tweet
lastDBdate("tweet")
## Ultima data de notificacao presente no tweet
lastDBdate("clima_wu")
## Ultima data de notificacao presente no historico do alerta
lastDBdate("historico")
# cidade especifica: 
lastDBdate("sinan", city=330240)
lastDBdate("sinan", city=330455)

# ========================================
# Quer salvar o resultado do Alerta no Banco de Dados? 
escreverBD <- TRUE   # use TRUE apenas quando tiver seguro pois irá aparecer no mapa


# ========================================
## PARAMETROS DEFAULT DO MODELO DO ALERTA
# -=======================================

#pdig = plnorm((1:20)*7, 2.5016, 1.1013) # prop de notific por semana atraso
# PS. Esses ajustes vem de modelos lognormais ajustados aos dados. Apenas o da regiao norte, que no original
# era muito atrasado, decidimos usar o da regiao metropolitana (segundo mais atrasado). Isso porque estava
# gerando um aumento de 20 vezes no numero de casos (original da regiao Norte: 3.299, 0.8354). 
pdigERJ <- data.frame(regiao = c("Lagos","Noroeste","Norte","Serrana","BaixLitor","Metropol","CentroSul",
                                 "MedParaiba","CostaVerde","Capital"),
                      media =  c(2.477091, 2.791400, 2.997765, 2.788100, 2.294574, 2.997765, 2.743135, 
                                 2.744345, 2.044211, 2.5016), 
                      sd = c(0.8925744, 0.9913278,  0.7859499,  0.7627551,  0.8221244,  0.7859499,
                             0.8294707,  0.7612805, 0.9251224, 1.1013)
                      )

 
# distribuicao do tempo de geracao 
gtdist="normal"
meangt=3
sdgt = 1.2

# (criterio, duracao da condicao para turnon, turnoff)
crity <- c("temp_min > 22 | (temp_min < 22 & p1 > 0.90)", 3, 3) # criterios para alerta amarelo
crito <- c("p1 > 0.95", 3, 3) # criterios para alerta laranja 
critr <- c("inc > 100", 2, 2) # # criterios para alerta vermelho


#==========================================
# ALERTA POR CIDADE
#==========================================

# Definir a data alvo para o relatorio. A principio, 2 semanas de atraso, depois vemos como 
# melhorar isso
datafim = 201610

#------------------------------
# REGIÃO 02 - NORTE FLUMINENSE
regiao = "Norte"
#------------------------------
# Campos dos Goytacazes: 
#-----------------------------
# PS. As funcoes estao definidas para essa cidade e repetidas nas outras

cidade = 330100
nick = "Campos"
estacoeswu = "SBCP" #Campos

# Run pipeline funtion
run.pipeline <- function(cidade,nick,estacoeswu, regiao, escreverBD=escreverBD){
  dC0 = getCases(city = cidade, datasource = con) # consulta dados do sinan
  dT = getTweet(city = cidade, lastday = Sys.Date(),datasource = con) # consulta dados do tweet
  dW = getWU(stations = estacoeswu,var="temp_min",datasource = con) # consulta dados do clima
  
  d <- mergedata(cases = dC0, climate = dW, tweet = dT, ini=201352)  # junta os dados
  d$temp_min <- nafill(d$temp_min, rule="linear")  # interpolacao clima NOVO
  d$casos <- nafill(d$casos, "zero") # preenche de zeros o final da serie NOVO
  
  d <- subset(d,SE<=datafim)
  pdig <- plnorm((1:20)*7, pdigERJ$media[pdigERJ$regiao == regiao], 
                 pdigERJ$sd[pdigERJ$regiao == regiao])[2:20]
  dC2 <- adjustIncidence(d, pdig = pdig) # ajusta a incidencia
  dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt) # calcula Rt
  
  alerta <- fouralert(dC3, cy = crity, co = crito, cr = critr, pop=dC0$pop[1], miss="last") # calcula alerta
  
  if (escreverBD == TRUE) {
    res <- write.alerta(alerta, write = "db")
    write.csv(alerta,file=paste("memoria\\", cidade,hoje,".csv",sep="")) 
  }
  # informacao para o mapa
  alerta
}

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)

# Generate Figure
figrelatorio <- function(alerta, nick, mapadados){
      filename = paste("report/",nick,".png",sep="")
      #coefs <- coef(lm(alerta$data$casos~alerta$data$tweet))
      
      png(filename, width = 16, height = 15, units="cm", res=100)
       layout(matrix(1:3, nrow = 3, byrow = TRUE), widths = lcm(15), 
              heights = c(rep(lcm(4),2), lcm(5)))

      # separação dos eixos para casos de dengue e tweets 
    
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      
      plot(alerta$data$casos, type="l", xlab="", ylab="", axes=FALSE)
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(2)
      mtext(text="Casos de Dengue", line=2.5,side=2, cex = 0.7)
      maxy <- max(alerta$data$casos, na.rm=TRUE)
      legend(25, maxy, c("casos de dengue","tweets"),col=c(1,3), lty=1, bty="n",cex=0.7)
      par(new=T)
      plot(alerta$data$tweet, col=3, type="l", axes=FALSE , xlab="", ylab="" ) #*coefs[2] + coefs[1]
      lines(alerta$data$tweet, col=3, type="h") #*coefs[2] + coefs[1]
      axis(1, pos=0, lty=0, lab=FALSE)
      axis(4)
      mtext(text="Tweets", line=2.5, side=4, cex = 0.7)
      
      #original
      #plot(alerta$data$casos, type="l", xlab="", ylab="número", axes=FALSE)
      #lines(alerta$data$tweet*coefs[2] + coefs[1], col=3, type="l")
      #lines(alerta$data$tweet*coefs[2] + coefs[1], col=3, type="h")
      #lines(alerta$data$casos)
      #axis(2)
      #maxy <- max(alerta$data$casos, na.rm=TRUE)
      #legend(100, maxy, c("casos de dengue","f(tweets)"),col=c(1,3), lty=1, bty="n",cex=0.7)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,3))
      plot(alerta$data$temp_min, type="l", xlab="", ylab ="Temperatura",axes=FALSE)
      axis(2)
      abline(h=22, lty=2)
      
      par(mai=c(0,0,0,0),mar=c(1,4,0,4))
      #par(mar=c(4,4,1,1))
      plot.alerta(alerta, var="tcasesmed",ini=201352,fim=max(alerta$data$SE))
      abline(h=100/100000*alerta$data$pop[1],lty=3)
      dev.off()
      message(paste("Figura salva da cidade", nick))
      mapadados$SE[mapadados$CD_GEOCMU==alerta$data$cidade[1]]<- max(alerta$data$SE)
      mapadados$nivel[mapadados$CD_GEOCMU==alerta$data$cidade[1]]<-tail(alerta$indices$level,1)
      mapadados
}

mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Carapebus
#--------------------------
cidade = 330093 
nick = "Carapebus"
estacoeswu = "SBME" #Macae

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Cardoso Moreira
#--------------------------
cidade = 330115 
nick = "CMoreira"
estacoeswu = "SBCP" # Campos

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Conceição de Macabu
#--------------------------
cidade = 330140 
nick = "CMacabu"
estacoeswu = "SBME" #Macae

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Macaé
#--------------------------
cidade = 330240 
nick = "Macae"
estacoeswu = "SBME" #Macae

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Quissamã
#--------------------------
cidade = 330415 
nick = "Quissama"
estacoeswu = "SBCP" # Campos

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## São Francisco de Itabapoana
#--------------------------
cidade = 330475 
nick = "SFItabapoana"
estacoeswu = "SBCP" # Campos

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## São Fidélis
#--------------------------
cidade = 330480 
nick = "SFidelis"
estacoeswu = "SBCP" # Campos

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## São João da Barra 
#--------------------------
cidade = 330500 
nick = "SJBarra"
estacoeswu = "SBCP" # Campos

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
# REGIÃO 01 - NOROESTE FLUMINENSE
regiao = "Noroeste"
#------------------------------
## Aperibé
# -----------------------------
cidade = 330015
nick = "Aperibe"
estacoeswu = "SBCP"   # campos: encontrar opção melhor
regiao = "Norte"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Bom Jesus de Itabapoana
# -----------------------------
cidade = 330060
nick = "BJItabapoana"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Cambuci
# -----------------------------
cidade = 330090
nick = "Cambuci"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Italva
# -----------------------------
cidade = 330205
nick = "Italva"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Itaocara
# -----------------------------
cidade = 330210
nick = "Itaocara"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Itaperuna
# -----------------------------
cidade = 330220
nick = "Itaperuna"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Laje do Muriaé
# -----------------------------
cidade = 330230
nick = "LMuriae"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Miracema
# -----------------------------
cidade = 330300
nick = "Miracema"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Natividade
# -----------------------------
cidade = 330310
nick = "Natividade"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Porciúncula
# -----------------------------
cidade = 330410
nick = "Porciuncula"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Santo Antônio de Pádua
# -----------------------------
cidade = 330470
nick = "SAPadua"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## São José de Ubá
# -----------------------------
cidade = 330513
nick = "SJUba"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#------------------------------
## Varre-Sai
# -----------------------------
cidade = 330615
nick = "VSai"
estacoeswu = "SBCP"   # campos: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

# ------------------------------
#REGIÃO 03 - REGIÂO SERRANA
regiao = "Serrana"
#--------------------------------
## Carmo
# -----------------------------
cidade = 330120
nick = "Carmo"
estacoeswu = "SBJF"   # juiz de fora: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Cantagalo
# -----------------------------
cidade = 330110
nick = "Cantagalo"
estacoeswu = "SBME"   # macaé: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## São Sebastião do Alto
# -----------------------------
cidade = 330530
nick = "SSAlto"
estacoeswu = "SBME"   # macaé: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Santa Maria Madalena
# -----------------------------
cidade = 330460
nick = "SMMadalena"
estacoeswu = "SBME"   # macaé: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Sumidouro
# -----------------------------
cidade = 330570
nick = "Sumidouro"
estacoeswu = "SBJF"   # juiz de fora: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Duas Barras
# -----------------------------
cidade = 330160
nick = "DBarras"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Cordeiro
# -----------------------------
cidade = 330150
nick = "Cordeiro"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Macuco
# -----------------------------
cidade = 330245
nick = "Macuco"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Trajano de Moraes
# -----------------------------
cidade = 330590
nick = "TMoraes"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## São José do Vale do Rio Preto
# -----------------------------
cidade = 330515
nick = "RioPreto"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Nova Friburgo
# -----------------------------
cidade = 330340
nick = "Friburgo"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

# -----------------------------
## Petropolis
# -----------------------------
cidade = 330390
nick = "Petropolis"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

# -----------------------------
## Teresopolis
# -----------------------------
cidade = 330580
nick = "Teresopolis"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------------
## Bom Jardim
# -----------------------------
cidade = 330050
nick = "BomJardim"
estacoeswu = "SBGL"   # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#-------------------------------
# REGIÃO 04 - BAIXADA LITORANEA
regiao = "BaixLitor"
#-------------------------------
## Araruama
#-------------------------------

cidade = 330020
nick = "Araruama"
estacoeswu = "SBCB" # Cabo Frio

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Armação dos Búzios
#-------------------------------

cidade = 330023
nick = "Buzios"
estacoeswu = "SBCB" # Cabo Frio

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Arraial do Cabo
#-------------------------------

cidade = 330025
nick = "Arraial"
estacoeswu = "SBCB" # Cabo Frio

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Cabo Frio
#-------------------------------

cidade = 330070
nick = "Cfrio"
estacoeswu = "SBCB"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Casimiro de Abreu
#-------------------------------

cidade = 330130
nick = "Casimiro"
estacoeswu = "SBME" # Macaé

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Iguaba Grande
#-------------------------------

cidade = 330187
nick = "Iguaba"
estacoeswu = "SBES" # Santo Antonio de Padua

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## São Pedro da Aldeia
#-------------------------------

cidade = 330520
nick = "SPAldeia"
estacoeswu = "SBES"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Saquarema
#-------------------------------

cidade = 330550
nick = "Saquarema"
estacoeswu = "SBCB" # Cabo Frio

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#-------------------------------
## Silva Jardim
#-------------------------------

cidade = 330560
nick = "SJardim"
estacoeswu = "SBME" # Macaé

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#----------------------------
## Rio das Ostras
#-------------------------------

cidade = 330452
nick = "Ostras"
estacoeswu = "SBME" # Macaé

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#-------------------------------
# REGIÃO 05 - METROPOLITANA
regiao = "Metropol"
#--------------------------
## Belford Roxo
#--------------------------
cidade = 330045
nick = "BRoxo"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Cachoeiras de Macacu
#--------------------------
cidade = 330080
nick = "CMacacu"
estacoeswu = "SBRJ" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Duque de Caxias
#--------------------------
cidade = 330170
nick = "Caxias"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Guapimirim
#--------------------------
cidade = 330185
nick = "Guapimirim"
estacoeswu = "SBGL" # rio de janeiro: encontrar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Itaboraí
#--------------------------
cidade = 330190
nick = "Itaborai"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Itaguaí
#--------------------------
cidade = 330200
nick = "Itaguai"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Japeri
#--------------------------
cidade = 330227
nick = "Japeri"
estacoeswu = "SBAF" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Magé
#--------------------------
cidade = 330250
nick = "Mage"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Marica
#--------------------------
cidade = 330270
nick = "Marica"
estacoeswu = "SBRJ"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Mesquita
#--------------------------
cidade = 330285
nick = "Mesquita"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Nilópolis
#--------------------------
cidade = 330320
nick = "Nilopolis"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Niteroi
#--------------------------
cidade = 330330
nick = "Niteroi"
estacoeswu = "SBRJ"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Nova Iguaçu
#--------------------------
cidade = 330350
nick = "Niguacu"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Paracambi
#--------------------------
cidade = 330360
nick = "Paracambi"
estacoeswu = "SBGL" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Queimados
#--------------------------
cidade = 330414
nick = "Queimados"
estacoeswu = "SBAF"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Rio Bonito
#--------------------------
cidade = 330430
nick = "RBonito"
estacoeswu = "SBRJ" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## São Gonçalo
#--------------------------
cidade = 330490
nick = "SGoncalo"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## São João de Meriti
#--------------------------
cidade = 330510
nick = "SJMeriti"
estacoeswu = "SBGL"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Seropédica
#--------------------------
cidade = 330510
nick = "Seropedica"
estacoeswu = "SBSC" # rio de janiero: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Tanguá
#--------------------------
cidade = 330575
nick = "Tangua"
estacoeswu = "SBRJ" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Rio de Janeiro
regiao = "Capital"
#--------------------------
cidade = 330455
nick = "RJ"
estacoeswu = "SBRJ" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#-------------------------------
# REGIÃO 06 - CENTRO-SUL
regiao = "CentroSul"
#--------------------------
## Areal
#--------------------------
cidade = 330022
nick = "Areal"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Comendador Levy Gasparian
#--------------------------
cidade = 330095
nick = "CLGasparian"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Engenheiro Paulo de Frontin
#--------------------------
cidade = 330180
nick = "EPFrontin"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Mendes
#--------------------------
cidade = 330280
nick = "Mendes"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Miguel Pereira
#--------------------------
cidade = 330290
nick = "MPereira"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Paraíba do Sul
#--------------------------
cidade = 330370
nick = "PSul"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Paty do Alferes
#--------------------------
cidade = 330385
nick = "PAlferes"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Sapucaia
#--------------------------
cidade = 330540
nick = "Sapucaia"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Três Rios
#--------------------------
cidade = 330600
nick = "TRios"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Vassouras
#--------------------------
cidade = 330620
nick = "Vassouras"
estacoeswu = "SBJF" # juiz de fora

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#-------------------------------
# REGIÃO 07 - MÉDIO PARAÍBA
regiao =  "MedParaiba"
#--------------------------
## Barra Mansa
#--------------------------
cidade = 330040
nick = "BMansa"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Barra do Piraí
#--------------------------
cidade = 330330
nick = "BPirai"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Itatiaia
#--------------------------
cidade = 330250
nick = "Itatiaia"
estacoeswu = "SBGW"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Pinheiral
#--------------------------
cidade = 330395
nick = "Pinheiral"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Piraí
#--------------------------
cidade = 330400
nick = "Pirai"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Porto Real
#--------------------------
cidade = 330411
nick = "PReal"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Quatis
#--------------------------
cidade = 330412
nick = "Quatis"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Resende
#--------------------------
cidade = 330420
nick = "Resende"
estacoeswu = "SBGW"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Rio Claro
#--------------------------
cidade = 330440
nick = "RClaro"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Rio das Flores
#--------------------------
cidade = 330450
nick = "RFlores"
estacoeswu = "SBJF"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Valença
#--------------------------
cidade = 330610
nick = "Valenca"
estacoeswu = "SBJF"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Volta Redonda
#--------------------------
cidade = 330630
nick = "VRedonda"
estacoeswu = "SBGW"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))


#-------------------------------
# REGIÃO 08 - COSTA VERDE
regiao = "CostaVerde"
#--------------------------
## Angra dos Reis
#--------------------------
cidade = 330010 
nick = "Angra"
estacoeswu = "SBSC" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Mangaratiba
#--------------------------
cidade = 330260 
nick = "Mangaratiba"
estacoeswu = "SBSC" # rio de janeiro: procurar opção melhor

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))

#--------------------------
## Paraty
#--------------------------
cidade = 330380 
nick = "Paraty"
estacoeswu = "SBSC"

alerta <- run.pipeline(cidade, nick,estacoeswu,regiao=regiao,escreverBD = escreverBD)
mapadados <- figrelatorio(alerta, nick, mapadados)
save(alerta,file=paste("report/",nick,".RData",sep=""))



# ------------------------
# Guardando resultados do historico no banco de dados
# ------------------------

save(mapadados,file="mapadados.Rdata")
# Falta completar essa parte.


# ------------------------
# Fechando o banco de dados
# ------------------------
dbDisconnect(con)




