## Summary-mem por UF, macro ou regional 
## Esse codigo compara a incidencia predita atual com
## o limiar do mem para definir se UF, macrorregiao ou regional estão em nivel muito alto

## INPUT fixo (atualizado anualmente)
## MEM
load("parameters/mem/mem2023.RData") # no AlertaDengueAnalise
## cidades (list de UFs, dataframe de municipios, dataframe de estados)
load("parameters/dados/cidades.RData")

## INPUT atualizado semanalmente
### incidencia atual dengue (permitir que o usuario defina a data de inicio)

comando <- "SELECT municipio_geocodigo, \"SE\", casos, casprov, casos_est, pop, nivel 
FROM \"Municipio\".\"Historico_alerta\" WHERE \"SE\" > 202401"

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
# Quantas unidades espaciais estao acima do limiar epidemico?

# UF
tabelaUF <- memUFanual %>%
  left_join(UFs, join_by("nome" == "estado")) %>%
  select(sigla, codigo, nome, veryhigh) %>% 
  mutate(codigo = as.numeric(sigla)) %>%
  select(estado = nome, codigo, limiar = veryhigh) 

dd.uf.se <- dd.uf %>% 
  filter(SE == 202407) %>%
  select(UF, incest) 
  
tabelaUF <- tabelaUF %>%
  left_join(dd.uf.se, join_by("codigo" == "UF"))

tabelaUF$nivelNowcast <- as.numeric( tabelaUF$incest > (1.5 * tabelaUF$limiar))  # margem de 50%
sum(tabelaUF$nivel)

# tabelaUF é um dos outputs

# Regional

tabelaReg <- memReganual %>%
  select(uf, regional, regional_id = nome, veryhigh) 

dd.Reg.se <- dd.Reg %>% 
  filter(SE == 202407) %>%
  select(regional_id, UF, pop, incest)

tabelaReg <- tabelaReg %>%
  left_join(dd.Reg.se, join_by("regional_id" == "regional_id"))

tabelaReg$nivel <- as.numeric( tabelaReg$incest > (1.5 * tabelaReg$veryhigh))  # margem de 50%
sum(tabelaReg$nivel)/length(tabelaReg$nivel)  #  regionais estão acima do limiar
sum(tabelaReg$nivel * tabelaReg$pop)/sum(tabelaReg$pop)  # 7 pop em regionais com nivel de alerta

tabelaReg$poprisco <- tabelaReg$nivel * tabelaReg$pop

# tabelaReg é outro output

# abaixo algumas estatisticas e graficos
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
  theme_minimal()  # Adicione um tema, se desejar


