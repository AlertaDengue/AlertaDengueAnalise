# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
ESTADO = "Rio de Janeiro"
# =============================================================================
source("../config.R") # criterios em uso em cada regiao
source("codigofiguras.R") # codigo para as figuras do relatorio


# ---- Calcula alerta 
con <- DenguedbConnect()
data_relatorio = 201613
aleRJ <- update.alerta(region = names(pars.RJ), pars = pars.RJ, crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

# ---- Gera e salva figuras 
for (i in 1:N) fig.all(aleRJ[i])

# --- Gera e salva mapas regionais
nomesregs = getRegionais(ESTADO)
mapa.regional(alerta=aleRJ, regionais=nomesregs, estado = ESTADO, sigla = "RJ",
              shape = RJ.shape, shapeid = RJ.shapeID )


# --- Gera e salva mapa estadual
geraMapa(alerta=aleRJ, data=data_relatorio, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo=("Estado do Rio de Janeiro") ,filename="Mapa_ERJ.png", caption=FALSE)


# --- Gera tabelas para relatorio
N = length(aleRJ)
res <- NULL
for (i in 1:N) res <- rbind(res, write.alerta(aleRJ[[i]], write="no"))

# --- Gera relatorio

# --- Guarda resultado no banco


# ----- Fechando o banco de dados
dbDisconnect(con)




