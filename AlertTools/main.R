# Arquivo de configuracao por municipio
#----------------------------------------

###########################
## Cidade do Rio de Janeiro
###########################
# Dados
#-------
cidade = 330455
nome = "Rio de Janeiro"
estacoeswu = c("SBRJ","SBJR","SBAF","SBGL")
withdivision = TRUE
nlocalidades = 10

localidades = c("AP1","AP2.1","AP2.2","AP3.1","AP3.2","AP3.3","AP4","AP5.1","AP5.2","AP5.3")
bairro2localidade = "data/locs.rda"
estacoeswuloc = c(rep("SBRJ",3), rep("SBGL",3), "SBJR", rep("SBAF", 3))
pop = c(226963, 552691, 371120, 735788, 489716, 924364, 838857, 655874, 665198, 368534)


# Parametros dos Modelos
#----------------------- 
# prop de notificacoes digitadas por semana de atraso
pdig = plnorm((1:20)*7, 2.5016, 1.1013)
# distribuicao do tempo de geracao 
gtdist="normal"
meangt=3
sdgt = 1

# criterios para alerta amarelo (condicao, duracao da condicao para turnon, turnoff)
crity <- c("temp_min > 22", 3, 3)
# criterios para alerta laranja (condicao, duracao da condicao para turnon, turnoff)
crito <- c("p1 > 0.9", 3, 0)
# criterios para alerta vermelho (condicao por 100.000, duracao da condicao para turnon, turnoff)
critr <- c("inc > 100", 3, 0)

# Run pipeline
#-------------
dC0 = getCases(city = cidade, withdivision = withdivision)
dT = getTweet(city = cidade, lastday = Sys.Date())
dW = getWU(stations = c('SBRJ','SBJR','SBAF','SBGL'))


for (i in 1:nlocalidades){
      dC1 <- casesinlocality(dC0, locality = localidades[i])      
      dC2 <- adjustIncidence(dC1, pdig = pdig)
      dC3 <- Rt(dC2, count = "tcasesmed", gtdist=gtdist, meangt=meangt, sdgt = sdgt)
      d <- mergedata(dC3, dT, dW[dW$estacao== estacoeswuloc[i],])
      
      alerta <- fouralert(d, cy = crity, co = crito, cr = critr, pop=pop[i])
      
      if(i==1) res <- table.alerta(cidade, localidades[1], alerta)
       else res <- rbind(res, table.alerta(cidade, localidades[i], alerta))
}


