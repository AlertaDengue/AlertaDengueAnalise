# ====================================================
# Arquivo de configuracao do Alerta Dengue
# ====================================================

# O default e' calcular o Alerta para a semana anterior
hoje = Sys.Date()
      
# ====================================================
# Parametros que sao fixos
# ====================================================
gtdist="normal"; meangt=3; sdgt = 1.2   # # distribuicao do tempo de geracao 

# Regras: (criterio, duracao da condicao para turnon, turnoff)
crity <- c("temp_min > tcrit | (temp_min < tcrit & p1 > 0.85)", 3, 3) # criterios para alerta amarelo
crito <- c("p1 > 0.9", 3, 3) # criterios para alerta laranja 
critr <- c("inc > inccrit", 2, 2) # # criterios para alerta vermelho


# =====================================================
# Funcao que roda o pipeline por cidade ou regiao
# =====================================================

run.pipeline <- function(lugar, write = escreverBD, sfigs = salvafiguras, smapa = salvamapa, sefinal = datafim){
      
      nlugares <- length(lugar$geocodigo)
      
      for (i in 1:nlugares){
            cidade = lugar$geocodigo[i]
            print(paste("Rodando alerta para ", cidade))
            estacao = lugar$estacao
            dC0 = getCases(city = cidade, datasource = con) # consulta dados do sinan
            dT = getTweet(city = cidade, lastday = Sys.Date(),datasource = con) # consulta dados do tweet
            dW = getWU(stations = estacao,var="temp_min",datasource = con) # consulta dados do clima
            d <- mergedata(cases = dC0, climate = dW, tweet = dT, ini=201352)  # junta os dados
            d$temp_min <- nafill(d$temp_min, rule="linear")  # interpolacao clima NOVO
            d$casos <- nafill(d$casos, "zero") # preenche de zeros o final da serie NOVO
            d <- subset(d,SE<=sefinal)
            d$cidade[is.na(d$cidade)==TRUE] <- cidade
            d$nome[is.na(d$nome)==TRUE] <- na.omit(unique(d$nome))[1]
            d$pop[is.na(d$pop)==TRUE] <- na.omit(unique(d$pop))[1] 
            pdig <- plnorm((1:20)*7, lugar$pdig[1], lugar$pdig[2])[2:20]
            dC2 <- adjustIncidence(d, pdig = pdig) # ajusta a incidencia
            dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt) # calcula Rt
            
            cy = c(gsub("tcrit", lugar$tcrit, crity[1]), crity[2], crity[3])
            cr = c(gsub("inccrit", lugar$inccrit, critr[1]), critr[2], critr[3])
            alerta <- fouralert(dC3, cy = cy, co = crito, cr = cr, pop=dC0$pop[1], miss="last") # calcula alerta
      
            nick <- gsub(" ", "", na.omit(unique(dC0$nome)), fixed = TRUE)
            if (write == TRUE) {
                  res <- write.alerta(alerta, write = "db")
                  write.csv(alerta,file=paste("memoria/", nick,hoje,".csv",sep="")) 
            }
            
            if (sfigs == TRUE)  figrelatorio(alerta)      
            #message(paste("alerta gerado para cidade",cidade))
      }
      alerta
}

# ===========================
# Generate Figure
# ===========================

figrelatorio <- function(alerta){
      
      # nome do arquivo para salvar a figura
      nick <- gsub(" ", "", na.omit(unique(alerta$data$nome)), fixed = TRUE)
      filename = paste("report/",nick,".png",sep="")
      #filename = paste(nick,".png",sep="")
      
      # codigo da figura
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
}


#########################################################
## Alerta Estado do Rio de Janeiro 
#########################################################

#"Varre-Sai", "Porciúncula", "Natividade", "Bom Jesus do Itabapoana", "Itaperuna", "Laje do Muriaé",
#"São José do Ubá", "Miracema", "Santo Antônio de Pádua", "Cambuci", "Italva", "Aperibé", "Itacoara"
RJ.noroeste <- list(geocodigo=c(330615,330410,330310,330060,330220,330230,330513,330300,330470,
                                330090,330205,330015,330210),
                       estacao = "SBCP", # Campos
                       pdig = c(2.791400,0.9913278),
                       tcrit = 22, inccrit = 100)

