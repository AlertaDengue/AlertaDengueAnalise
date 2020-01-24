# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Rio de Janeiro
# =============================================================================

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Rio de Janeiro"
sig = "RJ"
shape="AlertaDengueAnalise/report/RJ/shape/33MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/RJ"
dir_rel = "Relatorio/RJ/Estado"


# data do relatorio --------------------------
#data_relatorio = 202002
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidades -------------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# Calcula alerta ---------------------------- 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "fixedprob", 
                                     finalday = dia_relatorio)

#ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "fixedprob", 
#                            finalday = dia_relatorio)
save(ale.den, ale.chik, file="ale.RData")
# Boletim: 
if(write_report) { # so dengue
  bol=configRelatorioEstadual(uf=estado, sigla=sig, data=data_relatorio, 
                                tsdur=104,alert=ale.den, shape=shape, varid=shapeID,
                              dir=out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale.den, pdf = bol, dir = dir_rel)
  write_alerta(tabela_historico(ale.chik))
  #write_alerta(tabela_historico(ale.den))
  
}

# ----- Fechando o banco de dados
dbDisconnect(con)




