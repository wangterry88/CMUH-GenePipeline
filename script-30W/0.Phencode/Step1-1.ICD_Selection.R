setwd("./")

##### Required packages #####

library(data.table)
library(dplyr)
library(ggplot2)
library(transport)

cat('\n')
cat('\n')
cat(prompt="Input your ICD name, with ICD9 or ICD10 (Ex: 434.91|G45.4): ")
cat('\n')
ICD_input<-readLines(con="stdin",1)

##### Read ICD data #####

ICD_table<-fread("./data/Phencode_ICD9_ICD10.txt",sep="\t",header = T)
Phencode_def<-fread("./data/Phecode_definitions.txt",sep="\t",header = T)

##### Serach Phenotype Name by ICD codes ######

serach_result<-
    ICD_table %>% 
    filter(if_any(everything(), ~ grepl(ICD_input, .)))

##### Get Serach Phenotype Name Results ######

serach_result_unique<-distinct(serach_result,Phenotype_Name,.keep_all = F)


##### Get Serach Phenotype Name with exclusion critiria ######

serach_result_critiria<-left_join(serach_result_unique,Phencode_def,by=c("Phenotype_Name"="Phenotype"))

fwrite(serach_result_critiria,'./output/ICD_phenotype_list.txt',sep="\t",col.names = T)

##### Print the Results ######

cat('\n')
cat('\n')
cat('Your input ICD codes related Phenotype names is:')
cat('\n')
cat('\n')
print(serach_result_unique)
cat('\n')
cat('\n')
cat('Your ICD codes related Phenotype critira is output at: ./output/ICD_phenotype_list.txt')
cat('\n')
cat('\n')