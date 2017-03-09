#!/usr/bin/env Rscript 
args = commandArgs(trailingOnly=TRUE)


# ==============================
# Reading and checking arguments
# ==============================

if (length(args)!=2){ 
  stop("Missing arguments: main.R file and/or the epidemiological week.n", call.=FALSE)
} else {
  
  # main.R file
  mainfile = args[1]
  if (!(mainfile %in% dir(path = "main/"))) stop("this main file does not exist.n")
  
  # report date (epidemiological yearweek)
  data_relatorio = as.numeric(args[2])  
  if (!class(data_relatorio)=="numeric") stop("report date should be numeric (p.e. 201503)")
  if (!nchar(data_relatorio == 6)) stop("report date should have 6 characters (p.e. 201503)")
  if (floor(data_relatorio/100)<2000) stop("report date should have the following format: 201503")
}

print(paste("Running infodengue.R for", data_relatorio, "using",mainfile))


# ============================
# Sourcing the main file
# ============================

source(paste("main/",mainfile,sep=""))



# USE: system("Rscript infodengue.R ")
