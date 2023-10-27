setwd("./")
#############

cat(prompt="Input PRS results (Full directory): ")
cat('Ex: ./PRS/result/test.best')
cat('\n')
PRS_RESULT<-readLines(con="stdin",1)

cat(prompt="Input PRS Phenotype data (Full directory): ")
cat('\n')
PHENO<-readLines(con="stdin",1)

cat(prompt="Output PRS plot file name (Short Name): ")
cat('\n')
PLOT_OUT<-readLines(con="stdin",1)


############# Required Packages ###############

library(data.table)
library(dplyr)
library(ggplot2)
library(pROC)
library(broom)
library(gtsummary)
library(MatchIt)
library(transport)
library(survival)
library(casebase)

#############################

PRS.result.prsice<-fread(PRS_RESULT)
CMUH.pheno<-fread(PHENO,sep="\t",header=T)
PCA<-fread("./data/PCA/TPMI_40W_PC1-4.txt",sep="\t",header=T)


head(PRS.result.prsice)
head(CMUH.pheno)

Prsice.pheno<-inner_join(PRS.result.prsice,CMUH.pheno,by=c("FID"="FID","IID"="IID"))
Prsice.pheno<-na.omit(Prsice.pheno)

# Prepare Plot data
Prsice.pheno.plot<-Prsice.pheno[,c("FID","IID","PRS","Sex","Age","Pheno")]
Prsice.pheno.plot$Sex<-recode_factor(Prsice.pheno.plot$Sex,"1"="Male","2"="Female")
Prsice.pheno.plot$Pheno<-recode_factor(Prsice.pheno.plot$Pheno,"1"="Control","2"="Case")

# Prepare model data

Prsice.pheno.model<-Prsice.pheno[,c("FID","IID","PRS","Sex","Age","Pheno")]
Prsice.pheno.model$Sex<-as.factor(Prsice.pheno.model$Sex)
Prsice.pheno.model$Pheno<-as.factor(Prsice.pheno.model$Pheno)

# Ready plot data

PRS.pheno.plot<-Prsice.pheno.plot
colnames(PRS.pheno.plot)<-c("FID","IID","SCORE","Sex","Age","Pheno")

# Plot data prepare

PRS.pheno.plot$percentile<-ntile(PRS.pheno.plot$SCORE,10)

# Plot data output

tmp.PRS.pheno.plot<-paste0('./PRS/plot/',PLOT_OUT,'.plot-data.txt',collapse = '')
fwrite(PRS.pheno.plot,tmp.PRS.pheno.plot,sep="\t",col.names=T)


# Plot info

PRS.pheno.high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==10)
PRS.pheno.low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile==1)

high10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="10")
high10_line<-min(high10$SCORE)

low10<-subset(PRS.pheno.plot,PRS.pheno.plot$percentile=="1")
low10_line<-max(low10$SCORE)

PRS.pheno.plot$percentile<-as.factor(PRS.pheno.plot$percentile)
 
### Plotting Coefficients on Odds Scale ###

# Fit regression model
prs_glm <- glm(Pheno ~ percentile,data = PRS.pheno.plot,family = 'binomial')

# Put results in data.frame
summs <- prs_glm %>% summary()

# Get point estimates and SEs
results <- bind_cols(coef(prs_glm),summs$coefficients[, 2]) %>%
    setNames(c("estimate", "se"))  %>%
    mutate(percentile = 1:10)

# Your coefficients are on the log odds scale, such that a coefficient is
# log(odds_y==1 / odds_y == 0). We can exponentiate to get odds instead.
results_odds <- results %>% mutate(across(.cols = -percentile,
                                          ~ exp(.x)))

# Need SEs on the odds scale too
results_odds <- results_odds %>%
  mutate(var_diag = diag(vcov(prs_glm)),
         se = sqrt(estimate ^ 2 * var_diag))

# Plot with +/- 1 SE

tmp_or_plot<-paste0('./PRS/plot/',PLOT_OUT,'.OR-Plot.png',collapse = '')

#png(tmp_or_plot,height = 500,width  = 500)

or_plot=ggplot(results_odds, aes(x = as.factor(percentile), y = estimate, color)) +
        geom_point(stat = "identity", size=3,color = "black") +
        geom_hline(yintercept = 1, linetype = "dashed", color = "grey") +
        geom_errorbar(aes(ymin = estimate - se, ymax = estimate + se), width = 0.4) +
        ggtitle("Odds Ratio in 1st to 10th PRS score") +
        xlab("PRS Decile") +
        ylab("Odds")

ggsave(or_plot,file=tmp_or_plot,height = 8,width  = 8)

### Distribution plot ###

tmp_dist_plot<-paste0('./PRS/plot/',PLOT_OUT,'.distribution.png',collapse = '')

#png(tmp_dist_plot,height = 500,width  = 500)

