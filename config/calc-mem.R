# Calculo dos limiares epidêmicos usando o método MEM para todo o Brasil 
# -------------

# PS. requer conexao con bd

library(tidyverse); library(assertthat)
library(AlertTools)
library(lubridate)  


## Por municipio ----

# 1. O uso original é o calculo para cada municipio separadamente e devolvendo 
 # apenas alguns indicadores para posterior insercao no banco de dados

# Exemplo: ACRE
mun_list <- getCidades(uf = "Acre", datasource=con)$municipio_geocodigo
mun_list <- 1200401
thresAC <- infodengue_apply_mem(mun_list=mun_list, database=con, 
                              end_year = 2020)
save(thresAC, file = "limiar_mem_municipal_AC_2010_2020.RData")

mun_list <- getCidades(uf = "Rio de Janeiro", datasource=con)$municipio_geocodigo
thresRJ <- infodengue_apply_mem(mun_list=mun_list, database=con, 
                                end_year = 2020)
save(thresRJ, file = "limiar_mem_municipal_RJ_2010_2020.RData")


## Por regional ----
# 2. Agora é a versao nova, para agregar por regional.
# Exemplo de uso: Amazonas

# Norte ----
cidadesAC <- getCidades(uf = "Acre")
cidadesRO <- getCidades(uf = "Rondônia")
cidadesRR <- getCidades(uf = "Roraima")
cidadesAM <- getCidades(uf = "Amazonas")
cidadesPA <- getCidades(uf = "Pará")
cidadesAP <- getCidades(uf = "Amapá")
cidadesTO <- getCidades(uf = "Tocantins")

# Acre
(regs <- unique(cidadesAC$nome_regional))
resAC <- c()
cids <- cidadesAC
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AC" 
  resAC <- rbind(resAC, xx)
}
  
# Amazonas
(regs <- unique(cidadesAM$nome_regional))
resAM <- c()
cids <- cidadesAM
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AM" 
  resAM <- rbind(resAM, xx)
}

# RO
(regs <- unique(cidadesRO$nome_regional))
resRO <- c()
cids <- cidadesRO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RO" 
  resRO <- rbind(resRO, xx)
}

# RR
(regs <- unique(cidadesRR$nome_regional))
resRR <- c()
cids <- cidadesRR
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RR" 
  resRR <- rbind(resRR, xx)
}

# AP
(regs <- unique(cidadesAP$nome_regional))
resAP <- c()
cids <- cidadesAP
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AP" 
  resAP <- rbind(resAP, xx)
}

# PA
(regs <- unique(cidadesPA$nome_regional))
resPA <- c()
cids <- cidadesPA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PA" 
  resAP <- rbind(resPA, xx)
}

# TO
(regs <- unique(cidadesTO$nome_regional))
resTO <- c()
cids <- cidadesTO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "TO" 
  resTO <- rbind(resTO, xx)
}


resN <- rbind(resAC, resAM, resAP, resRR, resRO, resPA, resTO)
save(resN, file = "memN2020.RData")
load("memN2020.RData")

### Centro oeste ----

cidadesMT <- getCidades(uf = "Mato Grosso")
cidadesMS <- getCidades(uf = "Mato Grosso do Sul")
cidadesGO <- getCidades(uf = "Goiás")
cidadesDF <- getCidades(uf = "Distrito Federal")


# MT
(regs <- unique(cidadesMT$nome_regional))
resMT <- c()
cids <- cidadesMT
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "MT" 
  resMT <- rbind(resMT, xx)
}

# MS
(regs <- unique(cidadesMS$nome_regional))
resMS <- c()
cids <- cidadesMS
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "MS" 
  resMS <- rbind(resMS, xx)
}

# GO
(regs <- unique(cidadesGO$nome_regional))
resGO <- c()
cids <- cidadesGO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "GO" 
  resGO <- rbind(resGO, xx)
}

# DF
(regs <- unique(cidadesDF$nome_regional))
resDF <- c()
cids <- cidadesDF
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "DF" 
  resDF <- rbind(resDF, xx)
}

resCO <- rbind(resMT, resMS, resDF, resGO)
save(resCO, file = "memCO.RData")
load("memCO.RData")

resCO2 <- rbind(as.data.frame(resCO[1:18]),
                as.data.frame(resCO[19:36]),
                as.data.frame(resCO[37:54]), 
                as.data.frame(resCO[55:72]))

### Sul ----

# cidades 
cidadesRS <- getCidades(uf = "Rio Grande do Sul")
cidadesPR <- getCidades(uf = "Paraná")
cidadesSC <- getCidades(uf = "Santa Catarina")

# RS
(regs <- unique(cidadesRS$nome_regional))
resRS <- c()
cids <- cidadesRS
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RS" 
  resRS <- rbind(resRS, xx)
}

# PR
(regs <- unique(cidadesPR$nome_regional))
resPR <- c()
cids <- cidadesPR
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PR" 
  resPR <- rbind(resPR, xx)
}

