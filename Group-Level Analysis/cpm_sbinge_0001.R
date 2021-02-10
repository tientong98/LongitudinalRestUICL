library(dplyr)
library(ppcor)
library(foreach)
library(doParallel)

####################################################################################
##################                  load fcon                   ####################
####################################################################################

fcon <- read.table("/Users/tientong/rest/flat_subtract.txt", header = T)

####################################################################################
##################           load behavioral data              #####################
####################################################################################

finaldfex <- readRDS("/Users/tientong/rest/finaldfex_final.RDS")
subject <- unique(finaldfex$id)

finaldfex_time1 <- finaldfex %>% filter(ses_ord==0)
finaldfex_time2 <- finaldfex %>% filter(ses_ord==1)

behav <- finaldfex_time2[,c("id","group", "sex", "V1_ParentSES.num", 
                            "sum.sbinge.log", "sum.ebinge.log")]
behav$age_diff <- finaldfex_time2$age - finaldfex_time1$age
behav$fd_diff <- finaldfex_time2$fd - finaldfex_time1$fd
behav$scanner_change <- as.factor(
  ifelse(finaldfex_time2$scanner_info == finaldfex_time1$scanner_info, "same", "diff"))

####################################################################################
####################           load CPM functions              #####################
####################################################################################

source("/Users/tientong/rest/cpm_functions.R")

####################################################################################
#################################   Run CPM   ######################################
####################################################################################

cpm_results_sbinge <- cpm(fcon_df = fcon, behav_df = behav, behav_measure = "sum.sbinge.log",
                          threshold = .0001, total_roi = 300, cor.type="spearman",
                          confound = c("group", "sex", "V1_ParentSES.num", "scanner_change",
                                       "age_diff","fd_diff"))
saveRDS(cpm_results_sbinge, "/Users/tientong/rest/sbinge_0001.RDS")
