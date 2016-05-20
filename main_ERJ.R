# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
source("../config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201614

# ---- Calcula alerta: 
con <- DenguedbConnect()

aleRJ9 <- update.alerta(region = names(pars.RJ)[9], pars = pars.RJ, crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

res = write(aleRJ)
#save(aleRJ, file=paste(pathrelatorio,"aleRJ.RData",sep=""))
#save(aleRJ, file="aleRJ.RData")
load("aleRJ.RData")

   
# --- Gera parametros para o boletim

configRelatorio(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, 
                alert=aleRJ, shape=RJ.shape, varid=RJ.shapeID,
                dir=RJ.out, datasource=con)


#geraMapa(aleRJ9, data=201613, shapefile="../report/RJ/shape/33MUE250GC_SIR.shp",
#         se = 201613, varid="CD_GEOCMU", titulo="Regionais Norte e Nordeste \n", legpos="topright")

#Sweave(file = '../report/newsletter_InfoDenguev2_01.Rnw')

# --- Guarda resultado no banco


# ----- Fechando o banco de dados
dbDisconnect(con)




