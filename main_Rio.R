# ================================================================================
# Arquivo de execução do Alerta Dengue: Municipio do Rio de Janeiro
# ================================================================================
diralerta = "../" # trocar por "alerta/" para usar com o pacote AlertTools
source("diralerta/config/config.R") # criterios em uso
se = 201622

# --Calcula alerta--
con = DenguedbConnect()
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, se = se, verbose=TRUE)
res <- write.alertaRio(alerio, write="no") 

map.Rio(alerio,shapefile = "../report/Rio_de_Janeiro/shape/CAPS_SMS.shp") 

# configura o relatorio municipal e gera pdf
configRelatorioRio<-function(alert=alerio, dir=RJ.out, datasource=con, data=data_relatorio,
                             dirbase=diralerta){
      
      map.Rio(alerio, data=data, filename="mapaRio.png", dir=paste(diralerta,
                                                                   "report/Rio_de_Janeiro/",sep="")) 
}

configRelatorioRio(alert=alerio, dir=RJ.out, datasource=con, data=data_relatorio)

geraRelatorioMunicipal(dir=RJ.out, alert=aleCampos) # ignore as mensagens de erro

knit(input="../report/matriz_relatorioMRJ.Rmd",quiet=TRUE,envir=new.env())

# Quer salvar o resultado do Alerta no Banco de Dados? 
res <- write.alertaRio(alerio, write="db")


