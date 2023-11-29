#####coleta e organiza dado para atualizacao limiares meteorologicos########
#author: "Claudia Codeço"
#2022

### BIBLIOTECAS NECESSÁRIAS


library(AlertTools)
library(lubridate)
library(RPostgreSQL)
library(forecast)
library(MASS)
library(tidyverse)
library(assertthat)
library(imputeTS)
library(quantmod)

# parte 1: capturar os dados de casos e clima
# conexão:
# ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC
con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

out <- "dadosclima2022_"
ufs <-  c("Roraima","Amapá","Acre",
                  "Amazonas","Pará","Rondônia","Tocantins",
                  "Maranhão","Piauí","Ceará","Rio Grande do Norte",
                  "Paraíba","Pernambuco","Alagoas","Sergipe","Bahia",
                  "Goiás", "Distrito Federal","Mato Grosso" , "Mato Grosso do Sul",
                  "Minas Gerais", "Espírito Santo","Rio de Janeiro",
                  "São Paulo","Paraná", "Santa Catarina", "Rio Grande do Sul")
sigla <- c("RR","AP","AC","AM","PA","RO","TO","MA","PI","CE","RN",
                     "PB","PE","AL","SE","BA","GO","DF","MT","MS","MG","ES","RJ",
                     "SP","PR","SC","RS")


#Parana é i = 25
i = 10
ufs[i]

captura_casos_clima <- function(estado, sig){
  print(sig)
  # cidades --------------------------------
  cidades <- getCidades(uf = estado)
  casosDengue <- getCases(cidades$municipio_geocodigo, dataini = "sinpri", cid10 = "A90")
  casosChik <- getCases(cidades$municipio_geocodigo, dataini = "sinpri", cid10 = "A92.0")
  #casosZika <- getCases(cidades$municipio_geocodigo, dataini = "sinpri", cid10 = "A92.8")

  nome <- paste0(out ,sig,".RData")

  #estações meteorologicas
  wu <- getWUstation(cidades$municipio_geocodigo)
  wus <- unique(c(wu$codigo_estacao_wu, wu$estacao_wu_sec))
  wus <- na.omit(wus)
  clima <- getWU(wus, vars = c("temp_min","temp_max","temp_med","umid_max","umid_med","umid_min"))
  message(paste(nome, "saved"))
  save(casosDengue, casosChik, clima, wu, file = nome) 
  
} 

for(i in 1:27) captura_casos_clima(estado = ufs[i], sig = sigla[i])
dbDisconnect(con)

# parte 2 ----

#JUNTANDO OS DADOS de casos e clima e salva no mesmo arquivo da parte 1
# salvos numa pasta separada
arqs <- dir("parameters/dados")
(arq <- arqs[6]) # 

juntadados <- function(arq){
  load(paste0("parameters/dados/",arq))
  message(paste("juntando dados de", arq))
  
  casosD <- casosDengue[, c("SE", "cidade", "casos", "nome", "pop")] %>%
  left_join(wu, by = c("cidade" = "municipio_geocodigo")) %>% 
  left_join(clima, by = c("SE"="SE", "estacao_wu_sec" = "estacao")) %>%
  mutate(ano = floor(SE/100),
         sem = SE-ano*100) 
  
  summary(casosD)
  
  casosD$umid_max[casosD$umid_max > 100] = 100
  casosD$umid_min[casosD$umid_min > 100] = 100
  casosD$temp_med[casosD$temp_min > 40] = 40
  casosD$temp_min[casosD$temp_max > 40] = 40
  
  casosD$temp_max <- ts(casosD$temp_max, frequency = 52, start = c(2010, 1))
  casosD$temp_min <- ts(casosD$temp_min, frequency = 52, start = c(2010, 1))
  casosD$umid_max <- ts(casosD$umid_max, frequency = 52, start = c(2010, 1))
  casosD$umid_min <- ts(casosD$umid_min, frequency = 52, start = c(2010, 1))
  
  plot(casosD$temp_max[casosD$cidade == 4108304], type = "l")
  
    casosD <- casosD %>%  # interpolation group
    mutate(temp_max = na_seadec(temp_max),
           temp_min = na_seadec(temp_min),
           umid_max = na_seadec(umid_max),
           umid_min = na_seadec(umid_min)) %>%
  rename(dengue = casos)
  
  plot(casosD$temp_max[casosD$cidade == 4108304], type = "l")
  
  casosC <- casosChik %>%
    mutate(ano = floor(SE/100),
          sem = SE - ano*100) %>%
    rename(chik = casos) 
  
  casos <- casosD %>%
  left_join(casosC[, c("SE","cidade","chik")]) 
  casos$casos <- casos$dengue + casos$chik #+ casos$zika
  save(casos, casosChik, casosDengue, wu, clima, file = paste0("parameters/dados/",arq))
  casos
}

