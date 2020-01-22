# =============================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado do Paraná
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
#out = "AlertaDengueAnalise/report/MG/Regionais/"
dir_rel = "Relatorio/PR/Regionais"

# data do relatorio:---------------------
#data_relatorio = 201851
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino


# Boletim da Regional de Saude de Cascavel ------------------------------------
reg <- "Cascavel"
geo <- getCidades(regional = reg, uf = "Paraná")$municipio_geocodigo

flog.info(paste("alerta dengue", reg ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob",
                           finalday = dia_relatorio)

# Boletim ----------------------------------
if(write_report) {
  # dir 
  nome <- reg
  nomesemespaco = gsub(" ","",nome)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  out = paste0("AlertaDengueAnalise/report/PR/Regionais/",nomesemacento) 
  flog.info(paste("writing boletim de ", nome), name = alog)
  
  bol <- configRelatorioRegional(tipo="simples",uf=estado, regional=reg,
                                 sigla = sig, data=data_relatorio, 
                                 alert=ale.den, shape=shape, varid=shapeID,
                                 dir=out, datasource=con, geraPDF=TRUE)
  
  publicarAlerta(ale = ale.den, pdf = bol, dir = out)
  save(ale.den, file = paste0("alertasRData/alePR-rg",data_relatorio,".RData"))
}


# ----- Fechando o banco de dados
dbDisconnect(con)

