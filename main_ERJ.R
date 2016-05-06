# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
source("../config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201613

# ---- Calcula alerta: 
con <- DenguedbConnect()

aleRJ <- update.alerta(region = names(pars.RJ), pars = pars.RJ, crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

res = write(aleRJ)
#save(aleRJ, file=paste(pathrelatorio,"aleRJ.RData",sep=""))
#save(aleRJ, file="aleRJ.RData")
load("aleRJ.RData")

# --- Gera parametros para o boletim
configRelatorio(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, 
                alert=aleRJ, dir=RJ.out, datasource=con)


# ---- Gera e salva figuras 
for (i in 1:N) fig.all(aleRJ[i])
for (i in 1:N) fig.cores(aleRJ[i])

# --- Gera mapas:
# Estadual
geraMapa(alerta=aleRJ, se=data_relatorio, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="" ,filename="Mapa_ERJ.png", dir=RJ.out ,caption=FALSE)
# Regionais
mapa.regional(alerta=aleRJ, regionais=nomesregs, estado = "Rio de Janeiro", sigla = "RJ",
              shape = RJ.shape, shapeid = RJ.shapeID, dir=RJ.out,datasource=con )

# --- Gera e salva mapa estadual




#Sweave(file = '../report/newsletter_InfoDenguev2_01.Rnw')

# --- Gera boletim


# --- Guarda resultado no banco


# ----- Fechando o banco de dados
dbDisconnect(con)




