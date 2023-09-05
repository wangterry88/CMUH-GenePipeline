#!/bin/bash
echo ""
echo "This script is to run CMUH Gene Pipeline."
echo ""
echo "Please specify the new Project name:"
echo ""
read NAME
echo ""
PROJECT="$(date +"%Y%m%d_%H%M")"_${NAME}
mkdir ./${PROJECT}
mkdir ./output

#### Step0. Prepare Require Packages ####

Rscript ./script/Prepare/Package_Installation.R

#### Step0. Prepare input data ####

echo "Please specify [Input data mode] or [Perform Gene-Based Pathway Analysis]:"
echo ""
echo "[1] User input  [2] Phencode selection  [3] Gene-Based Pathway Analysis [4] SNP Analysis"
echo ""
echo "[Other] Exit the Program"
read MODE

if [ $MODE -eq 1 ]; then
    echo ""
    echo "########## Using User input list for analysis ###########"
    echo ""
    echo "Please input the list name (Short Name) (Ex: Example.txt):"
    read LIST
    echo ""
    echo "Please Specify the Pipeline you want to do :"
    echo ""
    echo "[1] TPMI Chip Check  [2] GWAS"
    echo "[3] GWAS + PRS       [4] PRS Catalog  [other] Exit the program "
    read WORKTYPE

    if [ $WORKTYPE -eq 1 ]; then
        echo ""
        echo "Data type:  User input list"
        echo ""
        echo "Your selected work is: [1] TPMI Chip Check..."
        echo ""
            Rscript ./script/1.TPMI-ChipCheck/Step1.PatientID_to_TPMI.R
        echo "[1] TPMI Chip Check... Done"
            cp ./input/${LIST} ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[1] Result is in ./Result/${PROJECT}......Bye Bye!"
    

    elif [ $WORKTYPE -eq 2 ]; then
        mkdir ./GWAS
        mkdir ./GWAS/plot
        echo ""
        echo "Data type:  User input list"
        echo ""
        echo "Your selected work is: [2] GWAS..."
        echo ""
            sh ./script/2.GWAS/Run_TPMI_GWAS_Pipeline.sh
        echo "[2] GWAS... Done"
            cp ./input/${LIST} ./${PROJECT}
            mv ./GWAS ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[2] Result is in ./Result/${PROJECT}......Bye Bye!"

    elif [ $WORKTYPE -eq 3 ]; then
        mkdir ./GWAS
        mkdir ./GWAS/plot
        mkdir ./pheno
        mkdir ./PRS
        mkdir ./PRS/data
        mkdir ./PRS/plot
        mkdir ./PRS/result
        echo ""
        echo "Data type:  User input list"
        echo ""
        echo "Your selected work is: [3] GWAS + PRS ..."
        echo ""
            sh ./script/3.GWAS+PRS/Run_TPMI_GWAS_PRS_Pipeline.sh
        echo "[3] GWAS + PRS ... Done"
            cp ./input/${LIST} ./${PROJECT}
            mv ./GWAS ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./pheno ./${PROJECT}
            mv ./PRS ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[3] Result is in ./Result/${PROJECT}......Bye Bye!"

    elif [ $WORKTYPE -eq 4 ]; then
        mkdir ./output/PGS_of_intrested
        echo ""
        echo "Data type:  User input list"
        echo ""
        echo "Your selected work is: [4] PRS Catalog..."
        echo ""
            sh ./script/4.PRSCatalog/Run-TPMI-PRSCatlog-Pipeline.sh
        echo "[4] PRS Catalog ... Done"
            cp ./input/${LIST} ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[4] Result is in ./Result/${PROJECT}......Bye Bye!"    
    fi

