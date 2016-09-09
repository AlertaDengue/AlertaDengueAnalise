## Alertas municipais do Estado do Rio de Janeiro
#==============================
setwd("~/")
con <- DenguedbConnect()
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
data_relatorio = 201635

#***********************************
### Cidade do Rio de Janeiro - - 
#***********************************

alerio <- alertaRio(pars=RJ.aps, datasource=con, crit = RJ.aps.criteria, se = data_relatorio, verbose=TRUE)        # calcula o alerta
  
res <- write.alertaRio(alerio, write="no")                  # organiza os dados do alerta no objeto res
  
save(alerio,res,data_relatorio, file="AlertaDengueAnalise/report/Rio_de_Janeiro/figs/paramsRio.RData")     # salva res
  
map.Rio(alerio,shapefile = "AlertaDengueAnalise/report/Rio_de_Janeiro/shape/CAPS_SMS.shp")            # faz mapa (so para visualizar)
  
configRelatorioRio(alert=alerio, tres = res, data=data_relatorio, 
                     dirout="AlertaDengueAnalise/report/Rio_de_Janeiro/figs/")     # gera figs e tabelas para o relatorio

# Abrir o arquivo report/Rio_de_Janeiro/BoletimRio.Rnw e executar. 

nome = "Rio-2016-teste.pdf"
system(paste("cp AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.pdf Relatorio/RJ/RiodeJaneiro/",nome,sep=""))

res <- write.alertaRio(alerio, write="db")    # salva resultado no Banco de Dados

#***************************************************
# Cidade de Campos de Goytacazes
#***************************************************

### Campos de Goitacazes (ja esta escrevendo direto no banco o resultado: writedb=TRUE)
aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = TRUE)


# ----- Fechando o banco de dados
dbDisconnect(con)