for(i in 1:27) x <- juntadados(arqs[i])

# parte 3: calcular Rt por cidade para chik, dengue e ambos e imputar var climaticas ----
# d é a tabela de dados de um estado
# ref generation time chik https://bmcmedicine.biomedcentral.com/articles/10.1186/s12916-020-01674-y

arqs <- dir("parameters/dados")
calcRt <- function(arq){
  load(paste0("parameters/dados/",arq))
  message(paste("calculando Rt de", arq))
  municipios <- unique(casos$cidade)
  res <- data.frame() 
  for (x in municipios){
    cas.x <- casos %>% 
      filter(cidade == x) %>%
      Rt(count = "dengue", gtdist="normal", meangt=3, sdgt = 1) %>%
      rename(Rt.de = Rt, lwr.de = lwr, upr.de = upr, p1.de = p1) %>%
      mutate(inc.de = dengue/pop*100000)  %>%
      Rt(count = "chik", gtdist="normal", meangt=2.5, sdgt = 1) %>%
      rename(Rt.ch = Rt, lwr.ch = lwr, upr.ch = upr, p1.ch = p1) %>%
      mutate(inc.ch = chik/pop*100000)  %>%
      Rt(count = "casos", gtdist="normal", meangt=3, sdgt = 1) %>%
      mutate(inc = casos/pop*100000)  %>%
      arrange(SE) 
    
    res <- rbind(res, cas.x)
  }
  
  res$Rt1.de <- factor(res$lwr.de > 1 ,labels = c("Rt<=1", "Rt>1"))
  res$Rt1.ch <- factor(res$lwr.ch > 1 ,labels = c("Rt<=1", "Rt>1"))
  res$Rt1 <- factor(res$lwr > 1 ,labels = c("Rt<=1", "Rt>1"))
  
  par(mfrow = c(3,1), mar = c(2,4,0,1))
  plot(res$temp_max[res$cidade == 4108304], type = "l", ylab = "temp")
  plot(res$dengue[res$cidade == 4108304], type = "l", ylab = "casos")
  plot(res$lwr[res$cidade == 4108304], type = "l", ylim = c(0,3), ylab = "Rt")
  abline(h = 1, col =2)
  
   (res$Rt)
  save(casos, casosChik, casosDengue, wu, clima, res, file = paste0("parameters/dados/",arq))
  res
} 

for(i in 1:27) dadosRt <- calcRt(arqs[i])

# Parte 4 : incluir info regional ----

regionais <- read.csv("parameters/regionais-infodengue.csv")

for(i in 1:27){
  arq <- arqs[i]
  load(paste0("parameters/dados/",arq))
  res <- res %>%
    left_join(regionais, by = c("cidade" = "municipio_geocodigo"))
  save(casos, casosChik, casosDengue, wu, clima, res, 
       file = paste0("parameters/dados/",arq))
  rm(res, casos)
}

# Parte 5 : Split dates for training and test sets, within the studied period ----
#set.seed(123)
#load(paste0("parameters/dados/",arqs[1]))
#rm(casosChik, casos, casosDengue, clima, wu)

#dates <- unique(res$SE)[10:658]  # to remove the first weeks with NA

#train.dates <- sample(dates, size = 0.75*length(dates))
#test.dates <- dates[!(dates %in% train.dates)]
 #rm(res)


# Parte 6 : find best tree model for each regional ----
library(partykit)
library(Hmisc)
load(paste0("parameters/dados/",arqs[i]))

