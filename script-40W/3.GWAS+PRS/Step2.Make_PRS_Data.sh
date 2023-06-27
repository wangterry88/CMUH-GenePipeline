#!/bin/bash

echo "Enter the PRS phenotype file (Full directory): "
read PHENO_COV  

echo "Output name of the PRS bfile data (Short Name): "
read PRS_DATA_OUTPUT

echo "Enter the Data type:"
echo "[1]Imputed Chip data-(30W)  [2]Imputed Chip data-(40W)  [Default] Imputed Chip data-(40W)"
read CHIP_TYPE

if [ $CHIP_TYPE -eq 1 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_imputed/clean/TPMI_29W_imputed_clean
	echo "Your Selected Chip Type is : Imputed Chip data (30W)"
elif [ $CHIP_TYPE -eq 2 ]; then
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_40W_imputed/TPMI_40W_version1
    echo "Your Selected Chip Type is : Imputed Chip data (40W)"
else
	BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_40W_imputed/TPMI_40W_version1
    echo "(Default) Your Selected Chip Type is : Imputed Chip data (40W)"
fi

./tools/plink2 \
--bfile ${BFILE} \
--keep ${PHENO_COV} \
--maf 0.01 \
--make-bed \
--memory 500000 \
--no-pheno \
--out ./PRS/data/${PRS_DATA_OUTPUT} \
--threads 120