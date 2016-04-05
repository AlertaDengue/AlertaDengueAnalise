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
crity <- c("temp_min > tcrit | (temp_min < tcrit & p1 > 0.85) | inc > preinc", 3, 0) # criterios para alerta amarelo
crito <- c("p1 > 0.9", 3, 0) # criterios para alerta laranja 
critr <- c("inc > inccrit", 0, 0) # # criterios para alerta vermelho

#########################################################
## Alerta Estado do Rio de Janeiro 
#########################################################
tcrit.def = 22
inc.def = 100
pre.inc = 20
RJ.noroeste <- list(pdig = c(2.791400,0.9913278), tcrit=22, inccrit=129, preinc=45.66,crity = crity, crito=crito, critr=critr)
RJ.norte <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit=85.83, preinc=42.29,crity= crity, crito=crito, critr=critr)
RJ.serrana <- list(pdig = c(2.788100,0.7627551),tcrit=22, inccrit=18.24, preinc=7.145,crity = crity, crito=crito, critr=critr)
RJ.baixadalit <- list(pdig = c(2.294574,0.8221244),tcrit=22, inccrit=85.38, preinc=33.04,crity = crity, crito=crito, critr=critr)
RJ.met1 <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = inc.def, crity = crity, crito=crito, critr=critr) 
RJ.met2 <- list(pdig = c(2.997765,0.7859499),tcrit = tcrit.def, inccrit = inc.def, crity = crity, crito=crito, critr=critr) 
RJ.centrosul <- list(pdig = c(2.743135,0.8294707),tcrit = tcrit.def, inccrit = inc.def, crity = crity, crito=crito, critr=critr)
RJ.medparaiba <- list(pdig = c(2.744345,0.7612805),tcrit = tcrit.def, inccrit = inc.def, crity = crity, crito=crito, critr=critr)
RJ.litoralsul <- list(pdig = c(2.044211,0.9251224),tcrit = tcrit.def, inccrit = inc.def, crity = crity, crito=crito, critr=critr)
RJ.capital <- list(pdig = c(2.5016,1.1013),tcrit = tcrit.def, inccrit = inc.def, crity = crity, crito=crito, critr=critr) # cidade como um todo

#########################################################
## Alerta da Cidade do Rio de Janeiro - por APS
#########################################################
# Criterios

RJ.aps <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 14.15, posseas = 18,
               crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 0),
               crito = c("p1 > 0.9 & inc > preseas", 2, 2),
               critr = c("inc > inccrit", 1, 2))


#########################################################
## Alerta Estado do Parana 
#########################################################
