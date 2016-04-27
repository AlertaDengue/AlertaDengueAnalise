# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
ESTADO = "Rio de Janeiro"
# =============================================================================
source("../config/config.R") # arquivo de configuracao do alerta (parametros)
source("codigofiguras.R") # codigo para as figuras do relatorio


# ---- Calcula alerta 
con <- DenguedbConnect()
data_relatorio = 201614
aleRJ <- update.alerta(region = names(pars.RJ)[1], pars = pars.RJ, crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

#save(aleRJ, file=paste(pathrelatorio,"aleRJ.RData",sep=""))
save(aleRJ, file="aleRJ.RData")
# ---- Gera e salva figuras 
for (i in 1:N) fig.all(aleRJ[i])
for (i in 1:N) fig.cores(aleRJ[i])

# --- Gera e salva mapas regionais
nomesregs = getRegionais(ESTADO)
mapa.regional(alerta=aleRJ, regionais=nomesregs, estado = ESTADO, sigla = "RJ",
              shape = RJ.shape, shapeid = RJ.shapeID )


# --- Gera e salva mapa estadual
geraMapa(alerta=aleRJ, data=data_relatorio, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="" ,filename="Mapa_ERJ.png", caption=FALSE)

# --- Gera parametros para o boletim
source('../report/RJ/configRelatorio.R')
configRelatorio(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, alertobj=aleRJ)


#Sweave(file = '../report/newsletter_InfoDenguev2_01.Rnw')

# --- Gera boletim


# --- Guarda resultado no banco


# ----- Fechando o banco de dados
dbDisconnect(con)




