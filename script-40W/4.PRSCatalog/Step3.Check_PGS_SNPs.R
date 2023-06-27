setwd("./")

library(data.table)
library(dplyr)

cat(prompt="Select the TPMI data type ( [1] 30W TPMI Chip data / [2] 40W TPMI Chip data (Default)): ")
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

tmp_30W<-c("./data/PGScatlog/TPMI-imputed/PGSCatlog-information-30W.txt")
tmp_40W<-c("./data/PGScatlog/TPMI-imputed/PGSCatlog-information-40W.txt")

if (Data_type == "1"){
    selected_data_type=tmp_30W
    print("Your selected data type is: 30W data")
}else if(Data_type == "2") {
    selected_data_type=tmp_40W
    print("Your selected data type is: 40W data")
}else {
    selected_data_type=tmp_40W
    print("Your selected data type is: 40W data (default)")
}

PGS_SNP_info<-fread(selected_data_type,sep="\t",header= T)

search_list<-LIST

PGS_SNP_info_select<-PGS_SNP_info[grepl(search_list,PGS_SNP_info$PGSID),]

cat('\n')
cat('\n')
print(PGS_SNP_info_select)
cat('\n')

fwrite(PGS_SNP_info_select,"./output/Related_PGSID_List_SNPinfo.txt",sep="\t",col.names=T)

cat('Step3 Done......')
cat('\n')
cat('\n')