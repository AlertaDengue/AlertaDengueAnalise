# ========================================================
# Configuracao para o boletim do Estado do Rio de Janeiro
# ========================================================

# ------------
## Parte fixa
# ------------

estado = "Rio de Janeiro"
sigla = "RJ"
nmunicipios = 92
regs = c("Metropolitana I", "Metropolitana II", "Médio Paraíba", "Centro Sul", "Serrana",
         "Baixada Litorânea", "Norte", "Nordeste") 
nickregs = c("MetI", "MetII", "MedPar", "CSul", "Serra","BaixLit", "Norte", "Nord")

municip = c("Rio de Janeiro","Magé","São Gonçalo","São João de Meriti","Nova Iguaçu")
nickmunicip = c("Rio","Mag","SGoncalo","SJMeriti","Niguacu")
# -----------
## Parte que muda (depois ajeitar)
# -----------
se = 13
ano = 2016

totano = 5420
totultse = 350

nverde = 10
namarelo = 20
nlaranja = 30
nvermelho = 1

namarelo1 = 10
nlaranja1 = 30
nvermelho1 = 10

ta = rbind(c(1,2,4),c(3,4,5),c(3,4,5))

save(estado, se, ano, nmunicipios, regs,nickregs, totano, totultse, 
     nverde, namarelo, nlaranja, nvermelho, file="pp.RData")
