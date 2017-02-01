# ====================================================
# Arquivo de configuracao do Alerta Dengue por Estado
# ====================================================
hoje = Sys.Date()
source("AlertaDengueAnalise/config/config_global.R") # packages e regras gerais do alerta

#**********************************************************************************************************************************      
# ========================================
# Parametros do Estado do Rio de Janeiro 
# ========================================
#nomesregs = getRegionais("Rio de Janeiro")# use essa funcao para descobrir as regionais
nomesregs.RJ <- c("Metropolitana I", "Metropolitana II", "Litoral Sul", "Médio Paraíba",    
               "Centro Sul", "Serrana", "Baixada Litorânea", "Norte", "Noroeste")         
pars.RJ <- NULL
pars.RJ[nomesregs.RJ] <- list(NULL)
pars.RJ[["Metropolitana I"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit = 100, preseas=8.28374162389761, posseas = 7.67878514885295, legpos="bottomright")
pars.RJ[["Metropolitana II"]] <- list(pdig = c(2.997765,0.7859499),tcrit = 22, inccrit = 100, preseas=31.2768016548567, posseas=23.820324604354, legpos="bottomright") 
pars.RJ[["Litoral Sul"]] <- list(pdig = c(2.044211,0.9251224),tcrit = 20, inccrit = 100, preseas=32.731408629799, posseas=33.8713008094722, legpos="bottomright")
pars.RJ[["Médio Paraíba"]] <- list(pdig = c(2.744345,0.7612805),tcrit = 22, inccrit = 100, preseas=28.2488218636962, posseas=28.2510753568988, legpos="bottomright")
pars.RJ[["Centro Sul"]] <- list(pdig = c(2.743135,0.8294707),tcrit = 22, inccrit = 100, preseas=15.1656600844788, posseas=18.0563291379993, legpos="bottomright")
pars.RJ[["Serrana"]] <- list(pdig = c(2.788100,0.7627551),tcrit=22, inccrit=100, preseas=7.14454530796742, posseas=8.66976041810981, legpos="bottomright")
pars.RJ[["Baixada Litorânea"]] <- list(pdig = c(2.294574,0.8221244),tcrit=22, inccrit=100,preseas=33.0426043568896, posseas = 40.9551438748963, legpos="topleft")
pars.RJ[["Norte"]] <- list(pdig = c(2.997765,0.7859499),tcrit=22, inccrit=100,preseas=42.2904139814942,posseas=42.9546181775769, legpos="bottomright")
pars.RJ[["Noroeste"]] <- list(pdig = c(2.791400,0.9913278), tcrit=22, inccrit=129.5,preseas=45.6573892160522, posseas=51.2923379640271, legpos="bottomright")

#pars.Rio <- list(pdig = c(2.5016,1.1013),tcrit = 22, inccrit = 100,
#                   preseas=18.59, posseas=14.15) # cidade como um todo

# Dados para o mapa
RJ.shape="AlertaDengueAnalise/report/RJ/shape/33MUE250GC_SIR.shp"  # fonte para o mapa
RJ.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
RJ.criteria = criteria

# Dados do diretorio para salvar (com / no final)
RJ.out = "AlertaDengueAnalise/report/RJ"

# ===================================================
# Rio de Janeiro - Intra-capital: por APS 
# ===================================================
# Criterios

RJ.aps <- list(pdig = c(2.5016,1.1013), tcrit=22, inccrit=100, preseas = 18, posseas = 40)
RJ.aps.shape = "AlertaDengueAnalise/report/RJ/Municipios/Rio_de_Janeiro/shape/CAPS_SMS.shp"
RJ.aps.shapeID = "CD_GEOCMU"
RJ.aps.criteria = criteria
RJ.RiodeJaneiro.out = "AlertaDengueAnalise/report/RJ/Municipios/Rio_de_Janeiro"

# ============================
# Rio de Janeiro - Municipios
# ============================
RJ_CamposdosGoytacazes.out = "AlertaDengueAnalise/report/RJ/Municipios/Campos_dos_Goytacazes"

#**********************************************************************************************************************************
# ========================================
# Parametros do Estado do Paraná 
# ========================================
#nomesregs = getRegionais("Paraná")# use essa funcao para descobrir as regionais
nomesregs.PR <- c("Paranaguá","Curitiba","Ponta Grossa","Iratí","Guarapuava","União da Vitória","Pato Branco","Francisco Beltrão","Foz do Iguaçu","Cascavel",
                  "Campo Mourão","Umuarama","Cianorte","Paranavaí","Maringá","Apucarana","Londrina","Cornélio Procópio","Jacarezinho","Toledo","Telêmaco Borba","Ivaiporã")         
pars.PR <- NULL
pars.PR[nomesregs.PR] <- list(NULL)
pars.PR[["Paranaguá"]] <- list(pdig = c(2.125716,1.018208),tcrit=22, inccrit = 100, preseas=1.76068117233195, posseas=1.76068117233195, legpos="bottomright") 
pars.PR[["Curitiba"]] <- list(pdig = c(2.973131,0.9326073),tcrit = 22, inccrit = 100, preseas=0.929008877888591, posseas=0.886370701993983, legpos="bottomright") 
pars.PR[["Ponta Grossa"]] <- list(pdig = c(2.541044,0.8201539),tcrit = 22, inccrit = 100, preseas=0.815300250623297, posseas=0.815300250623297, legpos="bottomright")
pars.PR[["Iratí"]] <- list(pdig = c(1.927047,0.8525307),tcrit = 22, inccrit = 100, preseas=2.935822911162, posseas=2.935822911162, legpos="bottomright")
pars.PR[["Guarapuava"]] <- list(pdig = c(2.399205,1.126098),tcrit = 22, inccrit = 100, preseas=1.09119319793808, posseas=1.09119319793808, legpos="bottomright")
pars.PR[["União da Vitória"]] <- list(pdig = c(3.171668,0.9902871),tcrit=22, inccrit=100, preseas=2.87353018930817, posseas=2.87353018930817, legpos="bottomright")
pars.PR[["Pato Branco"]] <- list(pdig = c(2.233429,0.9194316),tcrit=22, inccrit=100, preseas=1.90286266659563, posseas=1.90286266659563, legpos="bottomleft")
pars.PR[["Francisco Beltrão"]] <- list(pdig = c(2.312452,1.190818),tcrit=22, inccrit=100, preseas=6.52329241986629, posseas=7.98614914418451, legpos="bottomleft")
pars.PR[["Foz do Iguaçu"]] <- list(pdig = c(2.463862,1.41018), tcrit=22, inccrit=100, preseas=31.3056515260305, posseas=22.5217798363008, legpos="bottomright")
pars.PR[["Cascavel"]] <- list(pdig = c(2.41977,1.027232), tcrit=22, inccrit=100, preseas=7.94511869250431, posseas=8.17216603371322, legpos="topleft")
pars.PR[["Campo Mourão"]] <- list(pdig = c(2.803838,1.377009), tcrit=22, inccrit=100, preseas=51.2936057452847, posseas=39.1327072056761, legpos="bottomright")
pars.PR[["Umuarama"]] <- list(pdig = c(2.151001,1.084677), tcrit=22, inccrit=100, preseas=18.7768447813997, posseas=18.8313654215979, legpos="topleft")
pars.PR[["Cianorte"]] <- list(pdig = c(2.65319,0.9346824), tcrit=22, inccrit=100, preseas=33.0935066490596, posseas=28.3922738098471, legpos="bottomright")
pars.PR[["Paranavaí"]] <- list(pdig = c(2.279527,1.030392), tcrit=22, inccrit=100, preseas=65.0158233054388, posseas=66.2491973486479, legpos="bottomright")
pars.PR[["Maringá"]] <- list(pdig = c(2.73903,1.135885), tcrit=22, inccrit=100, preseas=25.6704554824092, posseas=25.5975051632751, legpos="bottomright")
pars.PR[["Apucarana"]] <- list(pdig = c(1.80942,0.9634508), tcrit=22, inccrit=100, preseas=9.21842307308938, posseas=11.7134983660164, legpos="bottomright")
pars.PR[["Londrina"]] <- list(pdig = c(2.698296,1.32989), tcrit=22, inccrit=100, preseas=44.0877388054775, posseas=38.5693221861767, legpos="bottomleft")
pars.PR[["Cornélio Procópio"]] <- list(pdig = c(2.248579,1.111528), tcrit=22, inccrit=100, preseas=15.9326990905241, posseas=22.3280339879008, legpos="bottomright")
pars.PR[["Jacarezinho"]] <- list(pdig = c(3.03749,1.093416), tcrit=22, inccrit=100, preseas=32.8909297474864, posseas=21.8551919883791, legpos="topright")
pars.PR[["Toledo"]] <- list(pdig = c(2.424175,1.04265), tcrit=22, inccrit=100, preseas=16.5884626816913, posseas=19.2742239553833, legpos="topright")
pars.PR[["Telêmaco Borba"]] <- list(pdig = c(1.972895,0.8972874), tcrit=22, inccrit=100, preseas=2.72979406433579, posseas=2.72979406433579, legpos="bottomright")
pars.PR[["Ivaiporã"]] <- list(pdig = c(2.146987,0.9084783), tcrit=22, inccrit=100, preseas=3.86314536514086, posseas=4.24471735288336, legpos="bottomright")


# Dados para o mapa
PR.shape="AlertaDengueAnalise/report/PR/shape/41MUE250GC_SIR.shp"  # fonte para o mapa
PR.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
PR.criteria = criteria
PR.out = "AlertaDengueAnalise/report/PR"

###====================================
## Parana - Regionais
### ===================================
PR.Cascavel.out = "AlertaDengueAnalise/report/PR/Regionais/Cascavel"

#***********************************************************************************************************************************
# ========================================
# Parametros do Estado do Espírito Santo 
# ========================================
#nomesregs = getRegionais("Espírito Santo")# use essa funcao para descobrir as regionais
nomesregs.ES <- c("Central","Metropolitana","Norte","Sul")
pars.ES <- NULL
pars.ES[nomesregs.ES] <- list(NULL)
pars.ES[["Central"]] <- list(pdig=c(1.857061,0.9466695),tcrit=22, inccrit = 100, preseas=5, posseas = 10, legpos="bottomleft")
pars.ES[["Metropolitana"]] <- list(pdig = c(2.412546,1.053108),tcrit=22, inccrit = 100, preseas=5, posseas = 10, legpos="bottomleft")
pars.ES[["Norte"]] <- list(pdig=c(2.679213,1.569757),tcrit=22, inccrit = 100, preseas=5, posseas = 10, legpos="bottomleft")
pars.ES[["Sul"]] <- list(pdig = c(2.295608,1.167698),tcrit=22, inccrit = 100, preseas=5, posseas = 10, legpos="topright")
#<<<<<<< HEAD
ES.out = "AlertaDengueAnalise/report/ES"
#=======
#ES.out = "AlertaDengueAnalise/report/ES"
#>>>>>>> 1ee88bb120ad9db4942a7a64d98b317bd8cacee0

# Dados para o mapa
ES.shape="AlertaDengueAnalise/report/ES/shape/32MUE250GC_SIRm.shp"  # fonte para o mapa
ES.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
ES.criteria = criteria


# Dados do diretorio para salvar (com / no final)
ES.MN.AlfredoChaves.out = "AlertaDengueAnalise/report/ES/Municipios/AlfredoChaves"
ES.MN.SantaMariaJetiba.out = "AlertaDengueAnalise/report/ES/Municipios/SantaMariaJetiba"
ES.MN.Anchieta.out = "AlertaDengueAnalise/report/ES/Municipios/Anchieta"
ES.MN.Aracruz.out = "AlertaDengueAnalise/report/ES/Municipios/Aracruz"
ES.MN.AtilioVivacqua.out = "AlertaDengueAnalise/report/ES/Municipios/AtilioVivacqua"
ES.MN.ConceicaoCastelo.out = "AlertaDengueAnalise/report/ES/Municipios/ConceicaoCastelo"
ES.MN.DomingosMartins.out = "AlertaDengueAnalise/report/ES/Municipios/DomingosMartins"
ES.MN.Itaguacu.out = "AlertaDengueAnalise/report/ES/Municipios/Itaguacu"
ES.MN.JeronimoMonteiro.out = "AlertaDengueAnalise/report/ES/Municipios/JeronimoMonteiro"
ES.MN.LaranjaTerra.out = "AlertaDengueAnalise/report/ES/Municipios/LaranjaTerra"
ES.MN.Linhares.out = "AlertaDengueAnalise/report/ES/Municipios/Linhares"
ES.MN.MarechalFloriano.out = "AlertaDengueAnalise/report/ES/Municipios/MarechalFloriano"
ES.MN.MimosoSul.out = "AlertaDengueAnalise/report/ES/Municipios/MimosoSul"
ES.MN.Mucurici.out = "AlertaDengueAnalise/report/ES/Municipios/Mucurici"
ES.MN.Muqui.out = "AlertaDengueAnalise/report/ES/Municipios/Muqui"
ES.MN.Pinheiros.out = "AlertaDengueAnalise/report/ES/Municipios/Pinheiros"
ES.MN.RioNovoSul.out = "AlertaDengueAnalise/report/ES/Municipios/RioNovoSul"
ES.MN.VilaVelha.out = "AlertaDengueAnalise/report/ES/Municipios/VilaVelha"

#***********************************************************************************************************************************
# ========================================
# Parametros do Estado de Minas Gerais 
# ========================================
#nomesregs = getRegionais("Espírito Santo")# use essa funcao para descobrir as regionais
nomesregs.MG <- c("Sete Lagoas")         
pars.MG <- NULL
pars.MG[nomesregs.MG] <- list(NULL)
pars.MG[["Sete Lagoas"]] <- list(pdig = c(2.708049,1.373673),tcrit=20, inccrit = 100, preseas=10, posseas = 10, legpos="bottomright")
MG.out = "AlertaDengueAnalise/report/MG/figs/"

# Dados para o mapa
MG.shape="AlertaDengueAnalise/report/MG/shape/31MUE250GC_SIR.shp"  # fonte para o mapa
MG.shapeID="CD_GEOCMU"  # variavel do mapa que corresponde ao geocodigo
MG.criteria = criteria


# Dados do diretorio para salvar (com / no final)
MG.SeteLagoas.out = "AlertaDengueAnalise/report/MG/Regionais/SeteLagoas"

