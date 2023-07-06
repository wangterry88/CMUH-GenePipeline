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
phencode_table<-fread("./data/TPMI_phencode_pheno.txt",sep="\t",header = T)

##### search Phenotype Name by ICD codes ######

search_result<-
    ICD_table %>% 
    filter(if_any(everything(), ~ grepl(ICD_input, .)))

##### Get search Phenotype Name Results ######

search_result_unique<-distinct(search_result,Phenotype_Name,.keep_all = F)


##### Get search Phenotype Name with exclusion critiria ######

search_result_critiria<-left_join(search_result_unique,Phencode_def,by=c("Phenotype_Name"="Phenotype"))

fwrite(search_result_critiria,'./output/ICD_phenotype_list.txt',sep="\t",col.names = T)

##### Print the Results ######

cat('\n')
cat('\n')
cat('Your input ICD codes related Phenotype names is:')
cat('\n')
cat('\n')
print(search_result_unique)
cat('\n')
cat('\n')
cat('Your ICD codes related Phenotype critira is output at: ./output/ICD_phenotype_list.txt')
cat('\n')
cat('\n')


#### Print all sample number of the result list

ICD_to_phencode_list<-search_result_unique$Phenotype_Name

disease_input<- phencode_table %>% select(contains(ICD_to_phencode_list))

disease_num_table<-
 disease_input %>%
 summarize_if(is.numeric, sum, na.rm=TRUE)

##### Print search result on the screen ######

show<-as.data.frame(t(disease_num_table)) # transpose the table
show<-tibble::rownames_to_column(show, "Disease_name") # make the row name to first column
colnames(show)[2]<-"Num_Case" # Set column name of 2nd column

###### Remove the PatientID row #####

show_final<-show[-1,] # Remove the PatientID row
print(show_final)

output_tmp<-paste0('./output/Phenotype_CaseNum.txt',collapse="")
fwrite(show_final,output_tmp,sep="\t",col.names = T)
cat('\n')
cat('\n')
cat('Please Copy the Disease Name, and go to next step....')
cat('\n')
cat('\n')