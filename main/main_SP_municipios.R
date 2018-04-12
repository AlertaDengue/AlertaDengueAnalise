#====================================================
## Alertas municipais do Estado de São Paulo
#====================================================
setwd("~/"); library("AlertTools")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

data_relatorio = 201814

# =====
# SJRP
# =====
# Dengue
aleSJRP.dengue <- update.alerta(city = 3549805, pars = pars.SP[["São José do Rio Preto"]], crit = PR.criteria, 
                                  datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = TRUE)
# Chik tem muito pouco caso 
aleSJRP.chick <- update.alerta(city = 3549805, pars = pars.SP[["São José do Rio Preto"]], cid10="A92.0", crit = PR.criteria, 
                          datasource = con, sefinal=data_relatorio, writedb = FALSE, adjustdelay = FALSE)


bolSJRP<- configRelatorioMunicipal(alert = aleSJRP.dengue, tipo = "simples", siglaUF = "SP", 
                                             data = data_relatorio, pars = pars.SP[["São José do Rio Preto"]], 
                                             dir.out = SP.MN.SJRP.out, geraPDF = TRUE) 

publicarAlerta(ale = aleSJRP.dengue, pdf = bolSJRP, dir = "Relatorio/SP/Municipios/SaoJosedoRioPreto")

# ----- Fechando o banco de dados