dist_plot=ggplot(PRS.pheno.plot, aes(x=SCORE, fill=Pheno)) +
        geom_vline(aes(xintercept=high10_line), colour="#BB0000", linetype="dashed")+
        geom_vline(aes(xintercept=low10_line), colour="#BB0000", linetype="dashed")+
        geom_text(aes(x = high10_line,y=0.4,label = "High 10% PRS"))+
        geom_text(aes(x = low10_line,y=0.4,label = "Low 10% PRS"))+
        geom_density(alpha=0.4, position = 'identity',bins=50)
ggsave(dist_plot,file=tmp_dist_plot,height = 8,width  = 8)

### Quantiles plot ###

tmp_quant_plot<-paste0('./PRS/plot/',PLOT_OUT,'.quantiles.png',collapse = '')

#png(tmp_quant_plot,height = 500,width  = 500)

quant_plot=PRS.pheno.plot %>%
        count(percentile, Pheno) %>%       
        group_by(percentile) %>%
        mutate(pct= prop.table(n) * 100) %>%
        ggplot() + aes(percentile, pct, fill=Pheno) +
        geom_bar(stat="identity") +
        ylab("Ratio of Case/Control") +
        geom_text(aes(label=paste0(sprintf("%1.1f", pct),"%")),
            position=position_stack(vjust=0.5)) +
        ggtitle("PRS in 1st to 10th distribution") +
        scale_fill_manual(values = c("#00BFC4", "#F8766D")) +
        theme_bw()
ggsave(quant_plot,file=tmp_quant_plot,height = 8,width  = 8)

########## Two sample T test: Case and control ########## 

  case<-subset(PRS.pheno.plot,PRS.pheno.plot$Pheno=="Case")
  ctrl<-subset(PRS.pheno.plot,PRS.pheno.plot$Pheno=="Control")

# Two sample T-test
  t.test.result<-tidy(t.test(case$SCORE,ctrl$SCORE))
  cat('\nP-value of PRS Case/Control distribution T-test is:',t.test.result$p.value)
  cat('\n')
  cat('\n')
  tmp_t_test<-paste0('./PRS/plot/',PLOT_OUT,'.T-test.txt',collapse = '')
  fwrite(t.test.result,tmp_t_test,sep="\t",col.names = T)

# Wilcoxon Whitney U test , specify alternative="less"
  u.test.result<-tidy(wilcox.test(case$SCORE,ctrl$SCORE,alternative = "two.sided", paired = FALSE, exact = FALSE, correct = TRUE))
  cat('\nP-value of PRS Case/Control distribution U-test is:',u.test.result$p.value)
  cat('\n')
  cat('\n')
  tmp_u_test<-paste0('./PRS/plot/',PLOT_OUT,'.U-test.txt',collapse = '')
  fwrite(u.test.result,tmp_u_test,sep="\t",col.names = T)

# Wasserstein distence test
cat('\n')
cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE))
cat('\n')
tmp_Wass_test<-paste0('./PRS/plot/',PLOT_OUT,'.Wasserstein-test.txt',collapse = '')
cat('Wasserstein distance is:',wasserstein1d(case$SCORE,ctrl$SCORE),sep = "\t", file = tmp_Wass_test)
  

################# Table 1 of PRS Sample in GLM model (Dropped NAs) #################

  cat('##### Table 1 of PRS Sample in GLM model (Dropped NAs) #####')
  cat('\n')
  cat('\n')

  table_PRS=PRS.pheno.plot
  cov = c('Pheno','Sex','Age')
  
  table_PRS_print <- table_PRS %>% select(cov)

  tmp_PRS_table1<-paste0('./PRS/plot/',PLOT_OUT,'.table1.html',collapse = '')
  
  table1 <- 
    tbl_summary(
      table_PRS_print,
      by = Pheno, # split table by group
      missing = "no" # don't list missing data separately
    ) %>%
    add_n() %>% # add column with total number of non-missing observations
    add_p() %>% # test for a difference between groups
    modify_header(label = "**Covarites**") %>% # update the column header
    bold_labels() 

  table1%>%
    as_gt() %>%
    gt::gtsave(filename = tmp_PRS_table1)
    
  cat('\n')
  cat('\nPRS Pheno table1 is in:',tmp_PRS_table1)
  cat('\n')
  cat('\n')

# Ready GLM PRS Model Data

PRS.pheno.model=Prsice.pheno.model

PRS.pheno.model<-inner_join(PRS.pheno.model,PCA,by=c("IID"="IID"))

colnames(PRS.pheno.model)<-c("FID","IID","SCORE","Sex","Age","Pheno","PC1","PC2","PC3","PC4")

##### 80% of the sample size #### 

smp_size <- floor(0.8 * nrow(PRS.pheno.model))

