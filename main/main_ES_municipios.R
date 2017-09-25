#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

con <- DenguedbConnect()



data_relatorio = 201737

#***************************************************
# Cidade de Alfredo Chaves
#***************************************************

aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "completo", siglaUF = "ES", 
                                             data = data_relatorio, pars = pars.ES, 
                                             dir.out = ES.MN.AlfredoChaves.out, geraPDF = TRUE) #

publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "Relatorio/ES/Municipios/Alfredo_Chaves", writebd = FALSE)

rm(aleAlfredoChaves,bolAlfredoChaves)
#***************************************************
# Cidade de Linhares
#***************************************************

aleLinhares <- update.alerta(city = 3203205, pars = pars.ES[["Central"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio, writedb = FALSE,adjustdelay = FALSE)

bolLinhares <- configRelatorioMunicipal(alert = aleLinhares, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                        pars = pars.ES, dir.out = ES.MN.Linhares.out, geraPDF = TRUE)

publicarAlerta(ale = aleLinhares, pdf = bolLinhares, dir = "Relatorio/ES/Municipios/Linhares")

rm(aleLinhares,bolLinhares)
#***************************************************
# Cidade de Santa Maria de Jetiba
#***************************************************

aleSantaMariaJetiba <- update.alerta(city = 3204559, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                  datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolSantaMariaJetiba <- configRelatorioMunicipal(alert = aleSantaMariaJetiba, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                             dir.out = ES.MN.SantaMariaJetiba.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleSantaMariaJetiba, pdf = bolSantaMariaJetiba, dir = "Relatorio/ES/Municipios/Santa_Maria_de_Jetiba")

rm(aleSantaMariaJetiba,bolSantaMariaJetiba)
#***************************************************
# Cidade de Anchieta
#***************************************************

aleAnchieta <- update.alerta(city = 320040, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolAnchieta <- configRelatorioMunicipal(alert = aleAnchieta, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                                dir.out = ES.MN.Anchieta.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleAnchieta, pdf = bolAnchieta, dir = "Relatorio/ES/Municipios/Anchieta")

rm(aleAnchieta,bolAnchieta)

#***************************************************
# Cidade de Rio Novo do Sul
#***************************************************

aleRioNovoSul <- update.alerta(city = 320440, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                               datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolRioNovoSul <- configRelatorioMunicipal(alert = aleRioNovoSul, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                          dir.out = ES.MN.RioNovoSul.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleRioNovoSul, pdf = bolRioNovoSul, dir = "Relatorio/ES/Municipios/Rio_Novo_do_Sul")

rm(aleRioNovoSul,bolRioNovoSul)
#***************************************************
# Cidade de Aracruz
#***************************************************

aleAracruz <- update.alerta(city = 320060, pars = pars.ES[["Central"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolAracruz <- configRelatorioMunicipal(alert = aleAracruz, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                                dir.out = ES.MN.Aracruz.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleAracruz, pdf = bolAracruz, dir = "Relatorio/ES/Municipios/Aracruz")

rm(aleAracruz,bolAracruz)
#***************************************************
# Cidade de Atílio Vivacqua
#***************************************************

aleAtilioVivacqua <- update.alerta(city = 320070, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                                     datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolAtilioVivacqua <- configRelatorioMunicipal(alert = aleAtilioVivacqua, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                                dir.out = ES.MN.AtilioVivacqua.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleAtilioVivacqua, pdf = bolAtilioVivacqua, dir = "Relatorio/ES/Municipios/Atilio_Vivacqua")

rm(aleAtilioVivacqua,bolAtilioVivacqua)
#***************************************************
# Cidade de Conceição do Castelo
#***************************************************

aleConceicaoCastelo <- update.alerta(city = 320170, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolConceicaoCastelo <- configRelatorioMunicipal(alert = aleConceicaoCastelo, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.ConceicaoCastelo.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleConceicaoCastelo, pdf = bolConceicaoCastelo, dir = "Relatorio/ES/Municipios/Conceicao_do_Castelo")

rm(aleConceicaoCastelo,bolConceicaoCastelo)

#***************************************************
# Cidade de Domingos Martins
#***************************************************

aleDomingosMartins <- update.alerta(city = 320190, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolDomingosMartins <- configRelatorioMunicipal(alert = aleDomingosMartins, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.DomingosMartins.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleDomingosMartins, pdf = bolDomingosMartins, dir = "Relatorio/ES/Municipios/Domingos_Martins")

rm(aleDomingosMartins,bolDomingosMartins)
#***************************************************
# Cidade de Itaguaçu
#***************************************************

aleItaguacu <- update.alerta(city = 320270, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolItaguacu <- configRelatorioMunicipal(alert = aleItaguacu, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.Itaguacu.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleItaguacu, pdf = bolItaguacu, dir = "Relatorio/ES/Municipios/Itaguacu")

rm(aleItaguacu,bolItaguacu)
#***************************************************
# Cidade de Jerônimo Monteiro
#***************************************************

aleJeronimoMonteiro <- update.alerta(city = 320310, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolJeronimoMonteiro <- configRelatorioMunicipal(alert = aleJeronimoMonteiro, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.JeronimoMonteiro.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleJeronimoMonteiro, pdf = bolJeronimoMonteiro, dir = "Relatorio/ES/Municipios/Jeronimo_Monteiro")

rm(aleJeronimoMonteiro,bolJeronimoMonteiro)
#***************************************************
# Cidade de Laranja da Terra
#***************************************************

aleLaranjaTerra <- update.alerta(city = 320316, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolLaranjaTerra <- configRelatorioMunicipal(alert = aleLaranjaTerra, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.LaranjaTerra.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleLaranjaTerra, pdf = bolLaranjaTerra, dir = "Relatorio/ES/Municipios/Laranja_da_Terra")

rm(aleLaranjaTerra,bolLaranjaTerra)
#***************************************************
# Cidade de Marechal Floriano
#***************************************************

aleMarechalFloriano <- update.alerta(city = 320334, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolMarechalFloriano <- configRelatorioMunicipal(alert = aleMarechalFloriano, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.MarechalFloriano.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleMarechalFloriano, pdf = bolMarechalFloriano, dir = "Relatorio/ES/Municipios/Marechal_Floriano")

rm(aleMarechalFloriano,bolMarechalFloriano)
#***************************************************
# Cidade de Mimoso do Sul
#***************************************************

aleMimosoSul <- update.alerta(city = 320340, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolMimosoSul <- configRelatorioMunicipal(alert = aleMimosoSul, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.MimosoSul.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleMimosoSul, pdf = bolMimosoSul, dir = "Relatorio/ES/Municipios/Mimoso_do_Sul")

rm(aleMimosoSul,bolMimosoSul)
#***************************************************
# Cidade de Mucurici
#***************************************************

aleMucurici <- update.alerta(city = 320360, pars = pars.ES[["Norte"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolMucurici <- configRelatorioMunicipal(alert = aleMucurici, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.Mucurici.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleMucurici, pdf = bolMucurici, dir = "Relatorio/ES/Municipios/Mucurici")

rm(aleMucurici,bolMucurici)
#***************************************************
# Cidade de Muqui
#***************************************************

aleMuqui <- update.alerta(city = 320380, pars = pars.ES[["Sul"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolMuqui <- configRelatorioMunicipal(alert = aleMuqui, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.Muqui.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleMuqui, pdf = bolMuqui, dir = "Relatorio/ES/Municipios/Muqui")

rm(aleMuqui,bolMuqui)
#***************************************************
# Cidade de Pinheiros
#***************************************************

alePinheiros <- update.alerta(city = 320410, pars = pars.ES[["Norte"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolPinheiros <- configRelatorioMunicipal(alert = alePinheiros, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.Pinheiros.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = alePinheiros, pdf = bolPinheiros, dir = "Relatorio/ES/Municipios/Pinheiros")

rm(alePinheiros,bolPinheiros)

#***************************************************
# Cidade de Vila Velha
#***************************************************

aleVilaVelha <- update.alerta(city = 320520, pars = pars.ES[["Metropolitana"]], crit = ES.criteria, 
                                   datasource = con, sefinal=data_relatorio,writedb = FALSE, adjustdelay = FALSE)

bolVilaVelha <- configRelatorioMunicipal(alert = aleVilaVelha, tipo = "completo", siglaUF = "ES", data = data_relatorio, 
                                              dir.out = ES.MN.VilaVelha.out, pars = pars.ES, geraPDF = TRUE)

publicarAlerta(ale = aleVilaVelha, pdf = bolVilaVelha, dir = "Relatorio/ES/Municipios/Vila_Velha")

rm(aleVilaVelha,bolVilaVelha)




# ----- Fechando o banco de dados
dbDisconnect(con)
