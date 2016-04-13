# =============================================================================
# Arquivo de configuracao e execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
library(foreign)
library("RPostgreSQL")
#library(AlertTools)
devtools::load_all()
source("../config.R") # criterios em uso em cada regiao
source("codigofiguras.R") # codigo para as figuras do relatorio

# ---- Calcula alerta 
con <- DenguedbConnect()
data_relatorio = 201613
aleRJ <- update.alerta(region = names(pars.RJ)[1], pars = pars.RJ[1], crit = criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)
N = length(aleRJ)

# ---- Agrega em um data.frame unico (opcional) 
res <- NULL
for (i in 1:N) res <- rbind(res, write.alerta(aleRJ[[1]], write="no"))

# ---- Gera e salva figuras 
for (i in 1:N) fig.all(aleRJ[i])

# --- Gera mapas regionais
geraMapa(aleRJ, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Noroeste", filename="mapaRJ_Noroeste.png")

# Mapa completo
todos = c(alerta.BaixadaLit,alerta.LitoralSul,alerta.CenSul,alerta.Met2,
          alerta.Met1,alerta.Capital,alerta.Serrana,alerta.Norte,alerta.Noroeste)
geraMapa(todos, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Estado do Rio de Janeiro", filename="mapaRJ_todos.png")

# ------------------------
# Fechando o banco de dados
# ------------------------
dbDisconnect(con)




