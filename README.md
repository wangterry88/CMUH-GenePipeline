# GenePipeline

A comprehensive Linux-based package for SNP array analysis

## Version

- **30W version**: 300,000 samples pipeline
- **40W version**: 400,000 samples pipeline

## Demo

For a demo of the pipeline, refer to `Demo.md`.

## Running the Main Pipeline

To run the main pipeline, execute the following command:

```sh
sh ./script/Run_GenePipeline.sh
```
## Gene Analysis Modes

This package supports 6 gene analysis modes. The following sub-pipelines can also be executed separately:

### Phencode Patient Phenotype Selection

```sh
sh ./script/0.Phencode/Run_TPMI_Phencode_Pipeline.sh
```
### Mode 1: TPMI Array Chip Check

```sh
Rscript ./script/1.TPMI-ChipCheck/Step1.PatientID_to_TPMI.R
```

### Mode 2: GWAS Analysis

```sh
sh ./script/2.GWAS/Run_TPMI_GWAS_Pipeline.sh
```

### Mode 3: GWAS and PRS Analysis

```sh
sh ./script/3.GWAS+PRS/Run_TPMI_GWAS_PRS_Pipeline.sh
```


### Mode 4: PGS Catalog Calculation

```sh
sh ./script/4.PRSCatalog/Run-TPMI-PRSCatlog-Pipeline.sh
```

### Mode 5: Gene-Pathway Analysis

```sh
sh ./script/5.GeneAnalysis/Run_GWAS_to_Gene_Analysis.sh
```

### Mode 6: SNP Analysis

```sh
Rscript ./script/6.SNPAnalysis/Step1.GWAS_to_SNPlist.R
sh ./script/6.SNPAnalysis/Step2.Bfile_to_vcf_table1.sh
```
