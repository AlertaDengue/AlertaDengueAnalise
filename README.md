# AlertaDengueAnalise

## Gerar o objeto alerta de forma remota

Para gerar o alerta, as seguintes bibliotecas são necessárias: 
```bash
if (!require('foreign')){install.packages("foreign")} 
if (!require('forecast')){install.packages("forecast")} 
if (!require('RPostgreSQL')){install.packages("RPostgreSQL")} 
if (!require('xtable')){install.packages("xtable")} 
if (!require('zoo')){install.packages("zoo")} 
if (!require('tidyverse')){install.packages("tidyverse")} 
if (!require('assertthat')){install.packages("assertthat")} 
if (!require('futile.logger')){install.packages("futile.logger")} 
if (!require('gridExtra')){install.packages("gridExtra")} 
if (!require('ggridges')){install.packages("ggridges")} 
if (!require('grid')){install.packages("grid")} 
if (!require('cgwtools')){install.packages("cgwtools")} 
if (!require('AlertTools')){
    if(!require("devtools")) install.packages("devtools")
    library("devtools")
    install_github("AlertaDengue/AlertTools", dependencies = TRUE)} 
if (!require('ggTimeSeries')){
    if(!require("devtools")) install.packages("devtools")
    library("devtools")
    install_github("AtherEnergy/ggTimeSeries")} 

# INLA: https://www.r-inla.org/download-install

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(c("graph", "Rgraphviz"), dep=TRUE)

install.packages("INLA",repos=c(getOption("repos"),INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)
```


Essas bibliotecas estão listadas: (AlertaDengueAnalise/blob/master/config/config_global_2020.R)

Os códigos parar gerar o objeto alerta para os respectivos estados e municípios estão no diretório: (AlertaDengue/AlertaDengueAnalise/tree/master/main). 

Para rodar o script é necessário uma conexão via chave ssh com o sistema (ssh -f infodengue@info.dengue.mat.br -L 5432:localhost:5432 -nNTC), não é necessário nenhuma edição nos scripts, sendo apenas definido a data do relatório. Os objetos serão salvos dentro do diretório (main/alertas/'data_relatorio') e o output SQL (main/sql)