## set the seed to make your partition reproducible
set.seed(123)
train_ind <- sample(seq_len(nrow(PRS.pheno.model)), size = smp_size)

##### Train data #####
PRS.train.pheno <- PRS.pheno.model[train_ind, ]

##### Test data #####
PRS.test.pheno <- PRS.pheno.model[-train_ind, ]

##### Train Test data output #####

tmp.tarin.data<-paste0('./PRS/plot/',PLOT_OUT,'.AUC.train-data.txt',collapse = '')
fwrite(PRS.train.pheno,tmp.tarin.data,sep="\t",col.names=T)

tmp.test.data<-paste0('./PRS/plot/',PLOT_OUT,'.AUC.test-data.txt',collapse = '')
fwrite(PRS.test.pheno,tmp.test.data,sep="\t",col.names=T)


# Read GLM PRS Model Data

mod_1 <- glm( Pheno ~ SCORE, data=PRS.train.pheno, family="binomial")
mod_2 <- glm( Pheno ~ SCORE+Age+Sex, data=PRS.train.pheno, family="binomial")
mod_3 <- glm( Pheno ~ SCORE+Age+Sex+PC1+PC2+PC3+PC4, data=PRS.train.pheno, family="binomial")


##################################### Model 1 (Base only) #####################################

  library(pROC)

  ## Train
  train_1_prob = predict(mod_1, data=PRS.train.pheno ,type='response')
  train_1_roc = roc(PRS.train.pheno$Pheno ~ train_1_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)
  
  ## Test
  test_1_prob = predict(mod_1, newdata = PRS.test.pheno, type = "response")
  test_1_roc = roc(PRS.test.pheno$Pheno ~ test_1_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)


##################################### Model 2 (PRS only) #####################################

  ## Train
  train_2_prob = predict(mod_2, data=PRS.train.pheno ,type='response')
  train_2_roc = roc(PRS.train.pheno$Pheno ~ train_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)
  
  ## Test
  test_2_prob = predict(mod_2, newdata = PRS.test.pheno, type = "response")
  test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

##################################### Model 3 (Full model) #####################################


  ## Train
  train_3_prob = predict(mod_3, data=PRS.train.pheno ,type='response')
  train_3_roc = roc(PRS.train.pheno$Pheno ~ train_3_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)
  
  ## Test
  test_3_prob = predict(mod_3, newdata = PRS.test.pheno, type = "response")
  test_3_roc = roc(PRS.test.pheno$Pheno ~ test_3_prob, plot = FALSE, print.auc = TRUE, legacy.axes=TRUE)

######################## AUC plot Table ################################

## Table Output

#### Table 1 ######

  out_a_1=coords(test_1_roc, "best", ret = c("auc","threshold", "specificity", "sensitivity", "accuracy","precision", "recall"), transpose = FALSE, print.auc = TRUE)

  #Get the first row to prevent error of 1 rows of metrics
  out_a_1=out_a_1[1,]
  out_b_1=as.data.frame(auc(test_1_roc))

  colnames(out_b_1)<-"AUC"
  out_final_1<-cbind(out_a_1,out_b_1)

  out_final_1$Model<-c("PRS model")


#### Table 2 ######

  out_a_2=coords(test_2_roc, "best", ret = c("auc","threshold", "specificity", "sensitivity", "accuracy","precision", "recall"), transpose = FALSE, print.auc = TRUE)

  #Get the first row to prevent error of 2 rows of metrics
  out_a_2=out_a_2[1,]
  out_b_2=as.data.frame(auc(test_2_roc))

  colnames(out_b_2)<-"AUC"
  out_final_2<-cbind(out_a_2,out_b_2)

  out_final_2$Model<-c("PRS + Age + Sex")

#### Table 3 ######

  out_a_3=coords(test_3_roc, "best", ret = c("auc","threshold", "specificity", "sensitivity", "accuracy","precision", "recall"), transpose = FALSE, print.auc = TRUE)

  #Get the first row to prevent error of 3 rows of metrics
  out_a_3=out_a_3[1,]
  out_b_3=as.data.frame(auc(test_3_roc))

  colnames(out_b_3)<-"AUC"
  out_final_3<-cbind(out_a_3,out_b_3)

  out_final_3$Model<-c("Full model (PRS + Age + Sex + PCs)")

########################

  out_final<-rbind(out_final_1,out_final_2,out_final_3)
  
  out_final<-out_final[,c(8,7,2:6,1)]
  head(out_final)

  tmp_out<-paste0('./PRS/plot/',PLOT_OUT,'.AUCs.Performance.txt',collapse = '')
  
  fwrite(out_final,tmp_out,sep="\t",col.names = T)


### Model plot ###

tmp_model_plot<-paste0('./PRS/plot/',PLOT_OUT,'.AUCs.png',collapse = '')

png(tmp_model_plot,height = 500,width  = 500)

