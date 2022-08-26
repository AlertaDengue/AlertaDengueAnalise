# Calculo dos limiares epidêmicos usando o método MEM para todo o Brasil 
# -------------

# PS. requer conexao con bd

library(tidyverse); library(assertthat)
library(AlertTools)
library(lubridate)  
#devtools::install_github("AlertaDengue/AlertTools")
#devtools::load_all()

## Por municipio ----

# 1. O uso original é o calculo para cada municipio separadamente e devolvendo 
 # apenas alguns indicadores para posterior insercao no banco de dados

# Exemplo: ACRE
# mun_list <- getCidades(uf = "Acre", datasource=con)$municipio_geocodigo
# mun_list <- 1200401
# thresAC <- infodengue_apply_mem(mun_list=mun_list, database=con, 
#                               end_year = 2020)
# save(thresAC, file = "limiar_mem_municipal_AC_2010_2020.RData")
# 
# mun_list <- getCidades(uf = "Rio de Janeiro", datasource=con)$municipio_geocodigo
# thresRJ <- infodengue_apply_mem(mun_list=mun_list, database=con, 
#                                 end_year = 2020)
# save(thresRJ, file = "limiar_mem_municipal_RJ_2010_2020.RData")

# 2. Para todos os municipios - metodo novo

#thres.mun <- c()

ufs1 <- c("Rondônia", "Roraima", "Amazonas", "Pará", "Amapá", "Tocantins")
ufs2 <- c("Alagoas", "Bahia", "Ceará", "Maranhão", "Paraíba", "Pernambuco", "Piauí",
         "Rio Grande do Norte", "Sergipe")
ufs3 <- c("Mato Grosso", "Mato Grosso do Sul", "Distrito Federal", "Goiás", "São Paulo")
ufs4 <- c("Rio Grande do Sul", "Rio de Janeiro")
ufs5 <- c("Minas Gerais", "Espírito Santo",  "Paraná")

estados <- c(ufs1, ufs2, ufs3, ufs4, ufs5)
thres.22 <- list()

for (u in estados){
  rm(thres, thres.mem, mun_list)
  print(u)
  mun_list <- getCidades(uf = u, datasource=con)$municipio_geocodigo  
  thres <- infodengue_apply_mem(mun_list=mun_list, database=con,
                                end_year = 2021)
  thres.mem <- thres$mem
  thres.mem$pop <- thres$min_threshold_inc$populacao
  thres.mem$limiar_preaseason <- thres$thresholds$limiar_preseason
  thres.mem$limiar_posseason <- thres$thresholds$limiar_posseason
  thres.mem$limiar_epidemico <- thres$thresholds$limiar_epidemico
  thres.mem$mininc_pre <- thres$min_threshold_inc$mininc_pre
  thres.mem$mininc_pos <- thres$min_threshold_inc$mininc_pos
  thres.mem$mininc_epi <- thres$min_threshold_inc$mininc_epi
  thres.mem$duracao <- thres$mem$duracao
  thres.mem$duracao.ic <- thres$mem$duracao.ic
  thres.mem$inicio <- thres$mem$inicio
  thres.mem$inicio.ic <- thres$mem$inicio.ic
  thres.mem$uf <- u
  thres.mem$ano_ini <- thres$thresholds$ano_inicio
  thres.mem$ano_fim <- thres$thresholds$ano_fim
  
  thres.22[[u]] <- thres.mem
  save(thres.22, file = "thres22.RData")
}

data <- thres.22 %>% bind_rows()
data$uf <- as.factor(data$uf)
levels(data$uf)
ufs_ordered <-  c("Roraima","Amapá","Acre",
                           "Amazonas","Pará","Rondônia","Tocantins",
                           "Maranhão","Piauí","Ceará","Rio Grande do Norte",
                           "Paraíba","Pernambuco","Alagoas","Sergipe","Bahia",
                           "Goiás", "Distrito Federal","Mato Grosso" , "Mato Grosso do Sul",
                           "Minas Gerais", "Espírito Santo","Rio de Janeiro",
                           "São Paulo","Paraná", "Santa Catarina", "Rio Grande do Sul")
