# =============================================================================
# Arquivo de configuracao e execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
library(foreign)
library("RPostgreSQL")
#library(AlertTools)
devtools::load_all()
source("../config.R") # criterios em uso em cada regiao

# --------------------------------------
# Abrindo e verificando o banco de dados
# --------------------------------------
con <- DenguedbConnect()
## Verificacoes: os dados estao atualizados?
lastDBdate("sinan")
lastDBdate("tweet")
lastDBdate("clima_wu")
lastDBdate("historico")
# cidade especifica: 
lastDBdate("sinan", city=330240)
lastDBdate("sinan", city=330455)

# ======================================
# Quer salvar o resultado do Alerta no Banco de Dados? 
escreverBD <- FALSE   # use TRUE apenas quando tiver seguro pois irá aparecer no mapa

#==========================================
# ALERTA POR REGIONAL
#==========================================
# Definir a data alvo para o relatorio.
datafim = 201613

# Noroeste
alerta.Noroeste <- run.pipeline(regional="Noroeste", pars = RJ.noroeste, datasource = con,
                               sefinal=datafim, writedb = escreverBD)

alerta.Norte <- run.pipeline(regional="Norte", pars = RJ.norte, datasource = con,
                               sefinal=datafim, writedb = escreverBD)

alerta.Serrana <- run.pipeline(regional="Serrana", pars = RJ.serrana, datasource = con,
                            sefinal=datafim, writedb = escreverBD)

alerta.BaixadaLit <- run.pipeline(regional="Baixada Litorânea", pars = RJ.serrana, datasource = con,
                            sefinal=datafim, writedb = escreverBD)

alerta.Met1 <- run.pipeline(regional="Metropolitana I", pars = RJ.met1, datasource = con,
                            sefinal=datafim, writedb = escreverBD)

alerta.Met2 <- run.pipeline(regional="Metropolitana II", pars = RJ.met2, datasource = con,
                           sefinal=datafim, writedb = escreverBD)

alerta.CenSul <- run.pipeline(regional="Centro Sul", pars = RJ.centrosul, datasource = con,
                           sefinal=datafim, writedb = escreverBD)

alerta.MedParaiba <- run.pipeline(regional="Médio Paraíba", pars = RJ.medparaiba, datasource = con,
                                 sefinal=datafim, writedb = escreverBD)

alerta.LitoralSul <- run.pipeline(regional="Litoral Sul", pars = RJ.litoralsul, datasource = con,
                                 sefinal=datafim, writedb = escreverBD)

alerta.Capital <- run.pipeline(cidade=330455, pars = RJ.capital, datasource = con,
                              sefinal=datafim, writedb = escreverBD)

### Salvando figuras
# Os codigos das figuras estao no arquivo codigofiguras.R. Aqui nós especificamos
# qual a gente quer usar.
source("codigofiguras.R")
fig.all(alerta.Noroeste)
fig.all(alerta.Norte)
fig.all(alerta.Serrana)
fig.all(alerta.BaixadaLit)
fig.all(alerta.Met1)
fig.all(alerta.Met2)
fig.all(alerta.CenSul)
fig.all(alerta.MedParaiba)
fig.all(alerta.LitoralSul)
fig.all(alerta.Capital)

### Salvando Mapas regionais
geraMapa(alerta.Noroeste, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Noroeste", filename="mapaRJ_Noroeste.png")

geraMapa(alerta.Norte, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Norte", filename="mapaRJ_Norte.png")

geraMapa(alerta.Serrana, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Serrana", filename="mapaRJ_Serrana.png")

geraMapa(alerta.BaixadaLit, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Baixada Litorânea", filename="mapaRJ_BaixLitoranea.png")

geraMapa(c(alerta.Met1, alerta.Capital), data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Metropolitana 1", filename="mapaRJ_Met1.png")

geraMapa(alerta.Met2, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Metropolitana 2", filename="mapaRJ_Met2.png")

geraMapa(alerta.CenSul, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Centro Sul", filename="mapaRJ_CenSul.png")

geraMapa(alerta.MedParaiba, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Medio Paraíba", filename="mapaRJ_MedParaiba.png")

geraMapa(alerta.LitoralSul, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Regional Litoral Sul", filename="mapaRJ_LitoralSul.png")

# mapa completo
todos = c(alerta.BaixadaLit,alerta.LitoralSul,alerta.CenSul,alerta.Met2,
          alerta.Met1,alerta.Capital,alerta.Serrana,alerta.Norte,alerta.Noroeste)
geraMapa(todos, data=datafim, shapefile=RJ.shape, varid=RJ.shapeID, 
         titulo="Estado do Rio de Janeiro", filename="mapaRJ_todos.png")
# ------------------------
# Fechando o banco de dados
# ------------------------
dbDisconnect(con)




