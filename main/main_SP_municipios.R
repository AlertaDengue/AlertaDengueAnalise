#====================================================
## Alertas municipais do Estado de São Paulo
#====================================================
# cidades: SJ Rio Preto (3549805), Bauru ()

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "São Paulo"
sig = "SP"
shape="AlertaDengueAnalise/report/SP/shape/35MUE250GC_SIR.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/SP/Municipios"
dir_rel = "Relatorio/SP/Municipios"


# data do relatorio:---------------------
#data_relatorio = 201851
dia_relatorio = seqSE(data_relatorio,data_relatorio)$Termino

# cidade -------------------------------
#geo <- 3549805
geo <- as.numeric(mn)  # from infodengue.R

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = alog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)
#ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "bayesian", finalday = dia_relatorio)
#ale.zika <- pipe_infodengue(geo, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)

# Boletim ----------------------------------
if(write_report) {
  # dir exists?
  nome <- ale.den[[1]]$data$nome[1]
  nomesemespaco = gsub(" ","",nome)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  out = paste0("AlertaDengueAnalise/report/SP/Municipios/",nomesemacento) 
  dir.create(file.path(out), showWarnings = FALSE) # check if directory exists
  dir.create(file.path(paste0(out, "/figs/")), showWarnings = FALSE) # check if directory exists
  
  
#  flog.info(paste("writing boletim de ", nome))
  bol <- configRelatorioMunicipal(alert = ale.den, tipo = "simples", 
                                  varcli = "temp_min", estado = estado, siglaUF = sig, data = data_relatorio, 
                                  dir.out = out, geraPDF = TRUE)
  
  dir_rel <- paste0("Relatorio/SP/Municipios/",nomesemacento) 
  dir.create(file.path(dir_rel), showWarnings = FALSE) # check if directory exists
  publicarAlerta(ale = ale.den, pdf = bol, dir = dir_rel)
}

save(ale.den, file = paste0("alertasRData/aleSP-mn",data_relatorio,".RData"))

# ----- Fechando o banco de dados
dbDisconnect(con)


