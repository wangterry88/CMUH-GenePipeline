setwd("./")

##### Required packages #####

library(data.table)
library(dplyr)
library(ggplot2)
library(transport)
library(tibble)

cat('\n')
cat('\n')
cat('Preparing required data...... ')
cat('\n')
cat('\n')

CodeBook<-fread("./data/Phencode/AIC_Phencode_ICD9_ICD10_codebook.txt",sep="\t",header=T)
TPMI_40W_phecode_table<-fread("./data/Phencode/AIC_Phencode_TPMI-40W_table.txt",sep="\t",header=T)

cat('\n')
cat('Required data loading successfully.....!')
cat('\n')
cat('\n')
cat(prompt="Input your ICD name, with ICD9 or ICD10 (Ex: 434.91|G45.4): ")
cat('\n')

ICD_input<-readLines(con="stdin",1)

search_result<-
    CodeBook %>% 
        filter(if_any(everything(), ~ grepl(ICD_input, .)))

search_result_clean <- search_result %>% distinct()

fwrite(search_result_clean,'./output/ICD_phenotype_list.txt',sep="\t",col.names = T)

##### Print the Results ######

cat('\n')
cat('\n')
cat('Your input ICD codes related Phenotype names is:')
cat('\n')
cat('\n')
print(unique(search_result_clean$Phenotype_Name))
cat('\n')
cat('\n')
cat('Your ICD codes related Phenotype critira is output at: ./output/ICD_phenotype_list.txt')
cat('\n')
cat('\n')


#### Print all sample number of the result list


phecode_AIC_list<-unique(search_result_clean$phecode_AIC)

Grep_col_table<-TPMI_40W_phecode_table %>% select(one_of(phecode_AIC_list))

df.col.name<-CodeBook$Phenotype_Name[match(names(Grep_col_table), CodeBook$phecode_AIC)]

colnames(Grep_col_table)<-df.col.name

Grep_col_table_CaseNo<-as.data.frame(colSums(Grep_col_table=='2'))

colnames(Grep_col_table_CaseNo)<-"Case_Num"

Grep_col_table_CaseNo <- tibble::rownames_to_column(Grep_col_table_CaseNo, "Disease_Name")

print(Grep_col_table_CaseNo)

output_tmp<-paste0('./output/Phenotype_CaseNum.txt',collapse="")

fwrite(Grep_col_table_CaseNo,output_tmp,sep="\t",col.names = T)

cat('\n')
cat('\n')
cat('Please Copy the Disease Name, and go to next step....')
cat('\n')
cat('\n')