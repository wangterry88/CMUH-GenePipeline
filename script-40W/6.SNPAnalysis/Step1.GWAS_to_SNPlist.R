setwd("./")

cat(prompt="Input GWAS results (Full directory): ")
GWAS_RESULT<-readLines(con="stdin",1)

######### Install packages ###########

library(data.table)
library(dplyr)
library(tibble)

GWAS<-fread(GWAS_RESULT,sep="\t",header = T)

######################################

GWAS_sig<-subset(GWAS,GWAS$P<5e-08)
GWAS_sig_SNP<-GWAS_sig[,c("ID")]

fwrite(GWAS_sig_SNP,"./output/SNP_Sig_list.txt",col.names = F)