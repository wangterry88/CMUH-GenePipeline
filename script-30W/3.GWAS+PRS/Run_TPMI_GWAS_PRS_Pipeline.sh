#!/bin/bash
echo ""
echo "This script is to run TPMI GWAS and PRS analysis."
echo ""
echo "############# Step1: Perform TPMI Chip Mapping.... ###########"
echo ""
Rscript ./script/3.GWAS+PRS/Step1.PatientID_to_GWAS_PRS_list.R
echo ""
echo "############# Step2: Make PRS Data.... ###########"
echo ""
sh ./script/3.GWAS+PRS/Step2.Make_PRS_Data.sh
echo ""
echo "############# Step3: Perform GWAS Anaysis.... ###########"
echo ""
bash ./script/3.GWAS+PRS/Step3.GWAS.sh
echo ""
echo "############# Step4: Plot the GWAS Manhattan QQ Plot + PRS Base data.... ###########"
echo ""
Rscript ./script/3.GWAS+PRS/Step4.Manhattan_QQ_Plot_PRSsumstat.R
echo ""
echo "############# Step5: Perform SNP to Gene annotation.... ###########"
echo ""
sh ./script/3.GWAS+PRS/Step5.SNP_to_Gene.sh
echo ""
echo "############# Step6: Plot the Gene Manhattan Plot.... ###########"
echo ""
Rscript ./script/3.GWAS+PRS/Step6.Gene_Manhattan.R
echo ""
echo "############# Step7: Perform PRS Anaysis.... ###########"
echo ""
sh ./script/3.GWAS+PRS/Step7.PRS.sh
echo ""
echo "############# Step8: Plot the PRS results.... ###########"
echo ""
Rscript ./script/3.GWAS+PRS/Step8.PRS_plot.R
echo ""
echo "#################### Done ###############################"