setwd("./")

##### Required packages #####

library(data.table)
library(dplyr)
library(ggplot2)
library(transport)

cat('\n')
cat('\n')
cat(prompt="Input your phenotype name: ")
cat('\n')
phenotype_input<-readLines(con="stdin",1)

##### Read data #####

phencode_table<-fread("./data/TPMI_phencode_pheno.txt",sep="\t",header = T)

####### Perpare columns ######

input<-phenotype_input
PatID<-c("PatientID")

input_list<-paste(PatID,input,sep="|")
disease_input<-subset(phencode_table,select = grepl(input_list, names(phencode_table)))

####### Count Number of selected disease ######

disease_num_table<-
    disease_input %>%
    summarize_if(is.numeric, sum, na.rm=TRUE)

#disease_num_table<-disease_num_table[,-1]

##### Print search result on the screen ######

show<-as.data.frame(t(disease_num_table)) # transpose the table
show<-tibble::rownames_to_column(show, "Disease_name") # make the row name to first column
colnames(show)[2]<-"Num_Case" # Set column name of 2nd column

###### Remove the PatientID row #####

show_final<-show[-1,] # Remove the PatientID row 
fwrite(show_final,'./output/Select_count.txt',sep="\t",col.names = T)

cat('\n')
cat('\n')
cat('Selected disease results:')
cat('\n')
cat('\n')

print(show_final,row.names = F)

cat('\n')
cat('\n')
cat('Selected disease list is output in:  ./output/Select_count.txt')

cat('\n')
cat('\n')
cat(prompt="Select ONE of your disease name from the search output: ")
cat('\n')

phenotype_select<-readLines(con="stdin",1)

####### Perpare select columns ######

select<-phenotype_select
PatID<-c("PatientID")

select_list<-append(PatID,select)

####### Get the selected disease dataframe ######

disease_select<-select(phencode_table,one_of(select_list))

####### Get the final selected disease dataframe ######

disease_select_final<-na.omit(disease_select)
disease_select_final[,2]<-disease_select_final[,2]+1 # For GWAS or PRS analysis

fwrite(disease_select_final,'./output/Select_list.txt',sep="\t",col.names = T)


####### Print the Case Control Number of selected data #######

ctrl<-filter(disease_select_final, disease_select_final[,2] == "1")  
case<-filter(disease_select_final, disease_select_final[,2] == "2")  

cat('\n')
cat('\n')
cat('Number of Control with user select is:',nrow(ctrl))
cat('\n')
cat('Number of Case with user select is:',nrow(case))
cat('\n')
cat('Selected disease list is output in:  ./output/Select_list.txt')
cat('\n')
cat('\n')
cat('\n')
cat('\n')