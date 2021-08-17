# =============================================================================
# Arquivo de execução do Alerta Dengue Nacional
# =============================================================================
setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/github")

# ++++++++++++++++++++++++++++++++++
# Definicao dos alertas a rodar ----
# ++++++++++++++++++++++++++++++++++
source("AlertaDengueAnalise/config/config_global_2020.R") 

#lista de estados com relatorios semanais
estados_Infodengue  

# PS. se quiser rodar para outros estados sem mexer na configuracao, 
# pode substituir a tabela estados_Infodengue:

estados_Infodengue <- data.frame(
  estado = c("Acre"),
  sigla = "SP",
  dengue = TRUE,
  chik = TRUE,
  zika = FALSE
)


# ++++++++++++++++++++++++
# data do relatorio:----
# ++++++++++++++++++++++++
data_relatorio = 202120
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# ++++++++++++++++++++++++
# ----- Conexao ----
# ++++++++++++++++++++++++
# com banco remoto do Infodengue (original)
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

# com banco local SQlite: para implementar ainda 
#con <- dbConnect(RSQLite::SQLite(), 
#                   "AlertaDengueAnalise/mydengue.sqlite")

#dbListTables(con) # verificar se as tabelas estão todas no banco. 
# se estiver vazio, ou o endereco está errado, ou o banco sqlite nao foi criado.

# +++++++++++++++++++++++++
# Pipeline ----
# +++++++++++++++++++++++++

t1 <- Sys.time()

for(i in 1:nrow(estados_Infodengue)){
    estado <- estados_Infodengue$estado[i] 
    sig <- estados_Infodengue$sigla[i]
    
    agravos <- c("dengue","chik","zika")[which(
      estados_Infodengue[i, 3:5] == TRUE)]

    # nome do arquivo para salvar alertas (como lista)
    nomeRData <- paste0("alertasRData/ale-",sig,
                        "-",data_relatorio,".RData")  
    
    # cidades --------------------------------
    cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
    
    res <- list() # guardar tudo numa lista
    # alerta dengue
    if(estados_Infodengue$dengue[estados_Infodengue$estado == estado]) {
      res[["ale.den"]] <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian", 
                               finalday = dia_relatorio, narule = "arima", 
                               iniSE = 201001, dataini = "sinpri", completetail = 0)
    
      res[["restab.den"]] <- tabela_historico(res[["ale.den"]], iniSE = data_relatorio - 100)  # so as ultimas 100 semanas
      save(res, file = nomeRData)
    }
    
    # alerta chik
    if(estados_Infodengue$chik[estados_Infodengue$estado == estado]){
      res[["ale.chik"]] <- pipe_infodengue(cidades, cid10 = "A92", nowcasting = "bayesian", 
                                           finalday = dia_relatorio, narule = "arima", 
                                           iniSE = 201001, dataini = "sinpri", completetail = 0)  
      
      res[["restab.chik"]] <- tabela_historico(res[["ale.chik"]], iniSE = data_relatorio - 100)  # so as ultimas 100 semanas
      save(res, file = nomeRData)
    }
      
    # alerta zika
    if(estados_Infodengue$zika[estados_Infodengue$estado == estado]){
    res[["ale.zika"]] <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "bayesian", 
                                           finalday = dia_relatorio, narule = "arima", 
                                           iniSE = 201001, dataini = "sinpri", completetail = 0)  
    res[["restab.zika"]] <- tabela_historico(res[["ale.zika"]], iniSE = data_relatorio - 100)  # so as ultimas 100 semanas
    save(res, file = nomeRData)
    }
    
    # copiar o arquivo RData para o servidor (o formato mudou! os ale.* estao todos dentro de uma lista)
    system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))
    
    # escrevendo no servidor
    if("restab.den" %in% names(res)) write_alerta(res[["restab.den"]])
    if("restab.chik" %in% names(res)) write_alerta(res[["restab.chik"]])
    if("restab.zika" %in% names(res)) write_alerta(res[["restab.zika"]])
    
  }
  t2 <- Sys.time()
  message(paste("total time was", t2-t1))

# ----- Fechando o banco de dados local -----------
dbDisconnect(con)


