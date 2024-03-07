## Tabela resumo de situacao por UF, macro ou regional 
## 
library(tidyverse)

## MEM
load("parameters/mem/mem2023.RData") # no AlertaDengueAnalise
## cidades (list de UFs, dataframe de municipios, dataframe de estados)
load("parameters/dados/cidades.RData")

### incidencia atual dengue (permitir que o usuario defina a data de inicio)

comando <- "SELECT municipio_geocodigo, \"SE\", casos, casprov, casos_est, pop, nivel 
FROM \"Municipio\".\"Historico_alerta\" WHERE \"SE\" > 202400"

dd <- dbGetQuery(con, comando)  # conexao banco

# merge com muns  (está no arquivo cidades.RData)
names(muns)
names(dd)
dd <- dd %>%
  left_join(muns)

# agregar casos por SE e UF
dd.uf <- dd %>% 
  mutate(UF = floor(municipio_geocodigo/100000)) %>%
  group_by(UF, SE) %>%
  summarise(casos = sum(casos),
            casprov = sum(casprov),
            casos_est = sum(casos_est),
            pop = sum(pop)) %>%
  mutate(inc = casos / pop * 100000,
         incprov = casprov / pop * 100000,
         incest = casos_est/pop * 100000) %>%
  arrange(UF, SE)


# agregar casos por SE e Macro
dd.Macro <- dd %>% 
  mutate(UF = floor(municipio_geocodigo/100000)) %>%
  group_by(macroregional_id, SE) %>%
  summarise(casos = sum(casos),
            casprov = sum(casprov),
            casos_est = sum(casos_est),
            pop = sum(pop),
            UF = unique(UF)) %>%
  mutate(inc = casos / pop * 100000,
         incprov = casprov / pop * 100000,
         incest = casos_est/pop * 100000) %>%
  arrange(UF, SE)

# agregar casos por SE e Regional
dd.Reg <- dd %>% 
  mutate(UF = floor(municipio_geocodigo/100000)) %>%
  group_by(regional_id, SE) %>%
  summarise(casos = sum(casos),
            casprov = sum(casprov),
            casos_est = sum(casos_est),
            pop = sum(pop),
            macroregional_id = unique( macroregional_id),
            UF = unique(UF)) %>%
  mutate(inc = casos / pop * 100000,
         incprov = casprov / pop * 100000,
         incest = casos_est/pop * 100000) %>%
  arrange(UF, macroregional_id, SE)


##########
# Quantas ubnidades espaciais estao acima do limiar epidemico?

# UF
tabelaUF <- memUFanual %>%
  left_join(UFs, join_by("nome" == "estado")) %>%
  select(sigla, codigo, nome, veryhigh) %>% 
  mutate(codigo = as.numeric(sigla)) %>%
  select(estado = nome, codigo, limiar = veryhigh) 

(se <- max(dd.uf$SE))

dd.uf.se <- dd.uf %>% 
  filter(SE == se) %>%
  select(UF, incest, inc) 
  
tabelaUF <- tabelaUF %>%
  left_join(dd.uf.se, join_by("codigo" == "UF"))

tabelaUF$nivelNowcast <- as.numeric( tabelaUF$incest > (1.5 * tabelaUF$limiar))  # margem de 50%
sum(tabelaUF$nivel)


# Regional

tabelaReg <- memReganual %>%
  select(uf, regional, regional_id = nome, veryhigh) 

dd.Reg.se <- dd.Reg %>% 
  filter(SE == se) %>%
  select(regional_id, UF, pop, incest)

tabelaReg <- tabelaReg %>%
  left_join(dd.Reg.se, join_by("regional_id" == "regional_id"))

tabelaReg$nivel <- as.numeric( tabelaReg$incest > (1.5 * tabelaReg$veryhigh))  # margem de 50%
sum(tabelaReg$nivel)/length(tabelaReg$nivel)  #  regionais estão acima do limiar
sum(tabelaReg$nivel * tabelaReg$pop)/sum(tabelaReg$pop)  # 7 pop em regionais com nivel de alerta

tabelaReg$poprisco <- tabelaReg$nivel * tabelaReg$pop


tabpoprisco <- tapply(tabelaReg$poprisco, tabelaReg$uf, sum)/tapply(tabelaReg$pop, tabelaReg$uf, sum) * 100

tabpoprisco <- tabelaReg %>%
  group_by(uf) %>%
  summarise(poprisco = sum(poprisco),
            pop = sum(pop)) %>%
  mutate(popriscoprop = poprisco/pop * 100) %>%
  arrange(popriscoprop)

