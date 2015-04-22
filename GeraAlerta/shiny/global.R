#options(warn=-1)
dadosAPS <- "./dadosAPS_201514.csv"
d<-read.csv(dadosAPS)
source("./calcRt.r")

dfRt <- calcdfRt()
