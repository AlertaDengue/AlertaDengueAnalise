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
#data_relatorio = 202024
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino
AlertTools::lastDBdate("sinan", cities = 3304557, datasource = con)
AlertTools::lastDBdate("clima_wu", cities = 3304557, datasource = con)

# cidades -------------------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]
print(Sys.time())

# Calcula alerta ---------------------------- 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "fixedprob", 
                                     finalday = dia_relatorio); save(ale.den, file="aleden.RData",userinput = T)

ale.chik <- pipe_infodengue(cidades, cid10 = "A92.0", nowcasting = "fixedprob", 
                            finalday = dia_relatorio); save(ale.chik, file="alechik.RData",userinput = T)

print(Sys.time())
# Boletim: 
if(write_report) { # so dengue
  flog.info("writing boletim estadual...", name = alog)
  new_data_relatorio <- max(ale.den[[1]]$data$SE)
  print(paste("Data real do relatorio:", new_data_relatorio))
  
  bol=configRelatorioEstadual(uf=estado, sigla=sig, data=new_data_relatorio, 
                                tsdur=104,alert=ale.den, shape=shape, varid=shapeID,
                              dir=out, datasource=con, geraPDF=TRUE)

  publicarAlerta(ale.den, pdf = bol, dir = dir_rel)
  write_alerta(tabela_historico(ale.chik))

}
print(Sys.time())
# ----- Fechando o banco de dados
dbDisconnect(con)