fit.trees <- function(arq){
  load(paste0("parameters/dados/",arq))  # dados do estado

  # analise por regional
  regs <- unique(res$regional_nome)
  print(regs)
  trees <- list()
  #r = 22
  for(r in 1:length(regs)){
    tr <- list() # guardar resultado da regional
    print(regs[r])
    res1 <- res %>%
      filter(regional_nome == regs[r]) %>%
      group_by(cidade) %>%
      mutate(temp_min = round(temp_min,1),
             temp_max = round(temp_max,1),
             umid_min = round(umid_min,1),
             umid_max = round(umid_max,1),
             inc = round(inc, 1),
             temp_min_1 = Lag(temp_min, 1),
             temp_max_1 = Lag(temp_max, 1),
             umid_min_1 = Lag(umid_min, 1),
             umid_max_1 = Lag(umid_max, 1),
             temp_min_2 = Lag(temp_min, 2),
             temp_max_2 = Lag(temp_max, 2),
             umid_min_2 = Lag(umid_min, 2),
             umid_max_2 = Lag(umid_max, 2),
             temp_min_3 = Lag(temp_min, 3),
             temp_max_3 = Lag(temp_max, 3),
             umid_min_3 = Lag(umid_min, 3),
             umid_max_3 = Lag(umid_max, 3),
             inc_3 = Lag(inc, 3))
    # prop Rt1
    tr$perc_Rt1_preremoval <- sum(res1$Rt1 == "Rt>1", na.rm=TRUE)/sum(!is.na(res1$Rt1))*100
    
    # removing missings:
    n <- nrow(res1)
    res1 <- res1 %>%
      filter(!is.na(Rt1)) %>%
      filter(!is.na(temp_min)) %>%
      filter(!is.na(temp_max)) %>%
      filter(!is.na(umid_min)) %>%
      filter(!is.na(umid_max)) 
    m <- n - nrow(res1)
    tr$perc_missing <- m/n*100
    # prop Rt1
    tr$perc_Rt1_posremoval <- sum(res1$Rt1 == "Rt>1", na.rm=TRUE)/sum(!is.na(res1$Rt1))*100
    
    tr$tree.c <- NA
    if(tr$perc_missing < 50 & tr$perc_Rt1_posremoval > 0.5){  #0.5%
      tr$tree.c <- ctree(
        Rt1 ~ temp_min_1 + temp_min_2 + temp_min_3 + 
          temp_max_1 + temp_max_2 + temp_max_3 +
          umid_min_1 + umid_min_2 + umid_min_3 +
          umid_max_1 + umid_max_2 + umid_max_3 +
          inc_3, 
        control = ctree_control(maxdepth = 3),
        data = res1)
    } 
    
    plot(tr$tree.c)
    
    - para cada ramo, calculo chance Rt1 
    - será considerada receptiva, toda decisao cuja chance > 3
    
    #res1$receptivo <- ifelse(res1$temp_max_2 > 27.167 | (res1$temp_max_1 <= 27.167 & res1$temp_max_2 > 31.14), "receptivo","nao receptivo") 
    #table(res1$receptivo, res1$Rt1)
    
    #tr$tree.glm <- glmtree(Rt1 ~ temp_min_1 + temp_max_1 + umid_min_1 + umid_max_1 +
    #                         temp_min_2 + temp_max_2 + umid_min_2 + umid_max_2 +
    #                         temp_min_3 + temp_max_3 + umid_min_3 + umid_max_3,
    #                       data = res1, family = binomial)
    
    #res1$receptivom <- ifelse(res1$temp_max_2 > 27.167 | (res1$temp_max_1 <= 27.167 & res1$temp_max_2 > 31.14), "receptivo","nao receptivo") 
    trees[[regs[r]]] <- tr
  }
  #names(trees) <- regs
  save(casos, casosChik, casosDengue, wu, clima, res, trees, file = paste0("parameters/dados/",arq))
  trees
}




for(i in 1:27) {
  print(i)
  out <- fit.trees(arqs[i])
}

## Parte 7: extracao regras de decisao ----
arqs <- dir("parameters/dados")
source("parameters/ctree_aux_fun.R")

summary.trees <- function(arq){
  load(paste0("parameters/dados/",arq))  # dados do estado
  uf <- res$uf[1]
  print(uf)
  # analise por regional
  regs <- unique(res$regional_nome)
  print(regs)
  
  # para guardar os resultados
  summ.regras <- data.frame(matrix(ncol=10,nrow=0, 
                                  dimnames=list(NULL, c("uf","regional", "regional_geocode", "nid", 
                                                        "probRt1","n",
                                                        "terminal","regra", "nRt1","odds"))))
 
   
  for(r in 1:length(regs)){
    reg_geocode <- res$regional_geocodigo[res$regional_nome == regs[22]][1]
    if(any(class(trees[[r]]$tree.c) == "party")){ # if not, = NA se nao tiver dado suficiente, ver fun acima
      ct <- trees[[r]]$tree.c
      nid <- nodeids(ct) # all nodes
        probs <- do.call("rbind", nodeapply(ct, nodeids(ct), probs_and_n, 
                                            by_node = FALSE)) # extrai a prob de Rt1 de cada no terminal
        pred <- as.data.frame(probs[nid, ])  # predito para cada no (interno ou terminal)
        if(length(nid) > 1){
        receptividade <- data.frame(nid, probRt1 = pred[,2], n = pred[,3])
        rules <- partykit:::.list.rules.party(ct)
        terminais <- as.numeric(names(rules))
        receptividade$terminal <- 0
        receptividade$terminal[terminais] <- 1
        receptividade$regra <- NA
        receptividade$regra[receptividade$terminal == 1] <- rules
        receptividade <- receptividade %>% 
          filter(!is.na(regra)) %>%
          arrange(desc(probRt1)) %>%
          mutate(uf = "PR",
                 regional = regs[r],
                 regional_geocode = reg_geocode,
                 nRt1 = probRt1 * n)
        receptividade$odds = tree.odds(receptividade$n, receptividade$nRt1, acum = FALSE)
        
         summ.regras <- rbind(summ.regras, receptividade)  
      } else { # se nao gera regra (1 node)
        d <- data.frame(uf = uf, regional = regs[r], regional_geocode = reg_geocode, nid = 1, probRt1 = pred[2,1] , 
                        n = pred[3,1], terminal = 1, regra = "", nRt1 = pred[2,1] * pred[3,1])
        d$odds = tree.odds(d$n, d$nRt1, acum = FALSE)
        summ.regras <- rbind(summ.regras, d)
      } } else { # se nao tem dados ou pouca transmissao
      d <- data.frame(uf = uf, regional = regs[r], regional_geocode = reg_geocode, nid = 0, probRt1 = NA , 
                      n = length(res), terminal = NA, regra = "no fit", nRt1 = NA)
      d$nRt1 <- sum(res$Rt1 == "Rt>1")
      d$probRt1 <- d$nRt1/d$n  
      d$odds <- NA
      summ.regras <- rbind(summ.regras, d)
    }
   
    
  }
   save(casos, casosChik, casosDengue, wu, clima, res, trees, summ.regras, 
        file = paste0("parameters/dados/",arq))
  summ.regras
  }

