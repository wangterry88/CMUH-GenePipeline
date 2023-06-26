#!/bin/bash

echo "Enter the GWAS phenotype file (Full directory): "
read PHENO_COV  

echo "Enter the Data type:"
echo "[1]Raw Chip data  [2]Imputed Chip data  [Default]Raw Chip data"
read CHIP_TYPE

if [ $CHIP_TYPE -eq 1 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_RAW/TPMI_29W_RAW
	echo "Your Selected Chip Type is : Raw Chip data"
elif [ $CHIP_TYPE -eq 2 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_imputed/clean/TPMI_29W_imputed_clean
    echo "Your Selected Chip Type is : Imputed Chip data"
else
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_RAW/TPMI_29W_RAW
    echo "(Default) Your Selected Chip Type is : Raw Chip data"
fi

echo "Output name of the GWAS result (Short Name): "
read GWAS_OUTPUT

# BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_RAW/TPMI_29W_RAW
# BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_imputed/clean/TPMI_29W_imputed_clean

#COVAR_NAME=`head -n 1 ${PHENO_COV} |cut -f 4- |sed 's/\t/,/g'`

#echo $COVAR_NAME
if [ $CHIP_TYPE -eq 1 ]; then
	./tools/plink2 \
	--bfile ${BFILE} \
	--covar ${PHENO_COV} \
	--covar-name Sex,Age \
	--geno 0.05 \
	--glm firth-fallback hide-covar \
	--hwe 0.00001 \
	--mind 0.1 \
	--ci 0.95 \
	--out ./GWAS/${GWAS_OUTPUT} \
	--pheno ${PHENO_COV} \
	--pheno-name  Pheno \
	--memory 500000 \
	--threads 120
elif [ $CHIP_TYPE -eq 2 ]; then
	mkdir ./GWAS/Parallel
	parallel --bar -j 10 \
    	./tools/plink2 \
        	--bfile ${BFILE} \
        	--chr {} \
        	--pheno-name Pheno \
        	--covar ${PHENO_COV} \
        	--covar-name Sex,Age \
			--geno 0.05 \
        	--glm firth-fallback hide-covar \
			--hwe 0.00001 \
			--mind 0.1 \
    		--ci 0.95 \
			--pheno  ${PHENO_COV} \
			--memory 500000 \
			--threads 120 \
			--out ./GWAS/chr{}_${GWAS_OUTPUT} ::: {1..22}

	head -n 1 ./GWAS/chr1_${GWAS_OUTPUT}.Pheno.glm.logistic.hybrid > ./GWAS/Merge_${GWAS_OUTPUT}_GWAS.Pheno.glm.logistic; \
	tail -n +2 -q ./GWAS/chr*_${GWAS_OUTPUT}.Pheno.glm.logistic.hybrid >> ./GWAS/Merge_${GWAS_OUTPUT}_GWAS.Pheno.glm.logistic
	
	mv ./GWAS/chr*_${GWAS_OUTPUT}.Pheno.glm.logistic.hybrid ./GWAS/Parallel/
	mv ./GWAS/chr*_${GWAS_OUTPUT}.log ./GWAS/Parallel/
	echo "Imputed GWAS result were output in:" 
	echo ""
	echo "./GWAS/Merge_${GWAS_OUTPUT}_GWAS.Pheno.glm.logistic"
	echo ""
fi