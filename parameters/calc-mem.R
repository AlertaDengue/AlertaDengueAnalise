# Calculo dos limiares epidêmicos usando o método MEM para todo o Brasil 
# -------------

# PS. requer conexao con bd

library(tidyverse); library(assertthat)
library(RPostgreSQL)
library(AlertTools)
library(lubridate)  
#devtools::install_github("AlertaDengue/AlertTools")
#devtools::load_all()

## Lista de cidades do Brasil ----
# por regiao, e todos (cids)
load("cidades.RData")

# DENGUE ----
## MEM por UF ----
# gera indices anuais e curva epidemica

memUFanual <- c()
memUFsazonal <- c()
for(i in 1:length(cids)){  # 1:27 ufs
  muns <- cids[[i]]$municipio_geocodigo
  yy <- infodengue_apply_mem_agreg(muns,nome = cids[[i]]$uf[1])  
  memUFanual <- rbind(memUFanual, yy)
  
  xx <- as.data.frame(mem_curve(muns))  # está no infodengue_apply_mem.R (nao comitado)
  xx$UF <- cids[[i]]$uf[1]
  xx$SE <- 1:52
  names(xx) <- c("preseason","epidemic","posseason","uf","SE")
  memUFsazonal <- rbind(memUFsazonal, xx)
}

save(memUFanual, memUFsazonal, file = "mem2023.RData")

## MEM por macroregional ----
# gera indices anuais e curva epidemica

memMacroanual <- c()
memMacrosazonal <- c()

for(i in 1:length(cids)){ # ufs
  (macroregs <- unique(cids[[i]]$macroregional_id))
  print(cids[[i]]$uf[1])
  for (m in macroregs) {
    muns <- cids[[i]]$municipio_geocodigo[cids[[i]]$macroregional_id == m]
    yy <- infodengue_apply_mem_agreg(muns,nome = m)
    yy$uf <- cids[[i]]$uf[1]
    yy$macroregional <- m
    memMacroanual <- rbind(memMacroanual, yy)
    
    xx <- as.data.frame(mem_curve(muns)) 
    xx$uf <- cids[[i]]$uf[1]
    xx$macroregional <- cids[[i]]$macroregional[cids[[i]]$macroregional_id == m][1]
    xx$macroregional_id <- m
    xx$dummyweeks <- 1:52
    xx$SE <- xx$dummyweeks + 40
    xx$SE[xx$SE > 52] <- xx$SE[xx$SE > 52] - 52
    names(xx)[1:3] <- c("preseason","epidemic","posseason")
    memMacrosazonal <- rbind(memMacrosazonal, xx)
  }
}

save(memUFanual, memUFsazonal, memMacroanual, memMacrosazonal, file = "mem2023.RData")

## MEM por regional ----
# gera indices anuais e curva epidemica

memReganual <- c()
memRegsazonal <- c()

for(i in 1:length(cids)){ # ufs
  (regs <- unique(cids[[i]]$regional_id))
  print(cids[[i]]$uf[1])
  for (r in regs) {
    muns <- cids[[i]]$municipio_geocodigo[cids[[i]]$regional_id == r]
    yy <- infodengue_apply_mem_agreg(muns,nome = r)
    yy$uf <- cids[[i]]$uf[1]
    yy$regional <- cids[[i]]$regional[cids[[i]]$regional_id == r][1]
    memReganual <- rbind(memReganual, yy)
    
    xx <- as.data.frame(mem_curve(muns)) 
    xx$uf <- cids[[i]]$uf[1]
    xx$regional <- cids[[i]]$regional[cids[[i]]$regional_id == r][1]
    xx$regional_id <- r
    xx$dummyweeks <- 1:52
    xx$SE <- xx$dummyweeks + 40
    xx$SE[xx$SE > 52] <- xx$SE[xx$SE > 52] - 52
    names(xx)[1:3] <- c("preseason","epidemic","posseason")
    memRegsazonal <- rbind(memRegsazonal, xx)
  }
}

save(memUFanual, memUFsazonal, memMacroanual, memMacrosazonal, memReganual,
     memRegsazonal, file = "mem2023.RData")

# CHIKUNGUNYA
# EXEMPLO:
# resC[[1]] <- infodengue_apply_mem_agreg(muns,nome = ufs[1], cid10 = "A92.0")



# Extras ----
## OUTPUT PARA ANALISES DE FORECAST DO FLAVIO
#res$LowCases <- res$Low * res$pop /1e5
#res$MedianCases <- res$Median * res$pop /1e5
#res$HighCases <- res$High * res$pop /1e5
#resFlavio <- res %>%
#  select(macroregional_id, SE, LowCases, HighCases, uf)
#write.csv(res, file = "typical_inc_curves_macroregiao.csv",row.names = FALSE)

