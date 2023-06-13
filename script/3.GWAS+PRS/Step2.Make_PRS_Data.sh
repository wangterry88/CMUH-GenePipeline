#!/bin/bash

echo "Enter the PRS phenotype file (Full directory): "
read PHENO_COV  

echo "Output name of the PRS bfile data (Short Name): "
read PRS_DATA_OUTPUT

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

#BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_RAW/TPMI_29W_RAW_clean
#BFILE=/media/volume1/bioinfo/TPMI_Array/TPMI_29W_imputed/clean/TPMI_29W_imputed_clean

./tools/plink2 \
--bfile ${BFILE} \
--keep ${PHENO_COV} \
--make-bed \
--memory 500000 \
--no-pheno \
--out ./PRS/data/${PRS_DATA_OUTPUT} \
--threads 120