test_1_roc = roc(PRS.test.pheno$Pheno ~ test_1_prob)
test_2_roc = roc(PRS.test.pheno$Pheno ~ test_2_prob)
test_3_roc = roc(PRS.test.pheno$Pheno ~ test_3_prob)

plot(test_1_roc,print.auc = TRUE, print.auc.y = .4)
plot(test_2_roc,print.auc = TRUE, print.auc.y = .3 , col='red' ,add=TRUE)
plot(test_3_roc,print.auc = TRUE, print.auc.y = .2 , col='blue',add=TRUE)

text(0.15, .4, paste("PRS model"))
text(0.15, .3, paste("PRS + Age + Sex"))
text(0.15, .2, paste("PRS + Age + Sex + PCs"))

cat('\n')
cat('\nAUC of PRS Model is:', auc(test_1_roc))
cat('\n')
cat('\nAUC of PRS + Age + Sex Model is:', auc(test_2_roc))
cat('\n')
cat('\nAUC of Full Model is:', auc(test_3_roc))
cat('\n')
dev.off()

######################## Prevalence plot and Table ################################

Prevalence.plot<-PRS.pheno.plot
Prevalence.plot$Pheno<-recode_factor(Prevalence.plot$Pheno,"Control"="0","Case"="1")
Prevalence.plot$Pheno<-as.numeric(as.character(Prevalence.plot$Pheno))
Prevalence.plot$percentile<-as.factor(Prevalence.plot$percentile)
Prevalence.plot$PrevalenceGroup<-ntile(Prevalence.plot$SCORE,100)

PrevalencePlot_data<-Prevalence.plot %>% 
group_by(PrevalenceGroup) %>% 
summarise(Prevalence = sum(Pheno)/n())

tmp_PrevalencePlot_data<-paste0('./PRS/plot/',PLOT_OUT,'.Prevalence-data.txt')
fwrite(PrevalencePlot_data,tmp_PrevalencePlot_data,sep="\t",col.names = T)


tmp_Prevalence_plot<-paste0('./PRS/plot/',PLOT_OUT,'.Prevalence.png')
      
Prevalence_plot<-ggplot(PrevalencePlot_data, aes(x=PrevalenceGroup, y=Prevalence)) + 
labs( x = "Percentile of PRS", y = "Prevalence",title ="Prevalence of Disease")+
geom_point()

ggsave(Prevalence_plot,file=tmp_Prevalence_plot,height = 8,width  = 8)

######################## Cumulative Risk plot and Table ################################

Cumulative.plot<-PRS.pheno.plot
Cumulative.plot$Pheno<-recode_factor(Cumulative.plot$Pheno,"Control"="0","Case"="1")
Cumulative.plot$Pheno<-as.numeric(as.character(Cumulative.plot$Pheno))
Cumulative.plot$percentile<-as.factor(Cumulative.plot$percentile)
Cumulative.plot$PrevalenceGroup<-ntile(Cumulative.plot$SCORE,100)

Cumulative.plot<-Cumulative.plot[order(Cumulative.plot$SCORE),]
Cumulative.plot$Index<-1:nrow(Cumulative.plot)
cumplot_glm <- fitSmoothHazard(Pheno ~ Age+SCORE,data = Cumulative.plot, time = "Age", ratio = 10)

#summary(cumplot_glm)

group_25<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="25")
group_50<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="50")
group_75<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="75")
group_100<-subset(Cumulative.plot,Cumulative.plot$PrevalenceGroup=="100")

sample_25<-min(group_25$Index)
sample_50<-min(group_50$Index)
sample_75<-min(group_75$Index)
sample_100<-min(group_100$Index)

smooth_risk_model <- absoluteRisk(object = cumplot_glm, newdata = Cumulative.plot[c(sample_25,sample_50,sample_75,sample_100),])

risk_data<-as.data.frame(smooth_risk_model)
colnames(risk_data)<-c("Age-Time","PRS-25%","PRS-50%","PRS-75%","PRS-100%")

tmp_risk_data<-paste0('./PRS/plot/',PLOT_OUT,'.Cumulative_Risk-data.txt')
fwrite(risk_data,tmp_risk_data,sep="\t",col.names = T,row.names=F)

tmp_risk_plot<-paste0('./PRS/plot/',PLOT_OUT,'.Cumulative_Risk.png')

smooth_risk <- absoluteRisk(object = cumplot_glm, newdata = Cumulative.plot[c(sample_25,sample_50,sample_75,sample_100),])

png(tmp_risk_plot,height = 800,width  = 800)
fullplot<-plot(smooth_risk,
      id.names = c("PRS 25%","PRS 50%","PRS 75%","PRS 100%"), 
      legend.title = "PRS", 
      xlab = "Age (Years Old)", 
      ylab = "Cumulative Incidence (%)")
print(fullplot)
dev.off()