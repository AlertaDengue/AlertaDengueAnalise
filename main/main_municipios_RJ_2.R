# =============================================================================
# Arquivo de execução do Alerta Dengue: Municipios do Rio de Janeiro
# =============================================================================
diralerta = "AlertaDengueAnalise/" # trocar por "alerta/" para usar com o pacote AlertTools 
source(paste(diralerta,"config/config.R",sep="")) # arquivo de configuracao do alerta (parametros)
data_relatorio = 201621
con <- DenguedbConnect()

##=========================
# Campos dos Goytacazes
## ========================
# Define o diretorio para guardar os resultados (se nao existir ainda, tem que criar)
dirrelatorio = "../report/RJ/CamposdosGoytacazes/"

# roda o alerta municipal (supoe-se que o alerta estadual ja foi rodado)
aleCampos <- update.alerta(city = 3301009, pars = pars.RJ[["Norte"]], crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = TRUE)

# configura o relatorio municipal e gera pdf
configRelatorioMunicipal(alert=aleCampos, dir=RJ.out, datasource=con, data=data_relatorio)
geraRelatorioMunicipal(dir=RJ.out, alert=aleCampos) # ignore as mensagens de erro

# copia pdf para diretorio de destino
system(paste("cp BoletimMunicipal_InfoDengue_v01.pdf ",dirrelatorio,"BoletimRJ_CamposdosGoytacazes_",
             data_relatorio,".pdf",sep=""))

# encerra a conexao
dbDisconnect(con)




