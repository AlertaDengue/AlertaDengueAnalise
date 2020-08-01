#### gera boletim municipal ##
### Infodengue 2020  
### autora: claudia codeco 

source("AlertaDengueAnalise/config/codigo_figuras_municipio.R")


gera_boletim_municipio <- function(ale, uf, dir.out = out, dirb = basedir, publicar = FALSE){
  
  # verifica se existe o local para salvar as figuras e o boletim, se nao tiver, gera aviso
  dirout <- paste0(dirb,"/",dir.out)
  
  if(!dir.exists(dirout)) {
    message(paste("boletim nao gerado porque diretorio", dirout, "não existe. 
                  Verifique se o nome está correto. Para criar use: dir.create(out)"))
    return(NULL)
    }
 
   
   
  d <- cbind(ale[[1]]$data, ale[[1]]$indice) 
  
  d <- d %>%
    mutate(
      data = SE2date(SE)$ini,
      ano= floor(SE/100),
      sem = SE - ano*100) 
  
  cid <- d$CID10[1]
  
  # Identificacao da cidade
  nomecidade <- d$nome[1]
  geocodigo <- d$cidade[1]
  
  # parametros
  pars <- read.parameters(geocodigo, cid)
  
  # ---------------------------------  
  # MEDIDAS RESUMO
  # ---------------------------------
  N <- nrow(d)
  lastSE <- d$SE[N]
  esse_ano <- d$ano[N]
  essa_se <- d$sem[N]
  iniSE <- (esse_ano-1)*100+1 
  
 # dados desde o inicio do ano anterior")
  casos_ano <- d %>%
    group_by(ano) %>%
    summarise(
      casos = sum(casos, na.rm=TRUE),
      pop = sum(pop),
      inc = casos/pop * 100000
    )
  
  # ate a semana 
  casos_ultse <- d %>%
    filter(ano >= (esse_ano-1) & sem <= (essa_se)) %>%
    group_by(ano) %>%
    summarise(casos = sum(casos),
              pop = mean(pop),
              nweeks = n(),
              receptividade = sum(nytrue==3, na.rm = TRUE),
              transmissao = sum(notrue>=2, na.rm = TRUE),
              pos0 = sum(casos>0, na.rm=TRUE)/nweeks*100
    ) %>%
    mutate(totinc = casos/pop *100000) 
  
  
  # --------------------------------
 # FIGURAS") 
  # --------------------------------
  dirfigs <- paste0(dirout,"/figs")
  if(!dir.exists(dirfigs)) {
    message(paste("boletim nao gerado porque diretorio", dirfigs, "não existe. Verifique se o nome está correto. Para criar use: dir.create(out)"))
    return(NULL)
  }
  nomesemacento = iconv(gsub(" ","",nomecidade), to = "ASCII//TRANSLIT")
  figname = paste(dirfigs,"/figura",nomesemacento,sep="")
  
  figuras_municipio(d, param = pars, nome = figname)
  
  # ---------------------------------
  # TABELA")
  # ---------------------------------
  # ultimas 6 semanas
  
  N <- nrow(d)
  dtail <- d[(N-5):N, ] %>%
    mutate(
      receptividade = case_when(
        cytrue == 0 ~ "baixa",
        cytrue %in% 1:2 ~ "média",
        cytrue == 3 ~ "alta"
      ),
      transmissao = case_when(
        cotrue == 0 ~ "improvável",
        cotrue %in% 1:2 ~ "provável",
        cotrue == 3  ~ "sustentada"  ),
      incidencia = case_when(
        crtrue == 0 ~ "baixa",
        crtrue %in% 1:2 ~ "alta por 2 semanas",
        cotrue == 3  ~ "alta contínua"    )
    )  %>%
    select(SE, casos, tcasesmed, receptividade, transmissao, incidencia) %>%
    rename(casos_esperados = tcasesmed)
  
  cores <- c("verde","amarelo","laranja","vermelho")
  dtail <- cbind(dtail, nivel = cores[tail(d$level,n=6)])
  
  tabname <- paste(dirfigs,"/tabela",nomesemacento,".tex",sep="")
  tabelax <-xtable(dtail,align ="cc|cccccc",digits = 0)
  digits(tabelax) <- 0
  print(tabelax, type="latex", file=tabname, floating=FALSE, latex.environments = NULL,
        include.rownames=FALSE)
  print(paste("tabela",tabname,"criada"))
  # ------------------------ 
  # CRIA AMBIENTE")
  # ------------------------
  
  env <<- new.env() # ambiente que vai ser usado no relatorio, imprescindivel para o sweave funcionar
  
  env$nomecidade <- nomecidade
  env$ano <- esse_ano
  env$se <- essa_se
  env$sigla <- uf
  
  env$totanomun <- casos_ultse$casos[2]
  env$totanoant <- casos_ultse$casos[1]
  env$variacao <- round(casos_ultse$casos[2]/casos_ultse$casos[1], digits = 3)*100
  env$variacaopos <- ifelse(env$variacao > 100, "crescimento", "decrescimento")
  env$incano <- round(casos_ultse$totinc[2], digits = 1)
  
  env$weekReceptEsseAno <- casos_ultse$receptividade[2]
  env$weekReceptAnoPass <- casos_ultse$receptividade[1]
  env$weekTransmEsseAno <- casos_ultse$transmissao[2]
  env$weekTransmAnoPass <- casos_ultse$transmissao[1]
  env$weekposEsseAno <- casos_ultse$pos0[2]
  env$weekposAnoPass <- casos_ultse$pos0[1]
  
  
  env$nivel <- dtail$nivel[6]
  env$figmunicipio1 <- paste0(figname,"1.png")
  env$figmunicipio2 <- paste0(figname,"2.png")
  env$figmunicipio3 <- paste0(figname,"3.png")
  env$tabmun <- tabname
  
  
  # ----------------------------------
  print("# SWEAVE")
  # ----------------------------------
  require(tools)  
  
  # mover wd para o diretorio onde esta o Rnw:
  dir.rnw = paste0(dirb,"/AlertaDengueAnalise/report/reportconfig")
  print(dir.rnw)
  setwd(dir.rnw)
  
  # executar o sweave
  rnwfile = "BoletimMunicipalSimples_InfoDengue_2020.Rnw"
  Sweave(paste0(dir.rnw,"/",rnwfile))
  texfile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".tex",sep="")
  texi2dvi(file = texfile , pdf = TRUE, quiet=TRUE, clean=TRUE) # tex -> pdf 
  
  # gera pdf na pasta reportconfig
  pdffile = paste(unlist(strsplit(rnwfile,"[.]"))[1],".pdf",sep="") # nome do pdf
  
  # renomeia p pdf e mova para pasta dos boletins
  dir.boletim = paste(dirout,"boletins",sep="/")
  nomeboletim = paste(dir.boletim, "/",uf,"-mn-",nomesemacento,"-",Sys.Date(),".pdf",sep="")
  
  if(!dir.exists(dir.boletim)) {
    message(paste("boletim foi criado na pasta reportconfig mas nao foi movido para a pasta",dir.boletim ,"pq a não foi encontrada"))
    return(pdffile)
  }
  
  system(paste("mv", pdffile, nomeboletim))
  system(paste("rm", texfile))
  system("rm *concordance.tex")
  message(paste(nomeboletim, "created"))
  
  setwd(dirb)
  
  remove(list=ls(),envir = env)
  
  
  
  return(nomeboletim)

}





