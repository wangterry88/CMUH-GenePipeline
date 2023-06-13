#!/bin/bash
echo ""
echo "This script is to run TPMI mapping and perform GWAS analysis."
echo ""
echo "############# Step1: Perform TPMI Chip Mapping.... ###########"
echo ""
Rscript ./script/2.GWAS/Step1.PatientID_to_TPMI.R
echo ""
echo "############# Step2: Perform GWAS Anaysis.... ###########"
echo ""
bash ./script/2.GWAS/Step2.GWAS.sh
echo ""
echo "############# Step3: Plot the GWAS Manhattan QQ Plot.... ###########"
echo ""
Rscript ./script/2.GWAS/Step3.Manhattan_QQ_Plot_PRSsumstat.R
echo ""
echo "############# Step4: Mapping GWAS Results to Genes.... ###########"
echo ""
sh ./script/2.GWAS/Step4.SNP_to_Gene.sh
echo ""
echo "############# Step5: Plot the Gene Manhattan Plot.... ###########"
echo ""
Rscript ./script/2.GWAS/Step5.Gene_Manhattan.R
echo ""
echo "#################################### Done #####################################"
