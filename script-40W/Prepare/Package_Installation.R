setwd("./")

######## Install packages ###########

##### data.table ######
if("data.table" %in% rownames(installed.packages()) == FALSE) {
        install.packages("data.table",repos = "http://cran.us.r-project.org")
}

##### dplyr ######
if("dplyr" %in% rownames(installed.packages()) == FALSE) {
        install.packages("dplyr",repos = "http://cran.us.r-project.org")
}

#### ggplot2 ######
if("ggplot2" %in% rownames(installed.packages()) == FALSE) {
	install.packages("ggplot2",repos = "http://cran.us.r-project.org")
}
#### pROC ######
if("pROC" %in% rownames(installed.packages()) == FALSE) {
	install.packages("pROC",repos = "http://cran.us.r-project.org")
}
##### snpStats ######
if("snpStats" %in% rownames(installed.packages()) == FALSE) {
	if (!requireNamespace("BiocManager", quietly = TRUE))
   	install.packages("BiocManager",repos = "http://cran.us.r-project.org")
	BiocManager::install("snpStats")
}
##### qqman ######
if("qqman" %in% rownames(installed.packages()) == FALSE) {
	install.packages("qqman",repos = "http://cran.us.r-project.org")
}

##### MatchIt ######
if("MatchIt" %in% rownames(installed.packages()) == FALSE) {
        install.packages("MatchIt",repos = "http://cran.us.r-project.org")
}

##### broom ######
if("broom" %in% rownames(installed.packages()) == FALSE) {
        install.packages("broom",repos = "http://cran.us.r-project.org")
}

##### gtsummary ######
if("gtsummary" %in% rownames(installed.packages()) == FALSE) {
        install.packages("gtsummary",repos = "http://cran.us.r-project.org")
}
##### transport ######
if("transport" %in% rownames(installed.packages()) == FALSE) {
        install.packages("transport",repos = "http://cran.us.r-project.org")
}
##### survival ######
if("survival" %in% rownames(installed.packages()) == FALSE) {
        install.packages("survival",repos = "http://cran.us.r-project.org")
}
##### casebase ######
if("casebase" %in% rownames(installed.packages()) == FALSE) {
        install.packages("casebase",repos = "http://cran.us.r-project.org")
}
##### tidyverse ######
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {
        install.packages("tidyverse",repos = "http://cran.us.r-project.org")
}
suppressWarnings(suppressMessages(library(data.table)))
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(ggplot2)))
suppressWarnings(suppressMessages(library(pROC)))
suppressWarnings(suppressMessages(library(snpStats)))
suppressWarnings(suppressMessages(library(qqman)))
suppressWarnings(suppressMessages(library(MatchIt)))
suppressWarnings(suppressMessages(library(broom)))
suppressWarnings(suppressMessages(library(gtsummary)))
suppressWarnings(suppressMessages(library(transport)))
suppressWarnings(suppressMessages(library(survival)))
suppressWarnings(suppressMessages(library(casebase)))
suppressWarnings(suppressMessages(library(tidyverse)))

cat('\n')
cat('All Required Packages installed successfully !')
cat('\n')
cat('\n')