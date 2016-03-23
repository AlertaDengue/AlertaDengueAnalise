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




#########################################################
## Alerta Estado do Rio de Janeiro 
#########################################################
tcrit.def = 22
inc.def = 100

RJ.noroeste <- list(pdig = c(2.791400,0.9913278), tcrit = tcrit.def, inccrit = inc.def)
RJ.norte <- list(pdig = c(2.997765,0.7859499),tcrit = tcrit.def, inccrit = inc.def)
RJ.serrana <- list(pdig = c(2.788100,0.7627551),tcrit = tcrit.def, inccrit = inc.def)
RJ.baixadalit <- list(pdig = c(2.294574,0.8221244),tcrit = tcrit.def, inccrit = inc.def)
RJ.met1 <- list(pdig = c(2.997765,0.7859499),tcrit = tcrit.def, inccrit = inc.def) 
RJ.met2 <- list(pdig = c(2.997765,0.7859499),tcrit = tcrit.def, inccrit = inc.def) 
RJ.centrosul <- list(pdig = c(2.743135,0.8294707),tcrit = tcrit.def, inccrit = inc.def)
RJ.medparaiba <- list(pdig = c(2.744345,0.7612805),tcrit = tcrit.def, inccrit = inc.def)
RJ.litoralsul <- list(pdig = c(2.044211,0.9251224),tcrit = tcrit.def, inccrit = inc.def)

RJ.capital <- list(pdig = c(2.5016,1.1013),tcrit = tcrit.def, inccrit = inc.def)



#########################################################
## Alerta Estado do Parana 
#########################################################
