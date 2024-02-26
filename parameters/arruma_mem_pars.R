mem <- read.csv("parameters/mem_regional_2010_2020_BR.csv")
macro <- read.csv("parameters/macro_e_regionais-BR-Infodengue-2021.csv")

micro <- macro %>%
  group_by(regional_nome) %>%
  summarise(regional_codigo = unique(regional_codigo, na.rm = TRUE))

library("tidyverse")
mm <- mem %>%
  left_join(micro, by = c("nome" = "regional_nome"))

table(mm$nome)
head(mm)
save(mm, file = "Data/mem_regional_2010_2020_BRcominfoUF.RData")


## Mapa
load("Data/mem_regional_2010_2020_BRcominfoUF.RData")
names(mm)

library("sf")
library("tmap")
library("ggplot2")

shapefile <- st_read("Data/cobertura_regiaosaude.shp")
#st_geometry_type(shapefile)

# mapa vazio
ggplot() + 
  geom_sf(data = shapefile, size = 0.3, color = "black", fill = "cyan1") + 
  ggtitle("Regionais") + 
  coord_sf()

# juntando os dados
shape <- shapefile[,c(1,2,10)] %>%
  mutate(Primary.ID = as.numeric(Primary.ID)) %>%
  left_join(mm, by = c("Primary.ID" = "regional_codigo"))

# Casos de dengue
ggplot(data = shape) + 
  geom_sf(size = 0.01) +
  geom_sf(data = shape, aes(fill = veryhigh)) +
  scale_fill_viridis_c(trans = "sqrt", alpha = .4) + 
  ggtitle(paste("Very High")) + 
  coord_sf()


# mem
mem <- read.csv("mem/mem_regional_2010_2020_BR.csv")
names(mem)
mem %>% filter(regiao == "Nordeste") %>% select(regional_id,inicio, inicio.ic,populacao) %>% arrange(populacao)

