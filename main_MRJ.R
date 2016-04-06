# ================================================================================
# Arquivo de execução do Alerta Dengue: Municipio do Rio de Janeiro
# ================================================================================
library(foreign)
library("RPostgreSQL")
#library(AlertTools)
devtools::load_all()
source("../config.R") # criterios em uso

# --Calcula alerta (RJ.aps = criterios em uso)--
alerio <- alertaRio(pars=RJ.aps, datasource=DenguedbConnect(), verbose=FALSE)
res <- write.alertaRio(alerio, write="no")
map.Rio(alerio)
knit(input="report/matriz_relatorioMRJ.Rmd",quiet=TRUE,envir=new.env())

# Quer salvar o resultado do Alerta no Banco de Dados? 
res <- write.alertaRio(alerio, write="db")


