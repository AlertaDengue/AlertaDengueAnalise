# ========================================================
# Configuracao para o boletim do Estado do Rio de Janeiro
# ========================================================

configRelatorio <- function(uf,sigla,data,alertobj){
      
      # ------------
      ## Parte fixa
      # ------------
      
      estado = uf
      sigla = sigla
      
      municipios = getCidades(uf=estado)
      nmunicipios = dim(municipios)[1]
      regs <- getRegionais(uf = estado)
      nickregs <- abbreviate(regs)
      
      # -----------
      ## Parte que semanalmente
      # -----------
      ano = floor(data/100)
      se = data-ano*100
      
      # Resumo do estado (total casos no ano, incidencia acumulada no ano)
      N = length(alertobj)
      totano=0; pop=0; totultse = 0
      nverde = 0; namarelo = 0; nlaranja=0; nvermelho=0
      nverde1 = 0; namarelo1 = 0; nlaranja1=0; nvermelho1=0
      
      for (i in 1:N){
            alertobj[[i]]$data$ano <- floor(alertobj[[i]]$data$SE/100)
            casosano = alertobj[[i]]$data$casos[alertobj[[i]]$data$ano==ano]
            casosse = alertobj[[i]]$data$casos[alertobj[[i]]$data$SE==data]
            totano = totano + sum(casosano)
            totultse = totultse + casosse 
            pop = pop + unique(alertobj[[i]]$data$pop)
            
            # Cores no estado (ultima semana)
            thisse = which(alertobj[[i]]$data$SE==data)
            nverde = nverde + as.numeric(alertobj[[i]]$indices$level[thisse]==1)
            namarelo = namarelo + as.numeric(alertobj[[i]]$indices$level[thisse]==2)
            nlaranja = nlaranja + as.numeric(alertobj[[i]]$indices$level[thisse]==3)
            nvermelho = nvermelho + as.numeric(alertobj[[i]]$indices$level[thisse]==4)
            
            lastse = thisse-1
            nverde1 = nverde1 + as.numeric(alertobj[[i]]$indices$level[lastse]==1)
            namarelo1 = namarelo1 + as.numeric(alertobj[[i]]$indices$level[lastse]==2)
            nlaranja1 = nlaranja1 + as.numeric(alertobj[[i]]$indices$level[lastse]==3)
            nvermelho1 = nvermelho1 + as.numeric(alertobj[[i]]$indices$level[lastse]==4)
            
      }
      inc.acum.estado = totano/pop*100000      
      inc.se.estado = totultse/pop*100000
      
      # Tabelas regionais
      M = length(regs)
      tabela <- xtable.regional(obj = alertobj, nomesregionais = regs,
                                      estado = estado, sigla=sigla, data_mapa=data)      
      
      print(tabela)
      
      save(estado, sigla, se, ano, municipios, nmunicipios, regs,nickregs, totano, totultse, 
           nverde, namarelo, nlaranja, nvermelho, nvermelho1, namarelo1, nlaranja1, 
           nvermelho1, pathrelatorio, file=paste(sigla,"/params.RData",sep=""))
}