elif [ $MODE -eq 2 ]; then
    echo ""
    echo "########## Search with Phencode list ###########"
    echo ""
        sh ./script/0.Phencode/Run_TPMI_Phencode_Pipeline.sh
        echo ""
        echo "Your Phecode selection list is in: ./output/Phencode_selected_list.txt"
    echo ""
    echo "########## Using Phencode list for analysis  ###########"    
    echo ""
    echo "Please Specify the Pipeline you want to do :"
    echo ""
    echo "[1] TPMI Chip Check  [2] GWAS"
    echo "[3] GWAS + PRS       [4] PRS Catalog  [other] Exit the program "
    read WORKTYPE

    if [ $WORKTYPE -eq 1 ]; then
        echo ""
        echo "Data type:  Phencode input list"
        echo ""
        echo "Your selected work is: [1] TPMI Chip Check..."
        echo ""
            Rscript ./script/1.TPMI-ChipCheck/Step1.PatientID_to_TPMI.R
        echo "[1] TPMI Chip Check... Done"
            mv ./output ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[1] Result is in ./Result/${PROJECT}......Bye Bye!"
    
    elif [ $WORKTYPE -eq 2 ]; then
        mkdir ./GWAS
        mkdir ./GWAS/plot
        echo ""
        echo "Data type:  Phencode input list"
        echo ""
        echo "Your selected work is: [2] GWAS..."
        echo ""
            sh ./script/2.GWAS/Run_TPMI_GWAS_Pipeline.sh
        echo "[2] GWAS... Done"
            mv ./GWAS ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[2] Result is in ./Result/${PROJECT}......Bye Bye!"

    elif [ $WORKTYPE -eq 3 ]; then
        mkdir ./GWAS
        mkdir ./GWAS/plot
        mkdir ./pheno
        mkdir ./PRS
        mkdir ./PRS/data
        mkdir ./PRS/plot
        mkdir ./PRS/result
        echo ""
        echo "Data type:  Phencode input list"
        echo ""
        echo "Your selected work is: [3] GWAS + PRS ..."
        echo ""
            sh ./script/3.GWAS+PRS/Run_TPMI_GWAS_PRS_Pipeline.sh
        echo "[3] GWAS + PRS ... Done"
            mv ./GWAS ./${PROJECT}
            mv ./output ./${PROJECT}
            mv ./pheno ./${PROJECT}
            mv ./PRS ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[3] Result is in ./Result/${PROJECT}......Bye Bye!"
        
    elif [ $WORKTYPE -eq 4 ]; then
        mkdir ./output/PGS_of_intrested
        echo ""
        echo "Data type:  Phencode input list"
        echo ""
        echo "Your selected work is: [4] PRS Catalog..."
        echo ""
        echo "Your Phecode list is in: ./output/Select_list.txt"
        echo ""
            sh ./script/4.PRSCatalog/Run-TPMI-PRSCatlog-Pipeline.sh
        echo "[4] PRS Catalog ... Done"
            mv ./output/ ./${PROJECT}
            mv ./${PROJECT} ./Result
        echo "[4] Result is in ./Result/${PROJECT}......Bye Bye!"    
    fi

elif [ $MODE -eq 3 ]; then
    echo ""
    echo "########## Perform Gene-Based Pathway Analysis ###########"
    echo ""
        mkdir ./output/process/
        mkdir ./output/Result/
        sh ./script/5.GeneAnalysis/Run_GWAS_to_Gene_Analysis.sh ${PROJECT}
    echo " Gene-Based Pathway Analysis... Done"
    echo ""
        mv ./output/ ./${PROJECT}
        mv ./${PROJECT} ./Result
    echo "Result is in ./Result/${PROJECT}......Bye Bye!"
    
elif [ $MODE -eq 4 ]; then
    echo ""
    echo "########## Perform SNP Analysis ###########"
    echo ""
         Rscript ./script/6.SNPAnalysis/Step1.GWAS_to_SNPlist.R
         sh ./script/6.SNPAnalysis/Step2.Bfile_to_vcf_table1.sh
    echo " SNP Analysis... Done"
    echo ""
        mv ./output/ ./${PROJECT}
        mv ./${PROJECT} ./Result
    echo "Result is in ./Result/${PROJECT}......Bye Bye!"
else 
    mv ./output/ ./${PROJECT}
    mv ./${PROJECT} ./Result
    echo ""
    echo "Exit the Program......Bye Bye!"
    break
fi