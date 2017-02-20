# set working directories of a new place 


# If a directory does not exist, create one.
checkDirectory <- function(directory){
  calldir <- paste("if [ -d",directory, "]; then echo \"True\"; else mkdir", directory, "; fi")
  system(calldir)
}


### Funcao para criar a arvore de diretorios
# USO: setTree.newsite(siglaestado="RS",municipio="PortoAlegre")

setTree.newsite <- function(siglaestado, regional, municipio){
  
  setwd("~/")
  dirb = getwd()
  
  # check if state directory exists
    
  diruf <- paste(dirb,"AlertaDengueAnalise/report",siglaestado,sep="/")
  checkDirectory(diruf)
  checkDirectory(paste(diruf,"figs",sep="/"))
  checkDirectory(paste(diruf,"boletins",sep="/"))
  checkDirectory(paste(diruf,"shape",sep="/"))
  
  # check if regional exists (if applies)
  if(!missing(regional)){
    if(length(strsplit(regional,split = " ")[[1]]) > 1 ) stop("Escreva o nome da regional sem espaco ou acento")
    dirRegionais <- paste(diruf,"Regionais",sep="/")
    checkDirectory(dirRegionais)
    dirreg <- paste(dirRegionais,regional,sep="/")
    checkDirectory(dirreg)
    checkDirectory(paste(dirreg,"figs",sep="/"))
    checkDirectory(paste(dirreg,"boletins",sep="/"))
  }
  
  # check if municipality exists (if applies)
  if(!missing(municipio)){
    if(length(strsplit(municipio,split = " ")[[1]]) > 1 ) stop("Escreva o nome do municipio sem espaco ou acento") 
    dirMunicipios <- paste(diruf,"Municipios",sep="/")
    checkDirectory(dirMunicipios)
    dirmun <- paste(dirMunicipios,municipio,sep="/")
    checkDirectory(dirmun)
    checkDirectory(paste(dirmun,"figs",sep="/"))
    checkDirectory(paste(dirmun,"boletins",sep="/"))
  }
  
}

