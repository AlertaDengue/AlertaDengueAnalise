# ================================================================================
# Arquivo de execução do Alerta Dengue: Municipio do Rio de Janeiro
# ================================================================================
diralerta = "../" # trocar por "alerta/" para usar com o pacote AlertTools
source(paste(diralerta,"/config/config.R",sep="")) # criterios em uso
data_relatorio = 201627

# --Calcula alerta--
con = DenguedbConnect()
alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, 
                    se = data_relatorio, verbose=TRUE)
res <- write.alertaRio(alerio, write="no") 
save(alerio,res,data_relatorio, file="../report/Rio_de_Janeiro/paramsRio.RData")
map.Rio(alerio,shapefile = "../report/Rio_de_Janeiro/shape/CAPS_SMS.shp") 

# configura o relatorio municipal
configRelatorioRio(alert=alerio, tres = res, data=data_relatorio)      
      
#knit(input="../report/BoletimRio_InfoDengue_v01.Rnw",quiet=TRUE,envir=new.env())

# Quer salvar o resultado do Alerta no Banco de Dados? 
res <- write.alertaRio(alerio, write="db")


