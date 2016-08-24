# =============================================================================
# Arquivo de execução do Alerta Dengue: Distrito Federal
# =============================================================================
source("alerta/config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201631

# ---- Calcula alerta: 
con <- DenguedbConnect()

aleDF <- update.alerta(region = names(pars.DF), pars = pars.DF, crit = DF.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

save(aleDF, file="alerta/report/DF/aleDF.RData")
#load("alerta/report/DF/aleDF.RData") # se precisar parar e retornar depois, rode esse para nao precisar refazer o calculo do alerta

# --- Gera parametros para o boletim
configRelatorio(uf="Distrito Federal", sigla = "DF", data=data_relatorio, 
                alert=aleDF, pars = pars.DF, shape=DF.shape, varid=DF.shapeID,
                dir=DF.out, datasource=con)

# Va para a pasta report/DF e knit Boletim_Estadual_DF.Rnw (botao) . gerara pdf
# do relatorio na mesma pasta

nome = "EDF-2016-teste.pdf"
system(paste("cp alerta/report/DF/BoletimEstadual_DF.pdf Relatorio/DF/EDF/",nome,sep=""))

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(aleDF)) res=write.alerta(aleDF[[i]], write="db")  

# ----- Fechando o banco de dados
dbDisconnect(con)

