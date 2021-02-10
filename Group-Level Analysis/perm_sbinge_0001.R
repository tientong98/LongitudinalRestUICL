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
#########################   Run CPM on permuted data  ##############################
####################################################################################

set.seed(101) ## for reproducibility
nsim <- 500

cores <- detectCores()
cl <- makeCluster(cores[1]-1)
registerDoParallel(cl)

cpm.loo.per <- foreach(i=1:nsim, .combine='comb', .multicombine=TRUE, .export=ls(envir=globalenv()),
        .packages=c("dplyr", "ppcor", "foreach", "doParallel"),
        .init=list(list(), list())) %dopar% {
          # shuffle all columes of the behav matrix
          # behav row no longer associate with fcon row
          perm <- sample(nrow(behav))
          behav_var <- names(behav)[-1]
          behav_perm <- behav
          behav_perm[behav_var] <- behav_perm[perm, behav_var]
          
          ## compute & store correlation
          
          behav_measure = "sum.sbinge.log"
          threshold = .0001 
          total_roi = 300
          cor.type = "spearman"
          confound = c("group", "sex", "V1_ParentSES.num", "scanner_change", "age_diff","fd_diff")
          total_sub <- nrow(fcon)
          
          cpm.loo <- foreach(loop=1:total_sub, .combine='comb', .multicombine=TRUE,
                             .packages=c("dplyr", "ppcor"), .export=ls(envir=globalenv()),
                             .init=list(list(), list())) %dopar% {
                               # train test split
                               fcon_train <- fcon[-loop,]
                               fcon_test <- fcon[loop,]
                               behav_train <- behav_perm[-loop,]
                               behav_test <- behav_perm[loop,]
                               
                               merge_train <- full_join(fcon_train, behav_train)
                               
                               # train correlation
                               col_list <- correl(inputdf = merge_train, threshold = threshold, 
                                                  total_roi = total_roi, behav_measure = behav_measure, 
                                                  cor.type=cor.type, confound = confound)
                               pos_col <- col_list[[1]]
                               neg_col <- col_list[[2]]
                               
                               # fit glm on train set
                               pos_fcon_train <- fcon_train %>% dplyr::select(-id) %>% dplyr::select(all_of(pos_col))
                               neg_fcon_train <- fcon_train %>% dplyr::select(-id) %>% dplyr::select(all_of(neg_col))
                               
                               sum_pos_fcon <- rowSums(pos_fcon_train[,1:ncol(pos_fcon_train)], na.rm = T)
                               sum_neg_fcon <- rowSums(neg_fcon_train[,1:ncol(neg_fcon_train)], na.rm = T)
                               
                               model_pos <- lm(unlist(merge_train[behav_measure]) ~ sum_pos_fcon, na.action = na.pass)
                               model_neg <- lm(unlist(merge_train[behav_measure]) ~ sum_neg_fcon, na.action = na.pass)
                               
                               # apply the fitted glm on test set
                               pos_fcon_test <- fcon_test %>% dplyr::select(-id) %>% dplyr::select(all_of(pos_col))
                               neg_fcon_test <- fcon_test %>% dplyr::select(-id) %>% dplyr::select(all_of(neg_col))
                               
                               pos <- rowSums(pos_fcon_test[,1:ncol(pos_fcon_test)], na.rm = T)
                               behav_pred_pos <- as.numeric(model_pos$coefficients[2])*pos + 
                                 as.numeric(model_pos$coefficients[1])
                               
                               neg <- rowSums(neg_fcon_test[,1:ncol(neg_fcon_test)], na.rm = T)
                               behav_pred_neg <- as.numeric(model_neg$coefficients[2])*neg + 
                                 as.numeric(model_neg$coefficients[1])
                               
                               list(behav_pred_pos, behav_pred_neg)
                             }
          
          behav_pred_pos <- unname(unlist(cpm.loo[[1]]))
          behav_pred_neg <- unname(unlist(cpm.loo[[2]]))
          
          Rpos <- cor(behav_pred_pos, unlist(behav_perm[behav_measure]))
          Rneg <- cor(behav_pred_neg, unlist(behav_perm[behav_measure]))
          
          list(Rpos, Rneg)
        }

stopCluster(cl)

Rpos_per_sbinge <- unname(unlist(cpm.loo.per[[1]]))
Rneg_per_sbinge <- unname(unlist(cpm.loo.per[[2]]))

saveRDS(Rpos_per_sbinge, "/Users/tientong/rest/perm_sbinge_0001_pos.RDS")
saveRDS(Rneg_per_sbinge, "/Users/tientong/rest/perm_sbinge_0001_neg.RDS")
