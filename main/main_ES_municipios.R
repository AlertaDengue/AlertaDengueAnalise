#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
source("config/config_global.R") # packages e regras gerais do alerta
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
dir.out = "report/ES/Municipios/AlfredoChaves"

aleAlfredoChaves <- update.alerta(city = 3200300, pars = params, crit = ES.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = p$adjustdelay)

bolAlfredoChaves <- configRelatorioMunicipal(alert = aleAlfredoChaves, tipo = "completo", siglaUF = p$UF, 
                                             data = data_relatorio, pars = params, 
                                             dir.out = dir.out, geraPDF = TRUE) #

publicarAlerta(ale = aleAlfredoChaves, pdf = bolAlfredoChaves, dir = "~/Relatorio/ES/Municipios/AlfredoChaves", 
               writebd = FALSE)

#rm(aleAlfredoChaves,bolAlfredoChaves)

# ----- Fechando o banco de dados
dbDisconnect(con)
