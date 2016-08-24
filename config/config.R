# ====================================================
# Arquivo de configuracao do Alerta Dengue por Estado
# ====================================================
hoje = Sys.Date()
source("alerta/config/config_global.R") # packages e regras gerais do alerta

      
# ========================================
# Parametros do Estado do Rio de Janeiro 
# ========================================
#nomesregs = getRegionais("Rio de Janeiro")# use essa funcao para descobrir as regionais
nomesregs.RJ <- c("Metropolitana I", "Metropolitana II", "Litoral Sul", "Médio Paraíba",    
               "Centro Sul", "Serrana", "Baixada Litorânea", "Norte", "Noroeste")         
pars.RJ <- NULL
pars.RJ[nomesregs.RJ] <- list(NULL)
pars.RJ[["Metropolitana I"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = 100, preseas=8.284, posseas = 7.679, legpos="bottomright")
pars.RJ[["Metropolitana II"]] <- list(pdig = c(2.997765,0.7859499),tcrit = 22, inccrit = 100, preseas=31.28, posseas=23.82, legpos="bottomright") 
pars.RJ[["Litoral Sul"]] <- list(pdig = c(2.044211,0.9251224),tcrit = 20, inccrit = 100, preseas=32.73, posseas=33.87, legpos="bottomright")
pars.RJ[["Médio Paraíba"]] <- list(pdig = c(2.744345,0.7612805),tcrit = 22, inccrit = 100, preseas=28.25, posseas=28.25, legpos="bottomright")
pars.RJ[["Centro Sul"]] <- list(pdig = c(2.743135,0.8294707),tcrit = 22, inccrit = 100, preseas=15.17, posseas=18.06, legpos="bottomright")
pars.RJ[["Serrana"]] <- list(pdig = c(2.788100,0.7627551),tcrit=22, inccrit=100, preseas=7.145, posseas=8.67, legpos="bottomright")
pars.RJ[["Baixada Litorânea"]] <- list(pdig = c(2.294574,0.8221244),tcrit=22, inccrit=100,preseas=33.04, posseas = 40.96, legpos="topleft")
pars.RJ[["Norte"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit=100,preseas=42.29,posseas=42.95, legpos="bottomright")
pars.RJ[["Noroeste"]] <- list(pdig = c(2.791400,0.9913278), tcrit=22, inccrit=129.5,preseas=45.66, posseas=51.29, legpos="bottomright")

#pars.Rio <- list(pdig = c(2.5016,1.1013),tcrit = 22, inccrit = 100,
#                   preseas=18.59, posseas=14.15) # cidade como um todo

# Dados para o mapa
RJ.shape="alerta/report/RJ/shape/33MUE250GC_SIR.shp"  # fonte para o mapa
RJ.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
RJ.criteria = criteria

# Dados do diretorio para salvar (com / no final)
RJ.out = "alerta/report/RJ/figs/"

# ===================================================
# Rio de Janeiro - Intra-capital: por APS 
# ===================================================
# Criterios

RJ.aps <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 18, posseas = 40)
RJ.aps.shape = "alerta/report/Rio_de_Janeiro/shape/CAPS_SMS.shp"
RJ.aps.shapeID = "CD_GEOCMU"
RJ.aps.criteria = criteria


# ========================================
# Parametros do Estado do Paraná 
# ========================================
#nomesregs = getRegionais("Paraná")# use essa funcao para descobrir as regionais
nomesregs.PR <- c("Paranaguá","Curitiba","Ponta Grossa","Iratí","Guarapuava","União da Vitória","Pato Branco","Francisco Beltrão","Foz do Iguaçu","Cascavel",
                  "Campo Mourão","Umuarama","Cianorte","Paranavaí","Maringá","Apucarana","Londrina","Cornélio Procópio","Jacarezinho","Toledo","Telêmaco Borba","Ivaiporã")         
pars.PR <- NULL
pars.PR[nomesregs.PR] <- list(NULL)
pars.PR[["Paranaguá"]] <- list(pdig = c(2.125716,1.018208),tcrit=22, inccrit = 100, preseas=1.7608, posseas=1.7608, legpos="bottomright") 
pars.PR[["Curitiba"]] <- list(pdig = c(2.973131,0.9326073),tcrit = 22, inccrit = 100, preseas=0.9290, posseas=0.8863, legpos="bottomright") 
pars.PR[["Ponta Grossa"]] <- list(pdig = c(2.541044,0.8201539),tcrit = 22, inccrit = 100, preseas=0.8153, posseas=0.8153, legpos="bottomright")
pars.PR[["Iratí"]] <- list(pdig = c(1.927047,0.8525307),tcrit = 22, inccrit = 100, preseas=2.9358, posseas=2.9358, legpos="bottomright")
pars.PR[["Guarapuava"]] <- list(pdig = c(2.399205,1.126098),tcrit = 22, inccrit = 100, preseas=1.0911, posseas=1.0911, legpos="bottomright")
pars.PR[["União da Vitória"]] <- list(pdig = c(3.171668,0.9902871),tcrit=22, inccrit=100, preseas=2.8735, posseas=2.8735, legpos="bottomright")
pars.PR[["Pato Branco"]] <- list(pdig = c(2.233429,0.9194316),tcrit=22, inccrit=100, preseas=1.9028, posseas=1.9028, legpos="bottomleft")
pars.PR[["Francisco Beltrão"]] <- list(pdig = c(2.312452,1.190818),tcrit=22, inccrit=100, preseas=6.5232, posseas=7.9861, legpos="bottomleft")
pars.PR[["Foz do Iguaçu"]] <- list(pdig = c(2.463862,1.41018), tcrit=22, inccrit=100, preseas=31.3056, posseas=22.5217, legpos="bottomright")
pars.PR[["Cascavel"]] <- list(pdig = c(2.41977,1.027232), tcrit=22, inccrit=100, preseas=7.9451, posseas=8.1721, legpos="topleft")
pars.PR[["Campo Mourão"]] <- list(pdig = c(2.803838,1.377009), tcrit=22, inccrit=100, preseas=51.2936, posseas=39.1327, legpos="bottomright")
pars.PR[["Umuarama"]] <- list(pdig = c(2.151001,1.084677), tcrit=22, inccrit=100, preseas=18.7768, posseas=18.8313, legpos="topleft")
pars.PR[["Cianorte"]] <- list(pdig = c(2.65319,0.9346824), tcrit=22, inccrit=100, preseas=33.0935, posseas=28.3922, legpos="bottomright")
pars.PR[["Paranavaí"]] <- list(pdig = c(2.279527,1.030392), tcrit=22, inccrit=100, preseas=65.0158, posseas=66.2491, legpos="bottomright")
pars.PR[["Maringá"]] <- list(pdig = c(2.73903,1.135885), tcrit=22, inccrit=100, preseas=25.6704, posseas=25.5975, legpos="bottomright")
pars.PR[["Apucarana"]] <- list(pdig = c(1.80942,0.9634508), tcrit=22, inccrit=100, preseas=9.2184, posseas=11.7134, legpos="bottomright")
pars.PR[["Londrina"]] <- list(pdig = c(2.698296,1.32989), tcrit=22, inccrit=100, preseas=44.0877, posseas=38.5693, legpos="bottomleft")
pars.PR[["Cornélio Procópio"]] <- list(pdig = c(2.248579,1.111528), tcrit=22, inccrit=100, preseas=15.9326, posseas=22.328, legpos="bottomright")
pars.PR[["Jacarezinho"]] <- list(pdig = c(3.03749,1.093416), tcrit=22, inccrit=100, preseas=32.8909, posseas=21.8551, legpos="topright")
pars.PR[["Toledo"]] <- list(pdig = c(2.424175,1.04265), tcrit=22, inccrit=100, preseas=16.5884, posseas=19.2742, legpos="topright")
pars.PR[["Telêmaco Borba"]] <- list(pdig = c(1.972895,0.8972874), tcrit=22, inccrit=100, preseas=2.7297, posseas=2.7297, legpos="bottomright")
pars.PR[["Ivaiporã"]] <- list(pdig = c(2.146987,0.9084783), tcrit=22, inccrit=100, preseas=3.8631, posseas=4.2447, legpos="bottomright")


# Dados para o mapa
PR.shape="alerta/report/PR/shape/41MUE250GC_SIR.shp"  # fonte para o mapa
PR.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
PR.criteria = criteria

# Dados do diretorio para salvar (com / no final)
PR.out = "alerta/report/PR/figs/"


