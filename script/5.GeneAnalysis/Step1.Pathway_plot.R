setwd("./")

library(data.table)
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
GWAS_name <-args[1]

result_tmp<-paste0('./output/Result/',GWAS_name,'/',GWAS_name,'.Pathway.result.txt')

result<-fread(result_tmp,sep="\t")

# Get plot data
result_sort<-result[order(result$P),]

# First 30 results
result_plot<-result_sort[1:30,]

result_plot$`-log10P` <- 0 - log10(result_plot$P)
result_plot$FULL_NAME<-as.factor(result_plot$FULL_NAME)

# Plot output

tmp_plot<-paste0('./output/Result/',GWAS_name,'/',GWAS_name,'.Pathway.result.plot.png',collapse = '')

plot=result_plot %>% 
  ggplot(aes(reorder(FULL_NAME, `-log10P`), `-log10P`)) + 
  geom_col(aes(fill = `-log10P`)) + geom_hline(yintercept = -log10(0.05))+
  scale_fill_gradient2(low = "pink", high = "brown", midpoint = median(result_plot$`-log10P`)) + coord_flip() + 
  labs(x = "Pathway name")+
    theme(axis.text.x = element_text(face="bold",size=10, angle=0),
          axis.text.y = element_text(face="bold",size=10, angle=0))
ggsave(plot,file=tmp_plot,height = 8,width  = 16)
