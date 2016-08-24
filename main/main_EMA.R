# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Maranhão
# =============================================================================
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201631

# ---- Calcula alerta: 
con <- DenguedbConnect()

aleMA <- update.alerta(region = names(pars.MA), pars = pars.MA, crit = MA.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

save(aleMA, file="AlertaDengueAnalise/report/MA/aleMA.RData")
#load("AlertaDengueAnalise/report/MA/aleMA.RData") # se precisar parar e retornar depois, rode esse para nao precisar refazer o calculo do alerta

# --- Gera parametros para o boletim
configRelatorio(uf="Maranhão", sigla = "MA", data=data_relatorio, 
                alert=aleMA, pars = pars.MA, shape=MA.shape, varid=MA.shapeID,
                dir=MA.out, datasource=con)

# Va para a pasta report/MA e knit Boletim_Estadual_MA.Rnw (botao) . gerara pdf
# do relatorio na mesma pasta

nome = "EMA-2016-teste.pdf"
system(paste("cp AlertaDengueAnalise/report/MA/BoletimEstadual_MA.pdf Relatorio/MA/EMA/",nome,sep=""))

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(aleMA)) res=write.alerta(aleMA[[i]], write="db")  

# ----- Fechando o banco de dados
dbDisconnect(con)

