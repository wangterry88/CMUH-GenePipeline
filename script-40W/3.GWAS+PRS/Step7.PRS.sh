#!/bin/bash

echo "Enter the Base file (GWAS summary stat.) (Full directory): "
read BASE  

echo "Enter the Target file (Full directory): "
read TARGET 

echo "Enter the PRS PHENO file (Full directory): "
read PHENO

echo "Enter the PRS R2: "
read R2

echo "Output name of the PRS result (Short name): "
read PRS_OUTPUT

#echo "Enter the lower bound of P-value (5e-08): "
#read LOWER_B

#echo "Enter the upper bound of P-value (1e-05): "
#read UPPER_B

Rscript ./tools/PRSice2/PRSice.R \
--prsice ./tools/PRSice2/PRSice_linux \
--base ${BASE} \
--target ${TARGET} \
--binary-target T \
--pheno ${PHENO} \
--pheno-col Pheno \
--cov ${PHENO} \
--cov-col Age,Sex \
--stat OR \
--or \
--A1 A1 \
--pvalue P \
--score std \
--thread 64 \
--print-snp \
--seed 123456789 \
--snp SNP \
--clump-r2 ${R2} \
--out ./PRS/result/${PRS_OUTPUT} 
#--quantile 10 \
#--no-default \
#--extract ./PRS/result/${PRS_OUTPUT}.valid
#--bar-levels 5e-08,5e-07,5e-06,5e-05,0.0001,0.001,0.05,0.1,0.2,0.3,0.4,0.5,1 \