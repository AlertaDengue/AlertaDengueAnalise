# ==============================================================
# Guia de instalação do Sistema Alerta Dengue versão 1.1
# ==============================================================

# --------------------------------------------------------------
# 1. Instalar a ultima versao do AlertTools e suas dependencias

#install.packages("RPostgreSQL"); install.packages("zoo"); install.packages("maptools")
#install.packages("xtable"); install.packages("knitr"); install.packages("devtools")

remove.packages("AlertTools") # remover versao antiga
library("devtools")
#install_github("claudia-codeco/AlertTools", dependencies = TRUE) # deprecated
install_github("AlertaDengue/AlertTools", dependencies = TRUE)




