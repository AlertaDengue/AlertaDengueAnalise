# Calculo dos limiares epidêmicos usando o métido MEM 
# -------------

# PS. requer conexao con bd

library(tidyverse); library(assertthat)
library(AlertTools)
library(lubridate)  



# 1. O uso original é o calculo para cada municipio separadamente e devolvendo 
 # apenas alguns indicadores para posterior insercao no banco de dados

# Exemplo:
#mun_list <- getCidades(uf = "Acre", datasource=con)$municipio_geocodigo
#thres <- infodengue_apply_mem(mun_list=mun_list, database=con, 
#                              end_year = 2020)
#thres

# 2. Agora é a versao nova, para agregar por regional.
# Exemplo de uso: Amazonas

cids <- getCidades(uf = "Amazonas")
head(cids)

# Calcular MEM por regional de saude
regs <- unique(cids$nome_regional)
regs

res <- c()
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  res <- rbind(res, xx)
}
  
# Tarefa : rodar para todos os estados e salvar num arquivo csv. 
# criar uma coluna UF no csv

#### OLD #############
# sempre verificar se tem NA
#summary(thres$thresholds)
#summary(thres$min_threshold_inc)
#summary(thres$percentiles)
#summary(thres$mem)

# caso tenha:
#pp <- thres$thresholds$municipio_geocodigo[is.na(thres$thresholds$limiar_epidemico)]
#for (i in pp){
#  thres$thresholds$limiar_epidemico[thres$thresholds$municipio_geocodigo == i] <- 
#    thres$min_threshold_inc$mininc_epi[thres$min_threshold_inc$municipio_geocodigo == i]
#  
#  thres$thresholds$limiar_preseason[thres$thresholds$municipio_geocodigo == i] <- 
#    thres$min_threshold_inc$mininc_pre[thres$min_threshold_inc$municipio_geocodigo == i]
#  
#  thres$thresholds$limiar_posseason[thres$thresholds$municipio_geocodigo == i] <- 
#    thres$min_threshold_inc$mininc_pos[thres$min_threshold_inc$municipio_geocodigo == i]
#  
#} 
#summary(thres$thresholds)

#save(thres, file ="thresSC.RData")

