#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201650

#***************************************************
# Cidade de Alfredo Chaves
#***************************************************

aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "simples", siglaUF = "ES", 
                                             data = data_relatorio, pars = pars.ES, 
                                             dir.out = ES.MN.AlfredoChaves.out, geraPDF = TRUE) #

publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "Relatorio/ES/Municipios/AlfredoChaves")


#***************************************************
# Cidade de Linhares
#***************************************************

aleLinhares <- update.alerta(city = 3203205, pars = pars.ES[["Central"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio, writedb = FALSE,adjustdelay = FALSE)

bolLinhares <- configRelatorioMunicipal(alert = aleLinhares, tipo = "simples", siglaUF = "ES", data = data_relatorio, 
                                        pars = pars.ES, dir.out = ES.MN.Linhares.out, geraPDF = TRUE)

publicarAlerta(ale = aleLinhares, pdf = bolLinhares, dir = "Relatorio/ES/Municipios/Linhares")



#***************************************************
# Cidade de Santa Maria de Jetiba
#***************************************************

aleSantaMariaJetiba <- update.alerta(city = 3204559, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                  datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolSantaMariaJetiba <- configRelatorioMunicipal(alert = aleSantaMariaJetiba, tipo = "simples", siglaUF = "ES", data = data_relatorio, 
                                             dir.out = ES.MN.SantaMariaJetiba.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleSantaMariaJetiba, pdf = bolSantaMariaJetiba, dir = "Relatorio/ES/Municipios/SantaMariadeJetiba")


# ----- Fechando o banco de dados
dbDisconnect(con)
