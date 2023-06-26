setwd("./")

#args = commandArgs(trailingOnly=TRUE)

cat(prompt="Input your patient list (Full directory): ")
Input_list<-readLines(con="stdin",1)

cat(prompt="Output file name (Short Name): ")
Output_name<-readLines(con="stdin",1)

cat(prompt="Please input your matching ratio:(1-10) ")
Matching_Ratio_input<-readLines(con="stdin",1)

# Select matching ratio

if (as.numeric(Matching_Ratio_input) > 10){
print("Your matching ratio is too high, we will use default ratio: 4")
Matching_Ratio=4
}else if(as.numeric(Matching_Ratio_input) <= 0) {
print("Your matching ratio must be a positive number, we will use default ratio: 4")
Matching_Ratio=4
}else {
cat("Your matching ratio is: ", Matching_Ratio_input)
Matching_Ratio=as.numeric(Matching_Ratio_input)
}

# Use Optional covariate list
cat('\n')
cat('\n')
cat(prompt="Do you have other covariate list? ")
cat('[1]Yes  [2]No (Default)')
cat('\n')
cat('\n')
covariate_input<-readLines(con="stdin",1)

if (covariate_input == "1"){
print("Input your patient covariate list (Full directory):")
covariate_list<-readLines(con="stdin",1)

}else if(covariate_input == "2") {
print("You don't have covariate list, use default TPMI list")
covariate_list<-"./TPMI-list/TPMI-29W-PTID-Name.txt"

}else {
print("You don't have covariate list, use default TPMI list (Default)")
covariate_list<-"./TPMI-list/TPMI-29W-PTID-Name.txt"
}


library(data.table)
library(dplyr)
library(broom)
library(gtsummary)
library(MatchIt)
library(ggplot2)

# read file

Input<-fread(Input_list,sep="\t",header=T)
TPMI_list<-fread(covariate_list,sep="\t",header=T)

# Check duplicate
colnames(Input)[1]<-"PatientID"
colnames(Input)[2]<-"Pheno"
Input_unique<-distinct(Input,PatientID,.keep_all = T)

# Count number of duplicate
num_dup=nrow(Input)-nrow(Input_unique)
cat('\n')
cat('##### Input Sample Information #####')
cat('\n')
cat('\nInput Sample Num. is:', nrow(Input))
cat('\nInput Sample Num. duplicated is:', num_dup)
cat('\nInput Sample Num. unique is:', nrow(Input_unique))
cat('\n')


# Get Patients with (without) TPMI

Patient_List_TPMI<-left_join(Input,TPMI_list,by=c("PatientID"="PatientID"))

# Check duplicate

Patient_List_TPMI_unique=distinct(Patient_List_TPMI,PatientID,.keep_all = T)

# Get the list of TPMI with PatientID

no_chip=subset(Patient_List_TPMI_unique,is.na(Patient_List_TPMI_unique$Sex))
have_chip=subset(Patient_List_TPMI_unique,!is.na(Patient_List_TPMI_unique$Sex))

cat('\n')
cat('##### TPMI Chip Information #####')
cat('\n')
cat('\nSample Num. with TPMI chip is:', nrow(have_chip))
cat('\nSample Num. without TPMI chip is:', nrow(no_chip))
cat('\n')
cat('\n')

# Output the data

tmp_no_chip=paste0('./output/',Output_name,'-no-chip-list.txt',collapse = '')
tmp_have_chip=paste0('./output/',Output_name,'-have-chip-list.txt',collapse = '')

fwrite(no_chip,tmp_no_chip,sep="\t",col.names = T)
fwrite(have_chip,tmp_have_chip, sep="\t",col.names = T)

# Make the GWAS-ready Pheno table

have_chip_GWAS=have_chip[,c("GenotypeName","GenotypeName","Sex","Age","Pheno")]


colnames(have_chip_GWAS)<-c("FID","IID","Sex","Age","Pheno")

# Perform Sex age matching

cat('\n')
cat('\n')
cat('##### Perform Age Sex matching...... #####')
cat('\n')
cat('\n')
cat("Your matching ratio is: ", Matching_Ratio)
cat('\n')
cat('\n')

have_chip_GWAS$Pheno<-recode_factor(have_chip_GWAS$Pheno,"1"="0","2"="1")

have_chip_GWAS.match <- matchit(Pheno ~ Age + Sex, data = have_chip_GWAS, method="nearest", ratio=Matching_Ratio)
have_chip_GWAS.match.df <-match.data(have_chip_GWAS.match)
have_chip_GWAS.match.df$Pheno<-recode_factor(have_chip_GWAS.match.df$Pheno,"0"="1","1"="2")

tmp_have_chip_GWAS.match.df=paste0('./output/',Output_name,'.matched-data.txt',collapse = '')
fwrite(have_chip_GWAS.match.df,tmp_have_chip_GWAS.match.df, sep="\t",col.names = T)


