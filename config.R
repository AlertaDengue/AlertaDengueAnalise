# ====================================================
# Arquivo de configuracao do Alerta Dengue
# ====================================================
hoje = Sys.Date()
      
# ====================================================
## Parametros globais (para todos os municipios)
# ====================================================

## Distribuicao do tempo de geracao da dengue:
gtdist="normal"; meangt=3; sdgt = 1.2   

## Regras de mudança de nivel de alerta
# (criterio, duracao da condicao para turnon, turnoff)

crity = c("temp_min > tcrit | (temp_min < tcrit & inc > preseas)", 3, 0)
crito = c("p1 > 0.9 & inc > preseas", 2, 2)
critr = c("inc > inccrit", 1, 2)

# ========================================================
## Parametros locais (para municipios ou regionais)
# ========================================================

# -----------------
## RIO DE JANEIRO 
# -----------------

RJ.noroeste <- list(pdig = c(2.791400,0.9913278), tcrit=22, inccrit=129.5, 
                    preseas=45.66, posseas=51.29 ,crity = crity, crito=crito, critr=critr)

RJ.norte <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit=85.83, 
                 preseas=42.29,posseas=42.95, crity= crity, crito=crito, critr=critr)

RJ.serrana <-    list(pdig = c(2.788100,0.7627551),tcrit=22, inccrit=18.24, 
                   preseas=7.145, posseas=8.67 ,crity = crity, crito=crito, critr=critr)

RJ.baixadalit <- list(pdig = c(2.294574,0.8221244),tcrit=22, inccrit=85.38, 
                      preseas=33.04, posseas = 40.96, crity = crity, crito=crito, critr=critr)

RJ.met1 <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = 21.6, 
                preseas=8.284, posseas = 7.679, crity = crity, crito=crito, critr=critr) 

RJ.met2 <- list(pdig = c(2.997765,0.7859499),tcrit = 22, inccrit = 77.65, 
                preseas=31.28, posseas=23.82, crity = crity, crito=crito, critr=critr) 

RJ.centrosul <- list(pdig = c(2.743135,0.8294707),tcrit = 22, inccrit = 87.54, 
                     preseas=15.17, posseas=18.06, crity = crity, crito=crito, critr=critr)

RJ.medparaiba <- list(pdig = c(2.744345,0.7612805),tcrit = 22, inccrit = 99.31, 
                      preseas=28.25, posseas=28.25, crity = crity, crito=crito, critr=critr)

RJ.litoralsul <- list(pdig = c(2.044211,0.9251224),tcrit = 20, inccrit = 117.1, 
                      preseas=32.73, posseas=33.87, crity = crity, crito=crito, critr=critr)

RJ.capital <- list(pdig = c(2.5016,1.1013),tcrit = 22, inccrit = 100,
                   preseas=18.59, posseas=14.15, crity = crity, crito=crito, critr=critr) # cidade como um todo

# Dados para o mapa
RJ.shape="../33MUE250GC_SIR.shp"  # fonte para o mapa
RJ.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo

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
