## Alertas municipais do Estado do Rio de Janeiro
#==============================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)
con <- DenguedbConnect()

data_relatorio = 201634

#***********************************
### Cidade do Rio de Janeiro - - 
#***********************************

alerio <- alertaRio(pars=RJ.aps, crit = RJ.aps.criteria, datasource=con, se = data_relatorio, verbose=TRUE)        # calcula o alerta
  
res <- write.alertaRio(alerio, write="no")                  # organiza os dados do alerta no objeto res
  
save(alerio,res,data_relatorio, file="AlertaDengueAnalise/report/Rio_de_Janeiro/figs/paramsRio.RData")     # salva res
  
map.Rio(alerio,shapefile = "AlertaDengueAnalise/report/Rio_de_Janeiro/shape/CAPS_SMS.shp")            # faz mapa (so para visualizar)
  
configRelatorioRio(alert=alerio, tres = res, data=data_relatorio, 
                     dirout="AlertaDengueAnalise/report/Rio_de_Janeiro/figs/")     # gera figs e tabelas para o relatorio

# Abrir o arquivo report/Rio_de_Janeiro/BoletimRio.Rnw e executar (unica parte ainda manual) 
# Para renomear e copiar para a pasta RiodeJaneiro/boletins
nome = paste("RJ-mn-RiodeJaneiro",Sys.Date(),".pdf",sep="")
system(paste("cp AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.pdf AlertaDengueAnalise/report/Rio_de_Janeiro/boletins",nome,sep=""))
system(paste("cp AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.pdf Relatorio/RJ/Municipios/RiodeJaneiro/",nome,sep=""))

# Para apagar arquivos temporarios 
system("rm AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.pdf")
system("rm AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.tex")
system("rm AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio.log")
system("rm AlertaDengueAnalise/report/Rio_de_Janeiro/BoletimRio-concordance.tex")

# Para fazer o update no site
res <- write.alertaRio(alerio, write="db")    # salva resultado no Banco de Dados

#***************************************************
# Cidade de Campos de Goytacazes
#***************************************************

aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
                           datasource = con, sefinal=data_relatorio, writedb = TRUE)

bolCampos <- configRelatorioMunicipal(alert = aleCampos, tipo = "simples", siglaUF = "RJ", data = data_relatorio, 
                                             dir.out = RJ_CamposdosGoytacazes.out, geraPDF = TRUE)

publicarAlerta(ale = aleCampos, pdf = bolCampos, dir = "Relatorio/RJ/Municipios/CamposdosGoytacazes")



# ----- Fechando o banco de dados
dbDisconnect(con)



