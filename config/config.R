# ====================================================
# Arquivo de configuracao do Alerta Dengue por Estado
# ====================================================
hoje = Sys.Date()
source("../config/config_global.R") # packages e regras gerais do alerta

      
# ========================================
# Parametros do Estado do Rio de Janeiro 
# ========================================
#nomesregs = getRegionais("Rio de Janeiro")# use essa funcao para descobrir as regionais
nomesregs <- c("Metropolitana I", "Metropolitana II", "Litoral Sul", "Médio Paraíba",    
               "Centro Sul", "Serrana", "Baixada Litorânea", "Norte", "Noroeste")         
pars.RJ <- NULL
pars.RJ[nomesregs] <- list(NULL)
pars.RJ[["Metropolitana I"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = 100, preseas=8.284, posseas = 7.679, legpos="topleft")
pars.RJ[["Metropolitana II"]] <- list(pdig = c(2.997765,0.7859499),tcrit = 22, inccrit = 100, preseas=31.28, posseas=23.82, legpos="topleft") 
pars.RJ[["Litoral Sul"]] <- list(pdig = c(2.044211,0.9251224),tcrit = 20, inccrit = 100, preseas=32.73, posseas=33.87, legpos="topleft")
pars.RJ[["Médio Paraíba"]] <- list(pdig = c(2.744345,0.7612805),tcrit = 22, inccrit = 100, preseas=28.25, posseas=28.25, legpos="topleft")
pars.RJ[["Centro Sul"]] <- list(pdig = c(2.743135,0.8294707),tcrit = 22, inccrit = 100, preseas=15.17, posseas=18.06, legpos="topleft")
pars.RJ[["Serrana"]] <- list(pdig = c(2.788100,0.7627551),tcrit=22, inccrit=100, preseas=7.145, posseas=8.67, legpos="topleft")
pars.RJ[["Baixada Litorânea"]] <- list(pdig = c(2.294574,0.8221244),tcrit=22, inccrit=100,preseas=33.04, posseas = 40.96, legpos="topleft")
pars.RJ[["Norte"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit=100,preseas=42.29,posseas=42.95, legpos="topleft")
pars.RJ[["Noroeste"]] <- list(pdig = c(2.791400,0.9913278), tcrit=22, inccrit=129.5,preseas=45.66, posseas=51.29, legpos="topleft")

pars.Rio <- list(pdig = c(2.5016,1.1013),tcrit = 22, inccrit = 100,
                   preseas=18.59, posseas=14.15) # cidade como um todo

# Dados para o mapa
RJ.shape="../report/RJ/shape/33MUE250GC_SIR.shp"  # fonte para o mapa
RJ.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
RJ.criteria = criteria

# Dados do diretorio para salvar (com / no final)
RJ.out = "../report/RJ/figs/"

# -----------------
# Rio de Janeiro - Intra-capital: por APS 
# -----------------
# Criterios

RJ.aps <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 14.15, posseas = 18)
RJ.aps.shape = "../report/Rio_de_Janeiro/shape/CAPS_SMS.shp"
RJ.aps.shapeID = "CD_GEOCMU"
RJ.aps.criteria = criteria
