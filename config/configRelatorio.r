# ========================================================
# Configuracao para o boletim do Estado do Rio de Janeiro
# ========================================================

configRelatorio <- function(uf, sigla, data, alert){
      # ------------
      ## Parte fixa
      # ------------

      estado = uf
      sigla = sigla
      municipios = getCidades(uf=estado,datasource=con)
      nmunicipios = dim(municipios)[1]
      regs = getRegionais(uf = estado) 
      nickregs = abbreviate(regs)

      # -----------
      ## Parte que muda
      # -----------
      ano = floor(data/100)
      se = data - ano*100 

      # Dados a nivel de estado
      totano=0; totultse=0
      nverde=0; namarelo=0;nlaranja=0;nvermelho=0
      nverde1=0; namarelo1=0;nlaranja1=0;nvermelho1=0
      
      linhasdoano = which(floor(alert[[1]]$data$SE/100)==ano)
      linhase = which(alert[[1]]$data$SE==data)
      linhase1 = which(alert[[1]]$data$SE==data)-1
      
      for (i in 1:nmunicipios){
            totano = totano + sum(alert[[i]]$data$casos[linhasdoano],na.rm=TRUE)
            totultse = sum(c(totultse, alert[[i]]$data$casos[linhase]),na.rm=TRUE)
            
            nverde = sum(c(nverde,as.numeric(alert[[i]]$indices$level[linhase]==1)),na.rm=TRUE)
            namarelo = sum(c(nverde,as.numeric(alert[[i]]$indices$level[linhase]==2)),na.rm=TRUE)
            nlaranja = sum(c(nverde,as.numeric(alert[[i]]$indices$level[linhase]==3)),na.rm=TRUE)
            nvermelho = sum(c(nverde,as.numeric(alert[[i]]$indices$level[linhase]==4)),na.rm=TRUE)
      
            nverde1 = sum(c(nverde1,as.numeric(alert[[i]]$indices$level[linhase1]==1)),na.rm=TRUE)
            namarelo1 = sum(c(nverde1,as.numeric(alert[[i]]$indices$level[linhase1]==2)),na.rm=TRUE)
            nlaranja1 = sum(c(nverde1,as.numeric(alert[[i]]$indices$level[linhase1]==3)),na.rm=TRUE)
            nvermelho1 = sum(c(nverde1,as.numeric(alert[[i]]$indices$level[linhase1]==4)),na.rm=TRUE)
            
      }
      
      
      
      save(estado, se, ano, nmunicipios, regs,nickregs, totano, totultse, 
      nverde, namarelo, nlaranja, nvermelho, nverde1, namarelo1, nlaranja1, nvermelho1,
      file="pp.RData")
}