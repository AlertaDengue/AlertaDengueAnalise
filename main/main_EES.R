# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Espírito Santo
# =============================================================================
setwd("~/"); library(AlertTools)
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:


data_relatorio = 201945
# ---- Calcula alerta:


#Dengue:
aleES <- update.alerta(region = names(pars.ES), pars = pars.ES, state = "Espírito Santo", crit = ES.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE) 


# Chik
aleES.chik <- update.alerta(region = names(pars.ES), state="Espírito Santo", pars = pars.ES, crit = ES.criteria,
                            cid10="A92.0", datasource = con, sefinal=data_relatorio, writedb = TRUE, adjustdelay = FALSE) 

# Zika
aleES.zika <- update.alerta(region = names(pars.ES), state="Espírito Santo", pars = pars.ES, crit = ES.criteria, 
                            cid10="A92.8", datasource = con, sefinal=data_relatorio, writedb = TRUE, adjustdelay = FALSE) 

# O Boletim estadual ainda é só de dengue:

bolES=configRelatorioEstadual(uf="Espírito Santo", sigla = "ES", data=data_relatorio, tsdur=104,
                              alert=aleES, pars = pars.ES, shape=ES.shape, varid=ES.shapeID,
                              dir=ES.out, datasource=con, geraPDF=TRUE)


publicarAlerta(ale = aleES, pdf = bolES, dir = "Relatorio/ES/Estado")

rm(aleES,bolES)


# ----- Calcula alerta arbo para Vitoria


# Dengue
aleVit <- update.alerta(city = 3205309, pars = pars.ES[["Metropolitana"]], cid10="A90",crit = ES.criteria, 
                         datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE,
                        delaymethod = "bayesian")

#res = write.alerta(obj = aleFort, write = "db")
#bolVit <- configRelatorioMunicipal(alert = aleFort, tipo = "simples", varcli = "umid_max", siglaUF = "CE", 
#                                    data = data_relatorio, pars = pars.CE,
#                                    dir.out = CE.Fortaleza.out, geraPDF = TRUE)

# Chik 
aleVitC <- update.alerta(city = 3205309, pars = pars.ES.chik[["Metropolitana"]], cid10="A92.0", 
                         crit = criteriaChik, datasource = con, sefinal=data_relatorio, writedb = FALSE, 
                         adjustdelay = FALSE)

#Zika
aleVitZ <- update.alerta(city = 3205309, pars = pars.ES.zika[["Metropolitana"]], cid10="A92.8", crit = ES.criteria, 
                          datasource = con, sefinal=data_relatorio, writedb = TRUE, adjustdelay = FALSE)

# Boletim Arbo
bolVit <- configRelatorioMunicipal(alert = aleVit, alechik = aleVitC, alezika = aleVitZ, tipo = "simples", 
                                    varcli = "temp_min", siglaUF = "ES", 
                                    data = data_relatorio, pars = pars.ES,
                                    dir.out = ES.MN.Vitoria.out, geraPDF = TRUE)


publicarAlerta(ale = aleVit, pdf = bolVit, dir = "Relatorio/ES/Municipios/Vitoria")



# ----- Fechando o banco de dados
dbDisconnect(con)






#ale <- update.alerta(city = 3200359, pars = pars.ES[["Central"]], crit = ES.criteria, 
#                             datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

#ale <- update.alerta(region = "Central", pars = pars.ES[["Central"]], crit = ES.criteria, 
#                     datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

