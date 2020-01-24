# =============================================================================
# Arquivo de execução do Alerta Dengue: Estado do Paraná
# =============================================================================
# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Paraná"
sig = "PR"
shape="AlertaDengueAnalise/report/PR/shape/41MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/PR"
dir_rel = "Relatorio/PR/Estado"


# data do relatorio -----------------
#data_relatorio = 202002
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino
 
# cidades --------------------------
cidades <- getCidades(uf = estado)[,"municipio_geocodigo"]

# checking the last date
AlertTools::lastDBdate("sinan", city = 4108304, datasource = con) # Foz
Sys.time()
# Calcula alerta estadual ------------------ 
ale.den <- pipe_infodengue(cidades, cid10 = "A90", nowcasting = "none", 
                           finalday = dia_relatorio); save(ale.den, file="aleden.RData")

Sys.time()
## boletim dengue estadual
if(write_report) {
  flog.info("writing boletim estadual...", name = alog)
  bol <- configRelatorioEstadual(uf=estado, sigla = sig, data=data_relatorio, tsdur=300,
                                 alert=ale.den, shape=shape, varid=shapeID,
                                 dir=out, datasource=con, geraPDF=TRUE)
  
  publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
  write_alerta(tabela_historico(ale.chik))
  write_alerta(tabela_historico(ale.zika))
}

# salvando objetos -------------------------
Rfile = paste0("alertasRData/alePR",data_relatorio,".RData")
flog.info("saving ...", Rfile, capture = TRUE, name = alog)
save(ale.den, ale.chik, ale.zika, ale.F.den, ale.F.chik, ale.F.zika, file = Rfile)

# ----- Fechando o banco de dados
dbDisconnect(con)

