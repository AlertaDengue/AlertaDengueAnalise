############################
Descricao dos arquivos 
############################

#---------------------------------------
## macro_e_regionais-BR-Infodengue-2021 
#---------------------------------------

tabela de regionais e macroregionais implementadas do Infodengue em 2021
fonte: Tabelas que Raquel compilou. 

autor : Raquel
data: abril 2021

#----------------------------
## mem_regional_2010_2020_BR
#----------------------------

tabela com limiares epidemicos calculados para cada regional de saude, conforme definido pela tabela
macro_e_regionais-BR-Infodengue-2021 

autor: Claudia
data: maio 2021

> head(mem,n = 2)
                nome       pre       pos veryhigh inicio inicio.ic duracao duracao.ic quant_pre quant_pos
1 Baixo Acre e Purus 10.871843 10.244994 63.05744      2    [45-8]      12     [1-16]  2.445979  2.445979
2          Alto Acre  9.522167  7.405256 55.51824      2    [45-7]      12     [4-16]  6.893889  6.893889
  quant_epidemico mininc_pre mininc_pos mininc_epi ano_inicio ano_fim populacao uf regional_id regiao
1        77.03978  0.8552374  0.8552374   1.710475       2010    2020    584633 AC       12002  Norte
2       110.30223  6.8938893  6.8938893  13.787779       2010    2020     72528 AC       12001  Norte

nome = nome regional saude
regional_id = codigo regional de saude
pre = nivel pre-epidemico
pos = nivel pos-epidemico
veryhigh = nivel epidemico
inicio = inicio temporada dengue
duracao = duracao tipica temporada de dengue
quant_pre = quant_pos = percentil 10 da incidencia de dengue
quant_epidemico = percentil 95 da incidencia de dengue
mininc_pre = 5/populacao *100000
mininc_epi = 10/populacal*100000
 

