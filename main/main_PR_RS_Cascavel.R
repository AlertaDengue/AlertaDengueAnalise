# =============================================================================
# Arquivo de execução do Alerta Dengue: Regional de saúde Cascavel - Estado do Paraná
# =============================================================================
source("AlertaDengueAnalise/config/config.R") # arquivo de configuracao do alerta (parametros)

# ---- Calcula alerta: 
con <- DenguedbConnect()
lastDBdate("sinan", city=410690)
lastDBdate("tweet", city=410690)

# ----- data do relatorio:
data_relatorio = 201633
alePR_RS_Cascavel <- update.alerta(region = names(pars.PR), pars = pars.PR[["Cascavel"]], crit = PR.criteria, 
                       datasource = con, sefinal=data_relatorio, writedb = FALSE)

save(alePR_RS_Cascavel, file="AlertaDengueAnalise/report/PR/alePR_RS_Cascavel.RData")
#load("AlertaDengueAnalise/report/PR/alePR.RData") # se precisar parar e retornar depois, rode esse para nao precisar refazer o calculo do alerta

# --- Gera parametros para o boletim
configRelatorio(uf="Paraná", sigla = "PR", data=data_relatorio, 
                alert=alePR_RS_Cascavel, pars = pars.PR, shape=PR.shape, varid=PR.shapeID,
                dir=PR.out, datasource=con)


# Va para a pasta report/PR e knit BoletimEstadual_InfoDengue_EPR.Rnw (botao) . gerara pdf
# do relatorio na mesma pasta

nome = "PR-RS-Cascavel-teste.pdf"
system(paste("cp AlertaDengueAnalise/report/PR-RS-Cascavel/Boletim_PR_RS_Cascavel_InfoDengue.pdf Relatorio/PR/PR-RS-Cascavel/",nome,sep=""))

# --- Guarda resultado no historico_alerta (e atualizar o mapa no site)
for (i in 1:length(alePR_RS_Cascavel)) res=write.alerta(alePR_RS_Cascavel[[i]], write="db")  

#-----
#extrair dados específicos do servidor
res1=write.alerta(alePR_RS_Cascavel[[1]], write="no")  
for (i in 2:length(alePR_RS_Cascavel)) res1=rbind(res1,write.alerta(alePR[[i]], write="no")  )
save(res1, file="AlertaDengueAnalise/report/PR/res1.RData")

# ----- Fechando o banco de dados
dbDisconnect(con)

