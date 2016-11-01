# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Paraná
# =============================================================================
setwd("~/")
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ---- Calcula alerta: 
con <- DenguedbConnect()

# ----- data do relatorio:
data_relatorio = 201642
alePR <- update.alerta(region = names(pars.PR), pars = pars.PR, crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

save(alePR, file="AlertaDengueAnalise/report/PR/alePR.RData")
#load("AlertaDengueAnalise/report/PR/alePR.RData") # se precisar parar e retornar depois, rode esse para nao precisar refazer o calculo do alerta

# --- Gera parametros para o boletim
configRelatorio(uf="Paraná", sigla = "PR", data=data_relatorio, 
                alert=alePR, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.out, datasource=con)


# Va para a pasta report/PR e knit BoletimEstadual_InfoDengue_EPR.Rnw (botao) . gerara pdf
# do relatorio na mesma pasta

nome = "EPR-2016-teste.pdf"
system(paste("cp AlertaDengueAnalise/report/PR/BoletimEstadual_InfoDengue_EPR.pdf Relatorio/PR/Estado/",nome,sep=""))

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(alePR)) res=write.alerta(alePR[[i]], write="db")  

#-----
res1=write.alerta(alePR[[1]], write="no")  
for (i in 2:length(alePR)) res1=rbind(res1,write.alerta(alePR[[i]], write="no")  )
save(res1, file="AlertaDengueAnalise/report/PR/res1.RData")

# ----- Fechando o banco de dados
dbDisconnect(con)




