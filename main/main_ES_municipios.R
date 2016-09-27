#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201636

#***************************************************
# Cidade de Alfredo Chaves
#***************************************************

aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["ES-MN-AlfredoChaves"]], crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "simples", siglaUF = "ES", data = data_relatorio, 
                             dir.out = ES.MN.AlfredoChaves.out, geraPDF = TRUE)

publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "Relatorio/ES/Municipios/AlfredoChaves")


#***************************************************
# Cidade de Santa Maria de Jetiba
#***************************************************

aleLinhares <- update.alerta(city = 3203205, pars = pars.ES[["ES-MN-Linhares"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio, writedb = FALSE)

bolLinhares <- configRelatorioMunicipal(alert = aleLinhares, tipo = "simples", siglaUF = "ES", data = data_relatorio, 
                                                dir.out = ES.MN.Linhares.out, geraPDF = TRUE)

publicarAlerta(ale = aleLinhares, pdf = bolLinhares, dir = "Relatorio/ES/Municipios/Linhares")



#***************************************************
# Cidade de Santa Maria de Jetiba
#***************************************************

aleSantaMariaJetiba <- update.alerta(city = 3204559, pars = pars.ES[["ES-MN-SantaMariaJetiba"]], crit = ES.criteria, 
                                  datasource = con, sefinal=data_relatorio, writedb = FALSE)

bolSantaMariaJetiba <- configRelatorioMunicipal(alert = aleSantaMariaJetiba, tipo = "simples", siglaUF = "ES", data = data_relatorio, 
                                             dir.out = ES.MN.SantaMariaJetiba.out, geraPDF = TRUE)

publicarAlerta(ale = aleSantaMariaJetiba, pdf = bolSantaMariaJetiba, dir = "Relatorio/ES/Municipios/SantaMariaJetiba")


# ----- Fechando o banco de dados
dbDisconnect(con)
