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
##### transport ######
if("survival" %in% rownames(installed.packages()) == FALSE) {
        install.packages("survival",repos = "http://cran.us.r-project.org")
}
##### transport ######
if("casebase" %in% rownames(installed.packages()) == FALSE) {
        install.packages("casebase",repos = "http://cran.us.r-project.org")
}
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {
        install.packages("tidyverse",repos = "http://cran.us.r-project.org")
}

library(data.table)
library(dplyr)
library(ggplot2)
library(snpStats)
library(qqman)
library(MatchIt)
library(broom)
library(gtsummary)
library(transport)
library(survival)
library(casebase)
library(tidyverse)