data$uf <- ordered(data$uf, levels = ufs_ordered)
levels(data$uf) <- c("RR","AP","AC","AM","PA","RO","TO","MA","PI","CE","RN",
                          "PB","PE","AL","SE","BA","GO","DF","MT","MS","MG","ES","RJ",
                          "SP","PR","SC","RS")

data$pop_cat <- cut(data$pop, breaks = c(0,1000,1e4,1e5,1e6,1e7,1e8))

png("mem_ini_duracao_temporada_2010_2021.png", width = 700)
par(mfrow = c(2,1), mar = c(3,4,3,1))
# inicio
boxplot(inicio ~ uf, data = data, xlab = "", 
        main = "Início temporada típica de dengue",
        ylab = "semana", col = c(rep("green", 7), rep("cyan", 9), rep("orange", 4),
                                 rep("darkblue", 4), rep("violet", 3)),cex.axis = 0.8)
#duracao
boxplot(duracao ~ uf, data = data, xlab = "", 
        main = "Duração temporada típica de dengue",
        ylab = "semanas", col = c(rep("green", 7), rep("cyan", 9), rep("orange", 4),
                                 rep("darkblue", 4), rep("violet", 3)),cex.axis = 0.8)
dev.off()

#incidencia pre-season
png("mem_inc_preseason_2010_2021.png", width = 700)
par(mfrow = c(2,1), mar = c(3,4,3,1))
boxplot(inc_preseason ~ uf, data = data, xlab = "", ylim = c(0,15),
        main = "Limiar início de temporada de dengue",
        ylab = "incidência (por 100.000)", col = c(rep("green", 7), rep("cyan", 9), rep("orange", 4),
                                  rep("darkblue", 4), rep("violet", 3)),cex.axis = 0.8)

boxplot(inc_preseason ~ pop_cat, data = data, 
        main = "Limiar início de temporada de dengue", xlab = "populaçao", ylim = c(0,20),
        ylab = "incidência (por 100.000)",cex.axis = 0.8)
dev.off()

#incidencia limiar epidemico
png("mem_inc_epidemico_2010_2021.png", width = 700)
par(mfrow = c(2,1), mar = c(3,4,3,1))
boxplot(inc_epidemico ~ uf, data = thres.mun, xlab = "", ylim = c(0,300),
        main = "Limiar epidêmico de dengue",
        ylab = "incidência (por 100.000)", col = c(rep("green", 7), rep("cyan", 9), rep("orange", 4),
                                                   rep("darkblue", 4), rep("violet", 3)),cex.axis = 0.8)

boxplot(inc_epidemico ~ pop_cat, data = thres.mun, 
        main = "Limiar epidemico de dengue", xlab = "populaçao", ylim = c(0,300),
        ylab = "incidência (por 100.000)",cex.axis = 0.8)
dev.off()

write.csv(data, file = "parameters/mem_mun_2010_2021_BR.csv")

## Por regional ----
# 1. Agora é a versao que calcula limiares por regional. precisa fazer um loop pelos estados, 
# esse codigo pode ser bem melhorado.

# Norte ----
cidadesAC <- getCidades(uf = "Acre")
cidadesRO <- getCidades(uf = "Rondônia")
cidadesRR <- getCidades(uf = "Roraima")
cidadesAM <- getCidades(uf = "Amazonas")
cidadesPA <- getCidades(uf = "Pará")
cidadesAP <- getCidades(uf = "Amapá")
cidadesTO <- getCidades(uf = "Tocantins")

# Acre
(regs <- unique(cidadesAC$regional))
resAC <- c()
cids <- cidadesAC
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AC" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resAC <- rbind(resAC, xx)
}

head(resAC)

