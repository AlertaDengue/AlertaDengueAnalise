## Alertas municipais do Estado do Rio de Janeiro
#==============================
setwd("~/"); library("AlertTools")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201810

#***********************************
### Cidade do Rio de Janeiro 
#***********************************



# Dengue 
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, se = data_relatorio, verbose=FALSE)        # calcula o alerta


# Chikungunya

alerioC <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, cid10 = "A920", datasource=con, se = data_relatorio, verbose=FALSE) 

# Boletim de dengue e chik
bolrio <- configRelatorioRio( data=data_relatorio, alert=alerio, alertC= alerioC, shape=RJ.aps.shape,
                              dirout=RJ.RiodeJaneiro.out, datasource=con, geraPDF=TRUE)


publicarAlerta(ale = alerio, pdf = bolrio, dir = "Relatorio/RJ/Municipios/RiodeJaneiro")


res<-write.alertaRio(alerioC, write = "db")
rm(alerio,alerioC,bolrio)


#***************************************************
# Cidade de Campos de Goytacazes
#***************************************************

aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE)

bolCampos <- configRelatorioMunicipal(alert = aleCampos, tipo = "completo", siglaUF = "RJ", data = data_relatorio, pars = pars.RJ,
                                             dir.out = RJ_CamposdosGoytacazes.out, geraPDF = TRUE)

publicarAlerta(ale = aleCampos, pdf = bolCampos, dir = "Relatorio/RJ/Municipios/CamposdosGoytacazes")

rm(aleCampos,bolCampos)


# ----- Fechando o banco de dados
dbDisconnect(con)


