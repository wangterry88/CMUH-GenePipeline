#!/bin/bash
echo ""
echo "This script is to run CMUH Phencode selection."
echo ""

echo "Please specify the Selection mode:"
echo "[1]ICD mode  [2]Phencode Name mode  [Default]ICD mode"
read MODE

if [ $MODE -eq 1 ]; then
    
    echo "############# Step1-1: Perform ICD selection.... ###########"
    echo ""
    Rscript ./script/0.Phencode/Step1-1.ICD_Selection.R
    echo ""
    echo "############# Step1-2: Perform CMUH Phencode selection.... ###########"
    echo ""
    Rscript ./script/0.Phencode/Step1-2.Phencode_Selection.R
    echo ""
    echo "#################################### Done #####################################"
elif [ $MODE -eq 2 ]; then
    
    echo "############# Step1-2: Perform CMUH Phencode selection.... ###########"
    echo ""
    Rscript ./script/0.Phencode/Step1-2.Phencode_Selection.R
    echo ""
    echo "#################################### Done #####################################"
else 
    echo "############# Step1-1: Perform ICD selection.... ###########"
    echo ""
    Rscript ./script/0.Phencode/Step1-1.ICD_Selection.R
    echo ""
    echo "############# Step1-2: Perform CMUH Phencode selection.... ###########"
    echo ""
    Rscript ./script/0.Phencode/Step1-2.Phencode_Selection.R
    echo ""
    echo "#################################### Done #####################################"
fi