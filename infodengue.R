#################################################
## Run Infodengue pipeline from Command-Line ##
#################################################
## Author: Claudia Codeco
## Last update: 2020
## Usage:
## Rscript infodengue.R -uf RJ -mn 3304557 -rg MG -se 201951 -wr true -sb false -te

##    -uf: to run statewise alert. E.g.: RJ, PR 
##    -mn: to run the alert at municipality level. E.g.: RJ
##    -rg: to run the alert at regional level. E.g.: MG 
##    -se: report's epidemiological week. E.g.: 202001 
##    -wr: password to write into the historico alerta table directly. Otherwise, saves an RData object. 
##    -sb: supress boletim creation
##    -te: testing the code (not implemented yet)

## pass
library(getPass)
pw <- getPass()

## Logging parameters
library(futile.logger, quietly = TRUE)
logging = TRUE
log_level = futile.logger::TRACE
alog <- paste0("AlertaDengueAnalise/log/",Sys.Date())

flog.appender(appender.tee(alog))

## Process arguments
myarg <- commandArgs(TRUE)
if(length(myarg)==0) stop("Run script like this: \n\t Rscript infodengue.R -uf RJ -mn 3304557 -se 201951") 
myarg <- unlist(strsplit(myarg, " {1,}"))
myargv <- myarg[seq(2, length(myarg), by=2)]
names(myargv) <- gsub("-", "", myarg[seq(1, length(myarg), by=2)])

## handling input errors
if(!any(names(myargv) %in% c("uf","mn","rg","se","wr","sb","te","pw"))) stop("One or more unknown arguments.")
if(any(names(myargv) %in% "mn") & !any(names(myargv) %in% "uf")) stop("Please specify -uf and -mn to run the municipal pipeline.")
if(any(names(myargv) %in% "rg") & !any(names(myargv) %in% "uf")) stop("Please specify -uf and -rg to run the regional pipeline.")
if(!any(names(myargv) %in% c("uf","mn","rg"))) stop("Run script like this: \n\t Rscript infodengue.R -uf RJ -mn 3304557 -se 201951")
if(!any(names(myargv) %in% "se")) stop("Run script like this: \n\t Rscript infodengue.R -uf RJ -mn 3304557 -se 201951")

# Check date
data_relatorio = as.numeric(unlist(myargv[["se"]]))	
stopifnot(data_relatorio > 201000) 


# Default writing argument is FALSE
if(!any(names(myargv) %in% "wr")) myargv <- c(myargv, wr="no") # Sets write default to no. Saving RData only.  
writedb = ifelse(myargv[["wr"]]=="no", FALSE, TRUE)

# Default reporting 
if(!any(names(myargv) %in% "sb")) {
	myargv <- c(myargv, bol="yes")  # Sets boletim default to yes.
} else  {myargv <- c(myargv, bol="no")}  
write_report = ifelse(myargv[["bol"]]=="yes", TRUE, FALSE)

# Location of Scripts
mains = dir("AlertaDengueAnalise/main/")
print(mains)
## If '-uf' only is provided, run state: 
if(any(names(myargv) %in% "uf" & !any(names(myargv) %in% c("mn", "rg")))) {
  arq = paste0("main_E",myargv[["uf"]],".R")
  if(!(arq %in% mains))stop("script not found. Check if arguments are correct.")
} 

## If '-mn' is provided: 
if(any(names(myargv) %in% "mn")) {
  mn <- myargv[["mn"]]
  arq <- paste0("main_", myargv[["uf"]] ,"_municipios.R")
  if(!(arq %in% mains))stop("script not found. Check if arguments are correct.")
}

## If '-rg' is provided: 
if(any(names(myargv) %in% "rg")) {
  arq = paste0("main_", myargv[["uf"]] ,"_regional.R")
  if(!(arq %in% mains))stop("script not found. Check if arguments are correct.")
}

## Starting the pipeline
flog.info("executing %s", arq, name = alog)
flog.info("Argumentos",myargv, capture=TRUE, name = alog)

con <- dbConnect(drv = dbDriver("PostgreSQL"), dbname = "dengue", 
                 user = "dengue", host = "localhost", 
                 password = pw)

source(paste0("AlertaDengueAnalise/main/", arq))

flog.info(paste(arq, "done"), name = alog)


#print(paste("Ultimos registros de dengue:",lastDBdate("sinan", city=330455,datasource=datasource)))
## Import paths and names of fastq samples
#  fastqDF <- read.delim(myargv[["i"]])
#  fastq <- as.character(fastqDF$Files); names(fastq) <- fastqDF$Samples

## Generate fastq statistics and store results in list
#  fqlist <- seeFastq(fastq=fastq, batchsize=as.numeric(myargv[["s"]]), klength=as.numeric(myargv[["k"]]))
#  save(fqlist, file=paste(myargv[["o"]], ".list", sep=""))
#}

## If '-l' is provided, import precomputed list object and generate plot in next step
#if(any(names(myargv) %in% "l")) {
## Import paths and names of fastq samples
#  load(file=myargv[["l"]])
#}

## Generate plots and output graphics to file
#if(myargv[["a"]] == "all") { # Specify row arrangement in plot
#  myrow <- c(1, 2, 3, 4, 5, 8, 6, 7)
#} else {
#  myrow <- as.numeric(unlist(strsplit(myargv[["a"]], "_")))	
#}
#if(myargv[["c"]] == "all") { # Specify column arrangement in plot
#  mycol <- seq(along=fqlist)
#} else {
#  mycol <- as.numeric(unlist(strsplit(myargv[["c"]], "_")))	
#}
#pdf(myargv[["o"]], height=18, width=4*length(fqlist))  
#seeFastqPlot(fqlist[mycol], arrange=myrow)
#dev.off()



