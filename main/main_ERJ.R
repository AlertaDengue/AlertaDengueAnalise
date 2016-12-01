# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

# ----- data do relatorio:
data_relatorio = 201647

# ---- Calcula alerta: 

<<<<<<< HEAD
aleRJ <- update.alerta(state="Rio de Janeiro", region = names(pars.RJ), pars = pars.RJ, crit = RJ.criteria, 
=======
aleRJ <- update.alerta(region = names(pars.RJ), state= "Rio de Janeiro", pars = pars.RJ, crit = RJ.criteria, 
>>>>>>> 1ee88bb120ad9db4942a7a64d98b317bd8cacee0
                       datasource = con, sefinal=data_relatorio, writedb = FALSE) #region = names(pars.RJ)[1] escolho a regiao que desejo analisar

bolRJ=configRelatorioEstadual(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, tsdur=104,
                              alert=aleRJ, pars = pars.RJ, shape=RJ.shape, varid=RJ.shapeID,
                              dir=RJ.out, datasource=con, geraPDF=TRUE)

<<<<<<< HEAD
publicarAlerta(ale = aleRJ, pdf = bolRJ, dir = "Relatorio/RJ/Estado")
=======
publicarAlerta(ale = aleRJ, pdf = bolRJ, dir = "Relatorio/RJ/Estadual")
>>>>>>> 1ee88bb120ad9db4942a7a64d98b317bd8cacee0

rm(aleRJ,bolRJ)

# ----- Fechando o banco de dados
dbDisconnect(con)




