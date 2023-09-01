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
mkdir ./output/Result/${GWAS_NAME}/Pathways/

# Make location file

awk 'NR>1 {print "chr"$1":"$2"\t"$1"\t"$2}' "${GWAS_PATH}" > ./output/process/${GWAS_NAME}/${GWAS_NAME}.location.txt

# Make P-value file

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

# Select the Geneset for analysis

for PATHWAY_SELECT in $(seq 0 1 9);
do 
  case "${PATHWAY_SELECT}" in
      0)
        PATHWAY_FILE="msigdb.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [All gene sets]"
        ;;
      1)
        PATHWAY_FILE="c1.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C1: positional gene sets]"
        ;;
      2)
        PATHWAY_FILE="c2.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C2: curated gene sets]"
        ;;
      3)
        PATHWAY_FILE="c3.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C3: regulatory target gene sets]"
        ;;
      4)
        PATHWAY_FILE="c4.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C4: computational gene sets]"
        ;;
      5)
        PATHWAY_FILE="c5.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C5: ontology gene sets]"
        ;;
      6)
        PATHWAY_FILE="c6.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C6: oncogenic signature gene sets]"
        ;;
      7)
        PATHWAY_FILE="c7.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C7: immunologic signature gene sets]"
        ;;
      8)
        PATHWAY_FILE="c8.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [C8: cell type signature gene sets]"
        ;;
      9)
        PATHWAY_FILE="h.all.v2023.1.Hs.symbols.gmt"
        echo "Your selected pathway is: [H: hallmark gene sets]"
        ;;
      *)
        PATHWAY_FILE="msigdb.v2023.1.Hs.symbols.gmt"
        echo "Please input [0 ~ 9] to select Gene set file"
        echo "Use default pathway: [All gene sets]"
        ;;
  esac

  mkdir ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}
  mkdir ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/Network

  # Pathway Analysis

  ./tools/magma \
  --gene-results ./output/Result/${GWAS_NAME}/${GWAS_NAME}.Gene.result.genes.raw \
  --set-annot ./data/GeneAnalysis/pathway/v2023.1/${PATHWAY_FILE} \
  --out ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${PATHWAY_FILE}.Pathway

  # Make Pathway result

  #### Abnormal process for c1,c4 #####

  if [ "${PATHWAY_SELECT}" -eq 1 ]; then
    awk 'NR>4 {print $1"\t"$7"\t"$3"\t"$4"\t"$5"\t"$6}' ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${PATHWAY_FILE}.Pathway.gsa.out > ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${GWAS_NAME}.Pathway.result.txt
  
  elif [ "${PATHWAY_SELECT}" -eq 4 ]; then
    awk 'NR>4 {print $1"\t"$7"\t"$3"\t"$4"\t"$5"\t"$6}' ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${PATHWAY_FILE}.Pathway.gsa.out > ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${GWAS_NAME}.Pathway.result.txt
  else
    #### Normal process #####
    awk 'NR>4 {print $8"\t"$7"\t"$3"\t"$4"\t"$5"\t"$6}' ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${PATHWAY_FILE}.Pathway.gsa.out > ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/${GWAS_NAME}.Pathway.result.txt
  fi

  # Make Pathway plot

  Rscript ./script/5.GeneAnalysis/Step1.Pathway_plot.R ${GWAS_NAME} ${PATHWAY_FILE}

  # Make Gene Pathway adjust result

  Rscript ./script/5.GeneAnalysis/Step2.Gene_Pathway_adjust.R ${GWAS_NAME} ${PATHWAY_FILE}

  # Make gmt data to network plot data

  cp ./data/GeneAnalysis/pathway/v2023.1/${PATHWAY_FILE} ./output/Result/${GWAS_NAME}/Pathways/${PATHWAY_FILE}/Network/${PATHWAY_FILE}

done