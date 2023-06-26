#!/bin/bash
echo ""
echo "This script is to run PRS Catalog analysis."
echo ""
echo "############# Step1: Perform PatientID to PGS Catlog.... ###########"
echo ""
Rscript ./script/4.PRSCatalog/Step1.PatientID_to_PGScatlog.R
echo ""
echo "############# Step2: PGS Data Caculation. ###########"
echo ""
Rscript ./script/4.PRSCatalog/Step2.PGS_Data_Caculation.R
echo ""
echo "############# Step3: PGS Information Output. ###########"
echo ""
Rscript ./script/4.PRSCatalog/Step3.Check_PGS_SNPs.R
echo ""
echo "#################################### Done #####################################"