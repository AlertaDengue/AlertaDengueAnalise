#==================================================
## Alertas municipais do Estado do Espírito Santo
#==================================================
setwd("~/")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
data_relatorio = 201633