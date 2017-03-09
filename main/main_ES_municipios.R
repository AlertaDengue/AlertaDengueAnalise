#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
source("config/config_global.R") # packages e regras gerais do alerta
source("config/config.R") # arquivo de configuracao do alerta (parametros)

con <- DenguedbConnect()


#***************************************************
# Inicialização dos parametros de configuracao
#***************************************************

Sys.setenv(R_CONFIG_ACTIVE = "ES-Sul")  # estado-regional
p <- config::get(file="config/ES.yml")  # estado
params<- list(pdig = c(p$pdig1,p$pdig2),tcrit=p$tcrit, inccrit = p$inccrit, preseas=p$preseas, 
              posseas =p$posseas, legpos=p$legpos) # provisorio-para compatibilidade com versao anterior


#***************************************************
# Cidade de Alfredo Chaves
#***************************************************


#aleAlfredoChaves <- update.alerta(city = 3200300, pars = pars.ES[["Sul"]], crit = ES.criteria, 
#                                  datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)


aleAlfredoChaves <- update.alerta(city = 3200300, pars = params, crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "completo", siglaUF = "ES", 
                                             data = data_relatorio, pars = pars.ES, 
                                             dir.out = ES.MN.AlfredoChaves.out, geraPDF = TRUE) #

#publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "Relatorio/ES/Municipios/Alfredo_Chaves", writebd = FALSE)

#rm(aleAlfredoChaves,bolAlfredoChaves)

# ----- Fechando o banco de dados
dbDisconnect(con)