# SC
(regs <- unique(cidadesSC$nome_regional))
resSC <- c()
cids <- cidadesSC
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "SC" 
  resSC <- rbind(resSC, xx)
}


resS <- c(resRS, resSC, resPR)
save(resS, file = "memS.RData")
load("memS.RData")

resS2 <- rbind(as.data.frame(resS[1:18]),
                as.data.frame(resS[19:36]),
                as.data.frame(resS[37:54]))

#dbDisconnect(con)

# Sudeste ----
# cidades 
cidadesRJ <- getCidades(uf = "Rio de Janeiro")
cidadesMG <- getCidades(uf = "Minas Gerais")
cidadesES <- getCidades(uf = "Espírito Santo")
cidadesSP <- getCidades(uf = "São Paulo")

#RJ
(regs <- unique(cidadesRJ$nome_regional))
resRJ <- c()
cids <- cidadesRJ
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RJ" 
  resRJ <- rbind(resRJ, xx)
}

#ES
(regs <- unique(cidadesES$nome_regional))
resES <- c()
cids <- cidadesES
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "ES" 
  resES <- rbind(resES, xx)
}

#SP
(regs <- unique(cidadesSP$nome_regional))
resSP <- c()
cids <- cidadesSP
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "SP" 
  resSP <- rbind(resSP, xx)
}

#MG
(regs <- unique(cidadesMG$nome_regional))
resMG <- c()
cids <- cidadesMG
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "MG" 
  resMG <- rbind(resMG, xx)
}

resSE <- c(resRJ, resSP, resES, resMG)
save(resSE, file = "memSE.RData")
load("memSE.RData")

resSE2 <- rbind(as.data.frame(resSE[1:18]),
                as.data.frame(resSE[19:36]),
                as.data.frame(resSE[37:54]),
                resSP)

dbDisconnect(con)

# Nordeste ----

# cidades 
cidadesAL <- getCidades(uf = "Alagoas")
cidadesBA <- getCidades(uf = "Bahia")
cidadesCE <- getCidades(uf = "Ceará")
cidadesMA <- getCidades(uf = "Maranhão")
cidadesPB <- getCidades(uf = "Paraíba")
cidadesPE <- getCidades(uf = "Pernambuco")
cidadesPI <- getCidades(uf = "Piauí")
cidadesRN <- getCidades(uf = "Rio Grande do Norte")
cidadesSE <- getCidades(uf = "Sergipe")

#AL
(regs <- unique(cidadesAL$nome_regional))
resAL <- c()
cids <- cidadesAL
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AL" 
  resAL <- rbind(resAL, xx)
}

#BA
(regs <- unique(cidadesBA$nome_regional))
resBA <- c()
cids <- cidadesBA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "BA" 
  resBA <- rbind(resBA, xx)
}

#CE
(regs <- unique(cidadesCE$nome_regional))
resCE <- c()
cids <- cidadesCE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "CE" 
  resCE <- rbind(resCE, xx)
}

#MA
(regs <- unique(cidadesMA$nome_regional))
resMA <- c()
cids <- cidadesMA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "MA" 
  resMA <- rbind(resMA, xx)
}

# PB
(regs <- unique(cidadesPB$nome_regional))
resPB <- c()
cids <- cidadesPB
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PB" 
  resPB <- rbind(resPB, xx)
}

# PE
(regs <- unique(cidadesPE$nome_regional))
resPE <- c()
cids <- cidadesPE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PE" 
  resPE <- rbind(resPE, xx)
}

# PI
(regs <- unique(cidadesPI$nome_regional))
resPI <- c()
cids <- cidadesPI
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PI" 
  resPI <- rbind(resPI, xx)
}

# RN
(regs <- unique(cidadesRN$nome_regional))
resRN <- c()
cids <- cidadesRN
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RN" 
  resRN <- rbind(resRN, xx)
}

# SE
(regs <- unique(cidadesSE$nome_regional))
resSE <- c()
cids <- cidadesSE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$nome_regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "SE" 
  resSE <- rbind(resSE, xx)
}

resNE <- c(resAL, resBA, resCE, resMA, resPB, resPE, resPI, resRN, resSE)
save(resNE, file = "memNE.RData")
load("memNE.RData")

resNE2 <- rbind(as.data.frame(resNE[1:18]),
                as.data.frame(resNE[19:36]),
                as.data.frame(resNE[37:54]), 
                as.data.frame(resNE[55:72]),
                as.data.frame(resNE[73:90]),
                as.data.frame(resNE[91:108]),
                as.data.frame(resNE[109:126]),
                as.data.frame(resNE[127:144]),
                as.data.frame(resNE[145:162]))

#dbDisconnect(con)

### juntando

resN$regiao <- "Norte"
resNE2$regiao <- "Nordeste" 
resCO2$regiao <- "Centro-Oeste"
resSE2$regiao <- "Sudeste"
resS2$regiao <- "Sul"

mem <- rbind(resN, resNE2, resCO2, resSE2, resS2)

write.csv(mem, file = "mem_regional_2010_2020_BR.csv")





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

