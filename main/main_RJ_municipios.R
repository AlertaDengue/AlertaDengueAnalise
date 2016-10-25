## Alertas municipais do Estado do Rio de Janeiro
#==============================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201641

#***********************************
### Cidade do Rio de Janeiro 
#***********************************

<<<<<<< HEAD

=======
>>>>>>> f7b49587706f3e0899bd25c2843ca16d941217ba
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, se = data_relatorio, verbose=FALSE)        # calcula o alerta

bolrio <- configRelatorioRio( data=data_relatorio, alert=alerio, shape=RJ.aps.shape,
                                    dirout=RJ.RiodeJaneiro.out, datasource=con, geraPDF=TRUE)

publicarAlerta(ale = alerio, pdf = bolrio, dir = "Relatorio/RJ/Municipios/RiodeJaneiro")

rm(alerio,bolrio)
#***************************************************
# Cidade de Campos de Goytacazes
#***************************************************

aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE)

bolCampos <- configRelatorioMunicipal(alert = aleCampos, tipo = "simples", siglaUF = "RJ", data = data_relatorio, 
                                             dir.out = RJ_CamposdosGoytacazes.out, geraPDF = TRUE)

publicarAlerta(ale = aleCampos, pdf = bolCampos, dir = "Relatorio/RJ/Municipios/CamposdosGoytacazes")

rm(aleCampos,bolCampos)

# ----- Fechando o banco de dados
dbDisconnect(con)



