setwd("./")

library(data.table)
library(dplyr)
library(tibble)
library(broom)
library(gtsummary)

args = commandArgs(trailingOnly=TRUE)
VCF_NAME <-args[1]
PHENO_FILE <-args[2]

VCF_PATH<-paste0('./output/',VCF_NAME,'.vcf',collapse='')
vcf<-fread(VCF_PATH,sep="\t",header=T)

### Make SNP tables

snp_info<-vcf[,c(3,4,5)]
ID_snp_info<-vcf[,-c(1:2,4:9)]

ID_snp_info_df<-as.data.frame(t(ID_snp_info))
colnames(ID_snp_info_df)<-ID_snp_info_df[1,]
ID_snp_info_df<-tibble::rownames_to_column(ID_snp_info_df, "IID")
ID_snp_info_df<-ID_snp_info_df[-c(1),]

### Make Pheno tables

pheno<-fread(PHENO_FILE,sep="\t",header=T)
pheno<-pheno[,-c(1,6,7,8)]
pheno$Sex<-recode_factor(pheno$Sex,"1"="Male","2"="Female")
pheno$Pheno<-recode_factor(pheno$Pheno,"1"="Control","2"="Case")

SNP_pheno_table<-left_join(ID_snp_info_df,pheno,c("IID"="IID"))

### Make table one

table1<-SNP_pheno_table[,-c(1)]

table1_tmp<-paste0('./output/',VCF_NAME,'.table1_data.txt',collapse='')

fwrite(table1,table1_tmp,sep="\t",col.names=T)

## Every column total (Pheno) ###

total_Pheno <-
  tbl_summary(
    table1,
    by = Pheno, # split table by group
    missing = "no" # don't list missing data separately
  ) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()

## Every column total (Sex) ###

total_Sex <-
  tbl_summary(
    table1,
    by = Sex, # split table by group
    missing = "no" # don't list missing data separately
  ) %>%
  add_n() %>% # add column with total number of non-missing observations
  add_p() %>% # test for a difference between groups
  modify_header(label = "**Variable**") %>% # update the column header
  bold_labels()

## Every column total (Pheno + Sex) ###

tbl_merge_PhenoSex <-
  tbl_merge(
    tbls = list(total_Pheno, total_Sex),
    tab_spanner = c("**Pheno**", "**Sex**")
  )

OUTPUT_TABLE_PATH<-paste0('./output/',VCF_NAME,'.Table1.html',collapse='')

tbl_merge_PhenoSex %>%
    as_gt() %>%
    gt::gtsave(filename = OUTPUT_TABLE_PATH)


## Every SNP OR ###

table_or <- table1
table_or <- select(table_or, -c(Sex,Age))

# Recode factor

table_or$Pheno<-recode_factor(table_or$Pheno,"Control"="0","Case"="1")
#table_or$Sex<-recode_factor(table_or$Sex,"Female"="0","Male"="1")

# Recode factor for pheno N

table_or_N <- table_or
table_or_N$Pheno<-recode_factor(table_or_N$Pheno,"0"="Control","1"="Case")

# Logistic Regression

tbl_reg <- 
  tbl_uvregression(
    data=table_or,
    y = Pheno, 
    method = glm,
    method.args = list(family = binomial),
    exponentiate = TRUE,
    hide_n = TRUE
  )

tbl_sum <-
  table_or_N %>%
  select(everything()) %>%
  tbl_summary(by = Pheno, 
              statistic = everything() ~ "{n}")

tbl_total_or<-tbl_merge(list(tbl_sum, tbl_reg)) %>%
  modify_spanning_header(everything() ~ NA) %>% 
  modify_header(label = "**SNPs**")

OUTPUT_OR_PATH<-paste0('./output/',VCF_NAME,'.SNP-OR.html',collapse='')

tbl_total_or %>%
    as_gt() %>%
    gt::gtsave(filename = OUTPUT_OR_PATH)