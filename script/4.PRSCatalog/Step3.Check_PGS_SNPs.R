setwd("./")

#args = commandArgs(trailingOnly=TRUE)

############ Required Packages ######################

#####################################################



library(data.table)
library(dplyr)

cat(prompt="Select the TPMI data type ( [1]:Raw TPMI Chip data / [2]:Imputed TPMI Chip data): ")
Data_type<-readLines(con="stdin",1)

cat("\n")

list_PGS_print<-fread('./output/Related_PGSID_List.txt',sep=",",header=F)
cat("\n")
cat("\n")
print(list_PGS_print)
cat("\n")
cat("\n")
cat(prompt="Please Input your PGSID (Ex: PGS000001|PGS000002) :")

LIST<-readLines(con="stdin",1)

################ Required data prepare: #########################

######### Select data: #######

tmp_raw<-c("./data/PGScatlog/TPMI-raw/PGS-SNP-info-table-done.txt")
tmp_imputed<-c("./data/PGScatlog/TPMI-imputed/PGS-SNP-info-table-imputed-done.txt")

if (Data_type == "1"){
selected_data_type=tmp_raw
print("Your selected data type is: Raw data")
}else if(Data_type == "2") {
selected_data_type=tmp_imputed
print("Your selected data type is: Imputed data")
}else {
selected_data_type=tmp_raw
}

##############################

PGS_SNP_info<-fread(selected_data_type,sep="\t",header= T)

search_list<-LIST

PGS_SNP_info_select<-PGS_SNP_info[grepl(search_list,PGS_SNP_info$PGS_ID),]

cat('\n')
cat('\n')

print(PGS_SNP_info_select)

cat('\n')
cat('\n')
cat('\n')
cat('Datail Information of PGS SNPs is in the following dirertory:')
cat('\n')
cat('/new_storage_1/bioinfo/PGS-Catlog/PGS-SNP-info-table/')
cat('\n')
cat('\n')