# Amazonas
(regs <- unique(cidadesAM$regional))
resAM <- c()
cids <- cidadesAM
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AM" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resAM <- rbind(resAM, xx)
}

# RO
(regs <- unique(cidadesRO$regional))
resRO <- c()
cids <- cidadesRO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RO" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resRO <- rbind(resRO, xx)
}

# RR
(regs <- unique(cidadesRR$regional))
resRR <- c()
cids <- cidadesRR
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RR" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resRR <- rbind(resRR, xx)
}

# AP
(regs <- unique(cidadesAP$regional))
resAP <- c()
cids <- cidadesAP
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "AP" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resAP <- rbind(resAP, xx)
}

# PA
(regs <- unique(cidadesPA$regional))
resPA <- c()
cids <- cidadesPA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "PA" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resPA <- rbind(resPA, xx)
}

# TO
(regs <- unique(cidadesTO$regional))
resTO <- c()
cids <- cidadesTO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "TO" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resTO <- rbind(resTO, xx)
}


resN <- rbind(resAC, resAM, resAP, resRR, resRO, resPA, resTO)
save(resN, file = "memN2021.RData")
load("memN2021.RData")

### Centro oeste ----

cidadesMT <- getCidades(uf = "Mato Grosso")
cidadesMS <- getCidades(uf = "Mato Grosso do Sul")
cidadesGO <- getCidades(uf = "Goiás")
cidadesDF <- getCidades(uf = "Distrito Federal")


# MT
(regs <- unique(cidadesMT$regional))
resMT <- c()
cids <- cidadesMT
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "MT" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resMT <- rbind(resMT, xx)
}

# MS
(regs <- unique(cidadesMS$regional))
resMS <- c()
cids <- cidadesMS
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "MS" 
  resMS <- rbind(resMS, xx)
}

# GO
(regs <- unique(cidadesGO$regional))
resGO <- c()
cids <- cidadesGO
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "GO" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resGO <- rbind(resGO, xx)
}

# DF
(regs <- unique(cidadesDF$regional))
resDF <- c()
cids <- cidadesDF
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "DF" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resDF <- rbind(resDF, xx)
}

resCO <- rbind(resMT, resMS, resDF, resGO)
save(resCO, file = "memCO.RData")
load("memCO.RData")

resCO2 <- rbind(as.data.frame(resCO[1:19]),
                as.data.frame(resCO[20:38]),
                as.data.frame(resCO[39:57]), 
                as.data.frame(resCO[58:76]))

### Sul ----

# cidades 
cidadesRS <- getCidades(uf = "Rio Grande do Sul")
cidadesPR <- getCidades(uf = "Paraná")
cidadesSC <- getCidades(uf = "Santa Catarina")

# RS
(regs <- unique(cidadesRS$regional))
resRS <- c()
cids <- cidadesRS
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "RS" 
  resRS <- rbind(resRS, xx)
}

# PR
(regs <- unique(cidadesPR$regional))
resPR <- c()
cids <- cidadesPR
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "PR" 
  resPR <- rbind(resPR, xx)
}

# SC
(regs <- unique(cidadesSC$regional))
resSC <- c()
cids <- cidadesSC
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "SC" 
  resSC <- rbind(resSC, xx)
}



resS <- rbind(resRS, resSC, resPR)
save(resS, file = "memS.RData")
load("memS.RData")


#dbDisconnect(con)

# Sudeste ----
# cidades 
cidadesRJ <- getCidades(uf = "Rio de Janeiro")
cidadesMG <- getCidades(uf = "Minas Gerais")
cidadesES <- getCidades(uf = "Espírito Santo")
cidadesSP <- getCidades(uf = "São Paulo")

#RJ
(regs <- unique(cidadesRJ$regional))
resRJ <- c()
cids <- cidadesRJ
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$uf <- "RJ" 
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  resRJ <- rbind(resRJ, xx)
}