summary.trees()
out <- summary.trees(arqs[1])
for(i in 2:27) {
  print(i)
  ou <- summary.trees(arqs[i])
  out <- rbind(out, ou)
}

## gerando um arquivo unico  
write.csv(out, file = "all_rules_regionais_2022_prepruned.csv", row.names = FALSE)

#  checking rules and pruning ----
d <- read.csv("all_rules_regionais_2022_prepruned.csv") 

summary(d)
# nao ajustou, poucos dados
tapply(is.na(d$odds), d$uf, sum)
#ac al am ap ba ce df es go ma mg ms mt pa pb pe pi pr rj rn ro rr rs sc se sp to 
#0  1  2  0  4  0  0  0  2 16 22  0  1  6  6  0  9  8  0  1  0  0 27 14  3  2  5 

d1 <- d[d$nid == 1,] # regra sem variavel  
#nid     probRt1    n terminal regra uf       regional regional_geocode nRt1 odds
#422    1 0.006371050 3924        1       ma Barra do Corda            21004   25  Inf
#666    1 0.005351682 2616        1       mg  Padre Paraíso            31067   14  Inf
#1222   1 0.006880734 3924        1       rr            Sul            14002   27  Inf

dd <- d[d$nid > 1,]  # geraram regras
dr <- unique(dd$regional)
length(dr) # 310 regionais no arquivo 

# pruning
# manter os ramos com odds > 3 
drec <- dd[dd$odds >= 3,] 
table(drec$uf)

write.csv(drec, file = "rules_recept_regionais_2022_vertical.csv", row.names = FALSE)
drec <- read.csv("parameters/rules_recept_regionais_2022_vertical.csv")
names(drec)
head(drec)


rn <- drec$regra[1] %>%
  str_replace_all(c("inc_3" = "20", "temp_min_1" = "25", "temp_max_3" = "35"))
eval(parse(text=rn[1]))

str_replace_all(drec$regra[1], "inc_3", as.character(inc_3))



final_rules <- data.frame(regional = unique(drec$regional_geocode), regra = NA) 
for(i in  1:length(rules$regional)){
  linhas <- drec[drec$regional == rules$regional[i],] 
  nl <- nrow(linhas)
  regra <- "("
  for(j in 1:nl){
    regra <- paste0(regra, linhas$regra[j], ")")
    if (j < nl) regra <- paste0(regra, " | (")
  } 
  final_rules$regra[i] <- regra
}

inc_3 = 20
final_rules$regra[14]

write.csv(final_rules, file = "infodengue_receptive_rules_2022.csv", row.names = FALSE)

drec <- read.csv("parameters/infodengue_receptive_rules_2022.csv")
names(drec)
head(drec)

values <- c("inc_3" = "10", "temp_min_1" = "15", "temp_max_3" = "15",
            "umid_min_2" = "10","umid_min_1" = "10")

rr <- drec$regra[1]
rn <- drec$regra[1] %>%
  str_replace_all(c("inc_3" = "10", "temp_min_1" = "15", "temp_max_3" = "15",
                    "umid_min_2" = "10","umid_min_1" = "10","umid_min_2" = 20))
eval(parse(text=rn[1]))



for(i in 1:22) {
  nam = names(trees)[i]
  png(filename = paste0("tree-",nam,".png"))
  plot(trees[[i]]$tree.c)
  dev.off()
}