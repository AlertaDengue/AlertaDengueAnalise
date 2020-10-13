## publicarAlerta ------------------
## Funcao para salvar o resultado do alerta no banco de dados
## e publicr o relatorio

publicar_alerta <- function(ale, pdf, dir, bdir = basedir, ndays = 365, writebd = TRUE){
  # A função write_alerta sabe se e para salvar na tabela de chik ou de dengue
  
  if(writebd)  message("atualizando a tabela do historico...")
  
  # fazer update apenas das ultimas ndays = 365 dias
  
  # Se é cidade do Rio ou outros 
  if("APS 1" %in% names(ale)) {
    restab  <- ifelse(writebd, write_alertaRio(ale, write = "db"),
                      write_alertaRio(ale, write = "no"))
  }else{
    
    restab <- tabela_historico(ale) %>%   # so fazer update das ultimas 52 semanas
      filter(data_iniSE > (max(data_iniSE) - ndays))
    
    if(writebd) res <- write_alerta(restab) 
  }
  
  
  message("Copia o boletim para a pagina do site...")
  strip <- strsplit(pdf,"/")[[1]]
  nomeb = strip[length(strip)] # nome do boletim
  bolpath <- paste(bdir,dir,nomeb,sep="/") # boletim com path completo
  comando <- paste ("cp", pdf, bolpath) 
  print(comando)
  system(comando) 
}