#ES
(regs <- unique(cidadesES$regional))
resES <- c()
cids <- cidadesES
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "ES" 
  resES <- rbind(resES, xx)
}

#SP
(regs <- unique(cidadesSP$regional))
resSP <- c()
cids <- cidadesSP
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "SP" 
  resSP <- rbind(resSP, xx)
}

#MG
(regs <- unique(cidadesMG$regional))
resMG <- c()
cids <- cidadesMG
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "MG" 
  resMG <- rbind(resMG, xx)
}

resSE <- rbind(resRJ, resSP, resES, resMG)
save(resSE, file = "memSE.RData")
load("memSE.RData")

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
(regs <- unique(cidadesAL$regional))
resAL <- c()
cids <- cidadesAL
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "AL" 
  resAL <- rbind(resAL, xx)
}


#BA
(regs <- unique(cidadesBA$regional))
resBA <- c()
cids <- cidadesBA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "BA" 
  resBA <- rbind(resBA, xx)
}

dbDisconnect(con)
#CE
(regs <- unique(cidadesCE$regional))
resCE <- c()
cids <- cidadesCE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "CE" 
  resCE <- rbind(resCE, xx)
}

#MA
(regs <- unique(cidadesMA$regional))
resMA <- c()
cids <- cidadesMA
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "MA" 
  resMA <- rbind(resMA, xx)
}


# PB
(regs <- unique(cidadesPB$regional))
resPB <- c()
cids <- cidadesPB
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "PB" 
  resPB <- rbind(resPB, xx)
}

# PE
(regs <- unique(cidadesPE$regional))
resPE <- c()
cids <- cidadesPE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "PE" 
  resPE <- rbind(resPE, xx)
}

# PI
(regs <- unique(cidadesPI$regional))
resPI <- c()
cids <- cidadesPI
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "PI" 
  resPI <- rbind(resPI, xx)
}

# RN
(regs <- unique(cidadesRN$regional))
resRN <- c()
cids <- cidadesRN
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "RN" 
  resRN <- rbind(resRN, xx)
}

# SE
(regs <- unique(cidadesSE$regional))
resSE <- c()
cids <- cidadesSE
for (i in regs) {
  muns <- cids$municipio_geocodigo[cids$regional == i]
  xx <- infodengue_apply_mem_agreg(muns,nome = i)
  xx$regional_id <- cids$regional_id[cids$regional == i][1]
  xx$uf <- "SE" 
  resSE <- rbind(resSE, xx)
}


resNE <- rbind(resAL, resBA, resCE, resMA, resPB, resPE, resPI, resRN, resSE)
save(resNE, file = "memNE.RData")
#load("memNE.RData")
dbDisconnect(con)


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
resNE$regiao <- "Nordeste" 
resCO$regiao <- "Centro-Oeste"
resSE$regiao <- "Sudeste"
resS$regiao <- "Sul"

mem <- rbind(resN, resNE, resCO, resSE, resS)

write.csv(mem, file = "mem_regional_2010_2020_BR.csv")


# criar uma coluna UF no csv

load("data/cidades.rda") # no AlertTools
## Por UF ----

# dengue
ufs <- unique(cidades$uf)
res <- infodengue_apply_mem_agreg(muns,nome = ufs[3])
for(i in c(4:27,1:2)){
  print(i)
  muns <- cidades$municipio_geocodigo[cidades$uf == ufs[i]]
  res <- rbind(res,infodengue_apply_mem_agreg(muns,nome = ufs[i]))
}
 
# chik
ufs <- unique(cidades$uf)
resC <- list()
resC[[1]] <- infodengue_apply_mem_agreg(muns,nome = ufs[1], cid10 = "A92.0")
for(i in 2:27){
  print(i)
  muns <- cidades$municipio_geocodigo[cidades$uf == ufs[i]]
  resC[[i]] <- infodengue_apply_mem_agreg(muns,nome = ufs[i], cid10 = "A92.0")
}
save(resC, file = "memC_uf.RData")



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

