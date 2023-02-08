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
Essas bibliotecas estão listadas: (https://github.com/AlertaDengue/AlertaDengueAnalise/blob/master/config/config_global_2020.R)

Para rodar o script é necessário uma conexão via chave ssh com o sistema.

### Gerar o alerta

O código parar gerar o objeto alerta estadual: https://github.com/AlertaDengue/AlertaDengueAnalise/blob/master/main/main_BR.R 
 






