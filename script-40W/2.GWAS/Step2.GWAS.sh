#!/bin/bash

echo "Enter the GWAS phenotype file (Full directory): "
read PHENO_COV  

echo "Enter the Data type:"
echo "[1]Imputed Chip data (30W)  [2]Imputed Chip data (40W) [Default] "
read CHIP_TYPE

if [ $CHIP_TYPE -eq 1 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_imputed/clean/TPMI_29W_imputed_clean
	echo "Your Selected Chip Type is : Imputed Chip data (30W)"
elif [ $CHIP_TYPE -eq 2 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_40W_imputed/TPMI_40W_version1
    echo "Your Selected Chip Type is : Imputed Chip data (40W)"
else
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_40W_imputed/TPMI_40W_version1
    echo "[Default] Your Selected Chip Type is : Imputed Chip data (40W) "
fi

echo "Output name of the GWAS result (Short Name): "
read GWAS_OUTPUT

if [ $CHIP_TYPE -eq 1 ]; then

	mkdir ./GWAS/Parallel
	parallel --bar -j 10 \
    	./tools/plink2 \
        	--bfile ${BFILE} \
			--maf 0.01 \
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

elif [ $CHIP_TYPE -eq 2 ]; then
	
	mkdir ./GWAS/Parallel
	parallel --bar -j 10 \
    	./tools/plink2 \
        	--bfile ${BFILE} \
			--maf 0.01 \
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