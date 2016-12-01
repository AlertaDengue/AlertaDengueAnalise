# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

# ----- data do relatorio:
<<<<<<< HEAD
data_relatorio = 201552

# ---- Calcula alerta: 

aleES <- update.alerta(state="Espírito Santo", region = names(pars.ES), pars = pars.ES, crit = ES.criteria, 
=======
data_relatorio = 201645

# ---- Calcula alerta: 

aleES <- update.alerta(region = names(pars.ES), pars = pars.ES, state = "Espírito Santo", crit = ES.criteria, 
>>>>>>> 1ee88bb120ad9db4942a7a64d98b317bd8cacee0
                       datasource = con, sefinal=data_relatorio, writedb = FALSE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

bolES=configRelatorioEstadual(uf="Espírito Santo", sigla = "ES", data=data_relatorio, tsdur=104,
                              alert=aleES, pars = pars.ES, shape=ES.shape, varid=ES.shapeID,
                              dir=ES.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = aleES, pdf = bolES, dir = "Relatorio/ES/Estado")

rm(aleES,bolES)

# ----- Fechando o banco de dados
dbDisconnect(con)
