# ================================================================================
# Arquivo de execução do Alerta Dengue: Municipio do Rio de Janeiro
# ================================================================================
source("../config.R") # criterios em uso

# --Calcula alerta--
con = DenguedbConnect()
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, verbose=TRUE)
res <- write.alertaRio(alerio, write="no") 
map.Rio(alerio) 
knit(input="report/matriz_relatorioMRJ.Rmd",quiet=TRUE,envir=new.env())

# Quer salvar o resultado do Alerta no Banco de Dados? 
res <- write.alertaRio(alerio, write="db")


