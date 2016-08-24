# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================
source("../config/config.R") # arquivo de configuracao do alerta (parametros)

# ----- data do relatorio:
data_relatorio = 201627

# ---- Calcula alerta: 
con <- DenguedbConnect()

aleRJ <- update.alerta(region = names(pars.RJ), pars = pars.RJ, crit = RJ.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

save(aleRJ, file="../report/RJ/aleRJ.RData")
#load("../report/RJ/aleRJ.RData") # se precisar parar e retornar depois, rode esse para nao precisar refazer o calculo do alerta

# --- Gera parametros para o boletim
configRelatorio(uf="Rio de Janeiro", sigla = "RJ", data=data_relatorio, 
                alert=aleRJ, shape=RJ.shape, varid=RJ.shapeID,
                dir=RJ.out, datasource=con)

# Va para a pasta report/RJ e knit Boletim_Rio_infodengue_v01.Rnw (botao) . gerara pdf
# do relatorio na mesma pasta

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(aleRJ)) res=write.alerta(aleRJ[[i]], write="db")  

# ----- Fechando o banco de dados
dbDisconnect(con)



