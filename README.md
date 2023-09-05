## GenePipeline

1. A comprehensive Linux-based package for SNP array analysis

2. Demo of Pipeline is in `Demo.md`

3. Version: 30W version (300,000 samples pipeline) / 40W version (400,000 samples pipeline)
  
## To run this package: (Main pipeline)

`sh ./script/Run_GenePipeline.sh`

### 5 Gene Analysis mode of this package

The following sub-pipline can also be execute separately:

0. Phencode Patient Phenotype selection

`sh ./script/0.Phencode/Run_TPMI_Phencode_Pipeline.sh`

1. TPMI Array Chip Check

`Rscript ./script/1.TPMI-ChipCheck/Step1.PatientID_to_TPMI.R`

2. GWAS Analysis

`sh ./script/2.GWAS/Run_TPMI_GWAS_Pipeline.sh`

3. GWAS and PRS Analysis

`sh ./script/3.GWAS+PRS/Run_TPMI_GWAS_PRS_Pipeline.sh`

4. PGS Catalog Calculation

`sh ./script/4.PRSCatalog/Run-TPMI-PRSCatlog-Pipeline.sh`

5. Gene-Pathway Analysis

`sh ./script/5.GeneAnalysis/Run_GWAS_to_Gene_Analysis.sh`

6. SNP Analysis

`Rscript ./script/6.SNPAnalysis/Step1.GWAS_to_SNPlist.R`
`sh ./script/6.SNPAnalysis/Step2.Bfile_to_vcf_table1.sh`
