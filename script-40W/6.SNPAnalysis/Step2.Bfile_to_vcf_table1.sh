#!/bin/bash
echo ""
echo "########## Step2: Convert SNP to vcf ###########"
echo ""
echo "Enter the phenotype file (Full directory): "
echo "Ex: ./GWAS-Project/output/Test.matched-data.txt"
read PHENO_FILE 

echo "Enter the SNP vcf output file name (Short name): "
read OUT_FILE 

# SNP to VCF

./tools/plink \
--bfile /media/volume1/bioinfo/TPMI_Array/TPMI_40W_imputed/TPMI_40W_version1 \
--extract ./output/SNP_Sig_list.txt \
--recode vcf-iid \
--keep ${PHENO_FILE} \
--out ./output/$OUT_FILE

# VCF to Table1

Rscript ./script/6.SNPAnalysis/Step3.Vcf_to_table1.R ${OUT_FILE} ${PHENO_FILE}

