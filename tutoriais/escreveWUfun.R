library(AlertTools)

# insere parametros de param.csv na tabela regionais 

escrevewu <- function(csvfile){
  wus <- read.csv(csvfile,header = F)
  wusES <- wus[,c(2,4,6)]
  names(wusES) <- c("geocodigo", "estacao", "dist")
  newdat <- data.frame(municipio_geocodigo=unique(wusES$geocodigo), codigo_estacao_wu=NA,
                       estacao_wu_sec=NA)
  for(cid in newdat$municipio_geocodigo) {
    estacoes <- wusES[wusES$geocodigo==cid,]
    estacoes <- estacoes[order(estacoes$dist),] # ordm decresc distancia
    newdat$codigo_estacao_wu[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[1])
    newdat$estacao_wu_sec[newdat$municipio_geocodigo==cid] <- as.character(estacoes$estacao[2])
  }
  newpars = c("codigo_estacao_wu","estacao_wu_sec")
  res = write.parameters(newpars,newdat,senha="aldengue")
  newdat
}

escrevewu("estações-mais-proximas-MG.csv")