# Prepare After Perform Matching plot

match_plot<-have_chip_GWAS.match.df

match_plot$Sex<-recode_factor(match_plot$Sex,"1"="Male","2"="Female")
match_plot$Pheno<-recode_factor(match_plot$Pheno,"1"="Control","2"="Case")

#  Age box plot  

tmp_mplot_age=paste0('./pheno/',Output_name,'.match.age.png',collapse = '')

mplot_age=ggplot(match_plot,aes(x=Pheno,y=Age))+
    geom_boxplot(alpha=0.4, position = 'identity')+
    stat_summary(aes(label=sprintf("%1.1f", ..y..), color=factor(Pheno)),geom="text", 
                fun = function(y) boxplot.stats(y)$stats,position=position_nudge(x=0.45), size=3.5)+
    labs( x = "Stroke", y = "Count",title ="Age box plot in Matched data")
ggsave(mplot_age,file=tmp_mplot_age,height = 8,width  = 8)


#  Sex distribution plot   

tmp_mplot_sex=paste0('./pheno/',Output_name,'.match.sex.png',collapse = '')

match_plot_df <- match_plot %>%
    filter(Sex %in% c("Male", "Female")) %>%
    group_by(Pheno, Sex) %>%
    summarise(counts = n()) 

mplot_sex=ggplot(match_plot_df, aes(x = Pheno, y = counts)) +
    geom_bar(aes(color = Sex, fill = Sex),stat = "identity", position = position_dodge(0.8),width = 0.7) +
    scale_color_manual(values = c("lightblue", "pink"))+
    scale_fill_manual(values = c("lightblue", "pink"))+
    geom_text(aes(label = counts, group = Sex), position = position_dodge(0.8),vjust = -0.3, size = 3.5)+
    labs( x = "Stroke", y = "Count",title ="Sex bar plot in Matched data")
ggsave(mplot_sex,file=tmp_mplot_sex,height = 8,width  = 8)



# Get Case Control Number

control=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="1")
case=subset(have_chip_GWAS.match.df,have_chip_GWAS.match.df$Pheno=="2")    


cat('\n')
cat('##### TPMI Chip for GWAS + PRS Information #####')
cat('\n')
cat('\nNum. of GWAS + PRS in case is:', nrow(case))
cat('\nNum. of GWAS + PRS in control is:', nrow(control))
cat('\n')
cat('\n')

cat('######### GWAS PRS data Sepration #####')
cat('\n')
cat('\n')
cat(prompt="Please specify GWAS rate(ex: 0.8): ")
training_rate<-as.numeric(readLines(con="stdin",1))

# Sample collection 8:2

### Control ####

smp_size_control <- floor(training_rate * nrow(control))
train_ind_control <- sample(seq_len(nrow(control)), size = smp_size_control)

train_control <- control[train_ind_control, ]
test_control <-  control[-train_ind_control, ]

### Case ####

smp_size_case <- floor(training_rate * nrow(case))
train_ind_case <- sample(seq_len(nrow(case)), size = smp_size_case)

train_case <- case[train_ind_case, ]
test_case <-  case[-train_ind_case, ]

# Combine the randomm seleted case control data

train.data<-rbind(train_control,train_case)
test.data<-rbind(test_control,test_case)
cat('\n')
cat('\n')
cat('##### Information of GWAS data  #####')
cat('\n')
cat('\n')
train.data$Pheno<-as.factor(train.data$Pheno)
summary(train.data)
cat('\n')
cat('##### Information of PRS data  #####')
cat('\n')
cat('\n')
test.data$Pheno<-as.factor(test.data$Pheno)
summary(test.data)
cat('\n')

# Get the full GWAS + PRS data

cat('##### Output of FULL Pheno table  #####')
cat('\n')

gwas_prs_data<-rbind(train.data,test.data)


# Output the data

tmp_gwas=paste0('./pheno/',Output_name,'.GWAS.pheno.txt',collapse = '')
tmp_prs=paste0('./pheno/',Output_name,'.PRS.pheno.txt',collapse = '')
tmp_gwas_prs=paste0('./pheno/',Output_name,'.ALL.pheno.txt',collapse = '')

fwrite(train.data,tmp_gwas,sep="\t",col.names = T)
fwrite(test.data,tmp_prs, sep="\t",col.names = T)
fwrite(gwas_prs_data,tmp_gwas_prs,sep="\t",col.names = T)

cat('\n')
cat('##### GWAS PRS Sepration successfully #####\n')
cat('\n')
cat('\n')
cat('##### GWAS-ready Information #####')
cat('\n')
cat('\n The GWAS-ready Phenotype table was output in:',tmp_gwas)
cat('\n')
cat('\n')
cat('##### PRS-ready Information #####')
cat('\n')
cat('\n The PRS-ready Phenotype table was output in:',tmp_prs)
cat('\n')
cat('\n Ready for Next step: GWAS Analysis......')
cat('\n')
cat('\n')