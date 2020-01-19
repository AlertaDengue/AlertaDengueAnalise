# ==================================================================================
# Arquivo de execução do Alerta Dengue: Regionais de Saude do Estado de Minas Gerais
# ==================================================================================
# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Minas Gerais"
sig = "MG"
shape="AlertaDengueAnalise/report/MG/shape/31MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
#out = "AlertaDengueAnalise/report/MG/Regionais/"
dir_rel = "Relatorio/MG/Regionais"

# logging -------------------------------- 
#habilitar se quiser
# alog = paste0("ale_",Sys.Date(),".log")
if (logging == TRUE){
  aalog <- paste0("AlertaDengueAnalise/",alog)
  print(aalog)
}

# data do relatorio:---------------------
#data_relatorio = 201851
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino



# Boletim da Regional de Saude de Sete Lagoas ----------------
reg <- "Sete Lagoas"
geo <- getCidades(regional = reg, uf = "Minas Gerais")$municipio_geocodigo

flog.info(paste("alerta dengue", reg ,"executing..."), name = aalog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)

# Boletim ----------------------------------
if(write_report) {
  # dir 
  nome <- reg
  nomesemespaco = gsub(" ","",nome)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  out = paste0("AlertaDengueAnalise/report/MG/Regionais/",nomesemacento) 
  flog.info(paste("writing boletim de ", nome), name = aalog)

  bol <- configRelatorioRegional(tipo="simples",uf="Minas Gerais", regional="Sete Lagoas", sigla = "MG", data=data_relatorio, 
                                   alert=ale.den, shape=shape, varid=shapeID,
                                   dir=out, datasource=con, geraPDF=TRUE)
  
  #publicarAlerta(ale = aleFort, pdf = bol, dir = "Relatorio/CE/Municipios/Fortaleza")
    save(ale.den, file = paste0("alertasRData/aleMG-rg",data_relatorio,".RData"))
}



# ----- Fechando o banco de dados
dbDisconnect(con)

