# =============================================================================
# Arquivo de execução do Alerta Dengue Nacional
# =============================================================================
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC

setwd("~/MEGA/Pesquisa/Linhas-de-Pesquisa/e-vigilancia/")

# ++++++++++++++++++++++++++++++++++
# Definicao dos alertas a rodar ----
# ++++++++++++++++++++++++++++++++++
source("AlertaDengueAnalise/config/config_global_2020.R") #lista de estados

estados_Infodengue  

# PS. se quiser rodar para outros estados sem mexer na configuracao, 
# pode substituir a tabela estados_Infodengue:

estados_Infodengue <- data.frame(
  estado = c("São Paulo"),
  sigla = "SP",
  dengue = "sim",
  chik = "sim",
  zika = "nao"
)


# ++++++++++++++++++++++++
# data do relatorio:----
# ++++++++++++++++++++++++
data_relatorio = 202116
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# ++++++++++++++++++++++++
# ----- Conexao ----
# ++++++++++++++++++++++++
# com banco remoto do Infodengue (original)
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
      estados_Infodengue[i, 3:5] == "sim")]

    # nome do arquivo para salvar alertas (como lista)
    nomeRData <- paste0("alertasRData/ale-",sig,
                        "-",data_relatorio,".RData")  
    
    # cidades --------------------------------
    cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
    
    # lista para guardar os alertas do estado
    res <- list()
    
    if("dengue" %in% agravos) {
      res[["ale.den"]] <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "bayesian", 
                               finalday = dia_relatorio, narule = "arima", 
                               iniSE = 201001, dataini = "sinpri", completetail = 0)
    
      restab.den <- tabela_historico(ale.den, iniSE = data_relatorio - 100)  # so as ultimas 100 semanas
    }
      
    if("chik" %in% agravos) res[["ale.chik"]] <- pipe_infodengue(cidades, cid10 = "A92", nowcasting = "bayesian", 
                                                    finalday = dia_relatorio, narule = "arima", 
                                                    iniSE = 201001, dataini = "sinpri", completetail = 0)  
    
    if("zika" %in% agravos) res[["ale.zika"]] <- pipe_infodengue(cidades, cid10 = "A92.8", nowcasting = "bayesian", 
                                                        finalday = dia_relatorio, narule = "arima", 
                                                        iniSE = 201001, dataini = "sinpri", completetail = 0)  
    
    # salvando os objetos gerados para o estado (usados pelo relatorio)
    save(res, nomeRData)
    
    #system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))
    
    # update da tabela historico_alerta
     semanas
    
    summary(restab.den)  # verificar se tem algo estranho (numero estourado)
    write_alerta(restab.den)
    
    
    
  }


  t2 <- Sys.time()
  message(paste("total time was", t2-t1))



# salvando alerta RData no servidor  ----
#flog.info("saving ...", Rfile, capture = TRUE, name = alog)
#system(paste("scp", nomeRData, "infodengue@info.dengue.mat.br:/home/infodengue/alertasRData/"))

# ----- Fechando o banco de dados local -----------
dbDisconnect(con)