#"São Francisco de Itabapoana", "Cardoso Moreira", "São Fidelis", "Campos dos Goytacazes", 
#"São João da Barra", "Conceição de Macabu", "Carapebus", "Quissamã", "Macaé")
RJ.norte <- list(geocodigo=c(330475,330115,330480,330100,330500,330140,330093,330415,330240),
                    estacao = "SBCP", # Campos
                    pdig = c(2.997765,0.7859499),
                    tcrit = 22, inccrit = 100)


#"Carmo", "Cantagalo", "São Sebatião do Alto", "Santa Maria Madalena", "Sumidouro", "Duas Barras",
#"Cordeiros", "Macuco", "Trajano de Morais","São José do Vale do Rio Preto", "Petrópolis", "Teresópolis", "Nova Friburgo", "Bom Jardim")
RJ.serrana <- list(geocodigo=c(330120,330110,330530,330460,330570,330160,330150,330245,330590,330515,330390,330580,330340,330050),
            estacao = "SBGL",  # Galeao
            pdig = c(2.788100,0.7627551),
            tcrit = 22, inccrit = 100)

#"Rio das Ostras", "Casimiro de Abreu", "Silva Jardim", "Saquarema", "Araruama", "Cabo Frio", "São Pedro da Aldeia", "Iguaba Grande",
#"Arraial do Cabo", "Armação dos Búzios")
RJ.lagos <- list(geocodigo=c(330452,330130,330560,330550,330020,330070,330520,330187,330025,330023),
            estacao = "SBCB", # Cabo Frio
            pdig = c(2.294574,0.8221244),
            tcrit = 22, inccrit = 100)

#"Belford Roxo", "Duque de Caxias", "Guapimirim", "Itaboraí", "Japeri", "Magé", "Maricá", "Mesquita",
#"Nilópolis", "Niterói", "Nova Iguaçú", "Paracambi", "Queimados", "São Gonçalo", "São João de Meriti",
#"Seropédica", "Tanguá", "Itaguaí", "Rio Bonito", "Cachoeiras de Macacu")
RJ.metropol <- list(geocodigo=c(330045,330170,330185,330190,330227,330250,330270,330285,330320,330330,330350,330360,330414,330490,330510,
                                330555,330575,330200,330430,330080),
            estacao = "SBGL", # Galeao
            pdig = c(2.997765,0.7859499),
            tcrit = 22, inccrit = 100)

#"Sapucaia", "Três Rios", "Comendador Levy Gasparian", "Paraíba do Sul", "Areal", "Paty do Alferes", "Vassouras", "Mendes",
#"Engenheiro Paulo de Frontin", "Miguel Pereira"
RJ.centrosul <- list(geocodigo=c(330540,330600,330095,330370,330022,330385,330620,330280,330180,330290),
            estacao = "SBGL", # Galeao
            pdig = c(2.743135,0.8294707),
            tcrit = 22, inccrit = 100)

#"Rio das Flores", "Valença", "Barra do Piraí", "Itatiaia", "Resende", "Quatis", "Porto Real", "Barra Mansa","Volta Redonda", "Pinheiral", "Piraí", "Rio Claro")
RJ.medparaiba <- list(geocodigo=c(330450,330610,330030,330225,330420,330412,330411,330040,330630,330395,330400,330440),
            estacao = "SBGW", #Guaratingueta
            pdig = c(2.744345,0.7612805),
            tcrit = 22, inccrit = 100)

#"Mangaratiba", "Angra dos Reis", "Paraty"
RJ.costaverde <- list(geocodigo=c(330260,330010,330380),
            estacao = "SBGW", # Guaratingueta
            pdig = c(2.044211,0.9251224),
            tcrit = 22, inccrit = 100)

#"Rio de Janeiro"
RJ.capital <- list(geocodigo=330455,
            estacao = "SBGL",
            pdig = c(2.5016,1.1013),
            tcrit = 22, inccrit = 100)


#########################################################
## Alerta Estado do Parana 
#########################################################