barplot(tabpoprisco$popriscoprop, names.arg = tabpoprisco$uf, las = 2, ylab = "%", 
        main = "pop em alto risco por estado", col = "orange")
abline(h = 50, col = 2, lty = 2)


####################

## mapa

library(sf)
library(ggplot2)

shape <- st_read("shape/rs_450_RepCor1.shp")# shape de regionais
shape$primary.id <- as.numeric(shape$primary.id)
shape <- shape %>%
  left_join(tabelaReg, join_by("primary.id" == "regional_id"))

ggplot() +
  geom_sf(data = shape, aes(fill = as.character(nivel))) +
  scale_fill_manual(values = c("grey", "orange")) +
  labs(fill = "Alto") +
  ggtitle("202408") +
  theme_minimal()  # Adicione um tema, se desejar

#######################

# Rt por UF
library(AlertTools)
obj <- dd.uf %>%
  group_by(UF) %>%
  arrange(SE) 

obj <- as.data.frame(obj)

# referente as ultimas 3 semanas
tabelaUF$Rtmean <- NA
tabelaUF$secomp1 <- NA
tabelaUF$weekmax <- NA

for(i in 1:27){
  tabelaUF$selimiaralto[i] <- ifelse(length(semanas) == 0, NA, min(semanas))
  semanas <- dd.ufi$SE[dd.ufi$incest > tabelaUF$limiar[i]]
  r <- Rt(obj[obj$UF == tabelaUF$codigo[i],], count = "casos_est", gtdist = "normal", meangt = 3, sdgt = 1)
  tabelaUF$Rtmean[i] <- mean(tail(r$Rt, n = 3))
  tabelaUF$secomp1[i] <- sum(tail(r$p1, n = 3) > 0.9)
  dd.ufi <- dd.uf %>% filter(UF == tabelaUF$codigo[i])
  tabelaUF$weekmax[i] <-  dd.uf$SE[which.max(dd.ufi$casos_est)]
}

tabelaUF
write.csv(tabelaUF, file = paste0("tabela-resumo", se, ".csv"))

# tabela - essa parte nao dá para automatizar ainda
ufmemtab <- read.csv("memUF2023-anual-edited.csv", header = T) 
ufmemtab$ini.season.atual <- NA
ufmemtab$epid.season.atual <- NA
ufmemtab$fim.season.atual <- NA
ufmemtab$duracao.temp <- NA
ufmemtab$nivel[i] <- NA

i = 24
ufmemtab[i,]
plot(dd.uf$SE[dd.uf$UF == ufmemtab$codigo[i]], 
     dd.uf$inc[dd.uf$UF == ufmemtab$codigo[i]], type = "h", main = "casos")
abline(h = ufmemtab$limiar.pre.season[i], col = "green")
abline(h = ufmemtab$limiar.pos.season[i], col = "blue")
abline(h = ufmemtab$limiar.epidemico[i], col = "red")

plot(dd.uf$SE[dd.uf$UF == ufmemtab$codigo[i] & dd.uf$SE >= 202350], 
     dd.uf$incest[dd.uf$UF == ufmemtab$codigo[i] & dd.uf$SE >= 202350], type = "h", 
     main = ufmemtab$UF[i])
abline(h = ufmemtab$limiar.pre.season[i], col = "green")
abline(h = ufmemtab$limiar.pos.season[i], col = "blue")
abline(h = ufmemtab$limiar.epidemico[i], col = "red")

# pre
dd.uf$SE[which(dd.uf$incest[dd.uf$UF == ufmemtab$codigo[i]] > ufmemtab$limiar.pre.season[i])]
#epid
dd.uf$SE[which(dd.uf$incest[dd.uf$UF == ufmemtab$codigo[i]] > ufmemtab$limiar.epidemico[i])]
# pos
dd.uf$SE[which(dd.uf$incest[dd.uf$UF == ufmemtab$codigo[i]] < ufmemtab$limiar.pos.season[i])]

ufmemtab$ini.season.atual[i] <- 01
ufmemtab$epid.season.atual[i] <- 03
ufmemtab$fim.season.atual[i] <- NA
ufmemtab$duracao.temp[i] <- NA
ufmemtab$nivel[i] <- "crescente"

ufmemtab[i,]

write.csv(ufmemtab, file = "memUF2023-anual-edited.csv", row.names = F)



