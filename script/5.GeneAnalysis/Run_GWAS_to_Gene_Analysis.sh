#!/bin/bash
echo "This script is to run Gene Analysis."
echo ""
echo "Please specify the GWAS result file: (Full directory)"
echo ""
echo "Ex: ./input/Test_GWAS_data.logistic"
echo ""
IFS= read -r GWAS_PATH
echo ""

PROJECT="$@"
GWAS_NAME=${PROJECT}

mkdir ./output/process/${GWAS_NAME}
mkdir ./output/Result/${GWAS_NAME}

awk 'NR>1 {print "chr"$1":"$2"\t"$1"\t"$2}' "${GWAS_PATH}" > ./output/process/${GWAS_NAME}/${GWAS_NAME}.location.txt

awk '{print "chr"$1":"$2"\t"$15"\t"$9}' "${GWAS_PATH}"|sed 's/chr#CHROM:POS/SNP/g' > ./output/process/${GWAS_NAME}/${GWAS_NAME}.Pvalue.txt

# Annotation

./tools/magma \
--snp-loc ./output/process/${GWAS_NAME}/${GWAS_NAME}.location.txt \
--annotate window=35,10 \
--gene-loc ./data/GeneAnalysis/Location/NCBI38.gene.loc \
--out ./output/Result/${GWAS_NAME}/${GWAS_NAME}.annotation

# Gene analysis

./tools/magma \
--bfile ./data/GeneAnalysis/Reference/East_Asian_hg38 \
--pval ./output/process/${GWAS_NAME}/${GWAS_NAME}.Pvalue.txt ncol=OBS_CT \
--gene-annot ./output/Result/${GWAS_NAME}/${GWAS_NAME}.annotation.genes.annot \
--gene-model snp-wise=mean \
--out ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Gene.result

# Pathway Analysis

./tools/magma \
--gene-results ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Gene.result.genes.raw \
--set-annot ./data/GeneAnalysis/pathway/v2023.1/msigdb.v2023.1.Hs.symbols.gmt \
--out ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Pathway

# Make Pathway result

awk 'NR>4 {print $8"\t"$7"\t"$3"\t"$4"\t"$5"\t"$6}' ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Pathway.gsa.out > ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Pathway.result.txt


# Make Pathway plot

Rscript ./script/5.GeneAnalysis/Step1.Pathway_plot.R ${GWAS_NAME}

# Make Gene Pathway adjust result

Rscript ./script/5.GeneAnalysis/Step2.Gene_Pathway_adjust.R ${GWAS_NAME}