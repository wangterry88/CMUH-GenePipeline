#!/bin/bash

echo "Enter the SNP file (Full directory)(CHR SNP BP): "
echo "Ex: ./GWAS/test.PRS.Sig-0.05.txt"
read INPUT 

echo "Enter the SNP file name(Short name): "
read OUT_FILE 

./tools/plink \
--annotate $INPUT prune minimal ranges=./tools/annotation_file/glist-hg38 \
--out ./GWAS/$OUT_FILE.txt




