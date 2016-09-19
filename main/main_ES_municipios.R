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


# ----- Fechando o banco de dados
dbDisconnect(con)
