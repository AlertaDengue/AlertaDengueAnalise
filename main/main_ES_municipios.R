#====================================================
## Alertas municipais do Estado do Espírito Santo
#====================================================
# cidades participantes (rever): Alfredo Chaves (3200300); 
# Linhares (3203205); Sta Maria Jetiba (3204559); Anchieta (320040);
# Rio Novo do Sul (320440);  Aracruz (320060); Atilio Vivaqua (320070);
# Conceição do Castelo (320170); Domingo Martins (320190); Itaguaçu (320270);
# Jerônimo Monteiro (320310); Laranja da Terra (320316);
# Marechal Floriano (320334); Mimoso do Sul (320340); Mucurici (320360);
# Muqui (320380); Pinheiros (320410); Vila Velha (320520)

# Cabeçalho ------------------------------
setwd("~/")
source("AlertaDengueAnalise/config/config_global.R") #configuracao 
con <- DenguedbConnect(pass = pw)  

# parametros especificos -----------------
estado = "Espírito Santo"
sig = "ES"
shape="AlertaDengueAnalise/report/ES/shape/32MUE250GC_SIRm.shp"
shapeID="CD_GEOCMU" 
# onde salvar boletim
out = "AlertaDengueAnalise/report/ES/Municipios"
dir_rel = "Relatorio/ES/Municipios"

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

# cidade -------------------------------
#geo <- 3200300

# pipeline -------------------------------
flog.info(paste("alerta dengue", geo ,"executing..."), name = aalog)

ale.den <- pipe_infodengue(geo, cid10 = "A90", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.chik <- pipe_infodengue(geo, cid10 = "A92.0", nowcasting = "fixedprob", finalday = dia_relatorio)
ale.zika <- pipe_infodengue(geo, cid10 = "A92.8", nowcasting = "fixedprob", finalday = dia_relatorio)


# Boletim ----------------------------------
if(write_report) {
  # dir exists?
  nome <- ale.den[[1]]$data$nome[1]
  nomesemespaco = gsub(" ","",nome)
  nomesemacento = iconv(nomesemespaco, to = "ASCII//TRANSLIT")
  out = paste0("AlertaDengueAnalise/report/ES/Municipios/",nomesemacento) 
  dir.create(file.path(out), showWarnings = FALSE) # check if directory exists
  dir.create(file.path(paste0(out, "/figs/")), showWarnings = FALSE) # check if directory exists
  
  
  flog.info(paste("writing boletim de ", nome), name = aalog)
  bol <- configRelatorioMunicipal(alert = ale.den, alechik = ale.chik, alezika = ale.zika, tipo = "simples", 
                                   varcli = "temp_min", estado = estado, siglaUF = sig, data = data_relatorio, 
                                   dir.out = out, geraPDF = TRUE)
  
  #publicarAlerta(ale = aleFort, pdf = bol, dir = "Relatorio/CE/Municipios/Fortaleza")
}
 

# ----- Fechando o banco de dados
dbDisconnect(con)


