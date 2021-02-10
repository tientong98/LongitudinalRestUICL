####################################################################################
############   pearson partial correlation between fcon and binge   ################
####################################################################################

library(dplyr)
library(ppcor)
library(foreach)
library(doParallel)

correl <- function(inputdf, threshold, total_roi, behav_measure, confound, cor.type) {
  
  # create a dataframe of correlation result: nrow=number of edges, col=r, p, edge id
  total_roi <- total_roi
  total_edge <- (total_roi^2 - total_roi) / 2
  r.val <- rep(NA, time=total_edge)
  p.val <- rep(NA, time=total_edge)
  
  for (i in 1:total_edge) {
    cor_df <- na.omit(inputdf[c(paste0("V", i), behav_measure, confound)])
    if (nrow(cor_df) >= 3) {
      pcor_result <- ppcor::pcor.test(cor_df[1], cor_df[2], unlist(cor_df[3:ncol(cor_df)]), 
                                      method = cor.type)
      r.val[i] <- pcor_result[1,"estimate"]
      p.val[i] <- pcor_result[1,"p.value"]
    }
  }
  cor_result_df <- data.frame(r.val, p.val)
  
  # get  positive and negative edges significantly correlate with behavioral measure
  threshold <- threshold
  pos_col <- which(cor_result_df$`r.val` > 0 & cor_result_df$`p.val` < threshold)
  neg_col <- which(cor_result_df$`r.val` < 0 & cor_result_df$`p.val` < threshold)
  
  combine_col <- list(pos_col, neg_col)
  
  return(combine_col)
}

####################################################################################
##########################  LOOCV train and predict   ##############################
####################################################################################

comb <- function(x, ...) {
  lapply(seq_along(x),
         function(i) c(x[[i]], lapply(list(...), function(y) y[[i]])))
}

cpm <- function(fcon_df, behav_df, behav_measure, confound, threshold, total_roi, cor.type){
  
  fcon <- fcon_df
  behav <- behav_df
  total_sub <- nrow(fcon)
  
  #setup parallel backend to use many processors
  cores <- detectCores()
  cl <- makeCluster(cores[1]-1) #not to overload your computer
  registerDoParallel(cl)
  
  cpm.loo <- foreach(loop=1:total_sub, .combine='comb', .multicombine=TRUE,
                     .packages=c("dplyr", "ppcor"), .export=ls(envir=globalenv()),
                     .init=list(list(), list(), list(), list(), list(), list())) %dopar% {
                       # train test split
                       fcon_train <- fcon[-loop,]
                       fcon_test <- fcon[loop,]
                       behav_train <- behav[-loop,]
                       behav_test <- behav[loop,]
                       
                       merge_train <- full_join(fcon_train, behav_train)
                       
                       # train correlation
                       col_list <- correl(inputdf = merge_train, threshold = threshold, 
                                          total_roi = total_roi, behav_measure = behav_measure, 
                                          cor.type=cor.type, confound = confound)
                       pos_col_list <- col_list[[1]]
                       neg_col_list <- col_list[[2]]
                       
                       # fit glm on train set
                       pos_fcon_train <- fcon_train %>% dplyr::select(-id) %>% dplyr::select(all_of(pos_col_list))
                       neg_fcon_train <- fcon_train %>% dplyr::select(-id) %>% dplyr::select(all_of(neg_col_list))
                       
                       sum_pos_fcon_train <- rowSums(pos_fcon_train[,1:ncol(pos_fcon_train)], na.rm = T)
                       sum_neg_fcon_train <- rowSums(neg_fcon_train[,1:ncol(neg_fcon_train)], na.rm = T)
                       
                       model_pos <- lm(unlist(merge_train[behav_measure]) ~ sum_pos_fcon_train, na.action = na.pass)
                       model_neg <- lm(unlist(merge_train[behav_measure]) ~ sum_neg_fcon_train, na.action = na.pass)
                       
                       # apply the fitted glm on train set
                       behav_pred_pos_train <- as.numeric(model_pos$coefficients[2])*sum_pos_fcon_train + 
                         as.numeric(model_pos$coefficients[1])
                       behav_pred_neg_train <- as.numeric(model_neg$coefficients[2])*sum_neg_fcon_train + 
                         as.numeric(model_neg$coefficients[1])
                       
                       Rpos_train <- cor(behav_pred_pos_train, unlist(merge_train[behav_measure]))
                       Rneg_train <- cor(behav_pred_neg_train, unlist(merge_train[behav_measure]))
                       
                       # apply the fitted glm on test set
                       pos_fcon_test <- fcon_test %>% dplyr::select(-id) %>% dplyr::select(all_of(pos_col_list))
                       neg_fcon_test <- fcon_test %>% dplyr::select(-id) %>% dplyr::select(all_of(neg_col_list))
                       
                       sum_pos_fcon_test <- rowSums(pos_fcon_test[,1:ncol(pos_fcon_test)], na.rm = T)
                       sum_neg_fcon_test <- rowSums(neg_fcon_test[,1:ncol(neg_fcon_test)], na.rm = T)
                       
                       behav_pred_pos_test <- as.numeric(model_pos$coefficients[2])*sum_pos_fcon_test + 
                         as.numeric(model_pos$coefficients[1])
                       behav_pred_neg_test <- as.numeric(model_neg$coefficients[2])*sum_neg_fcon_test + 
                         as.numeric(model_neg$coefficients[1])
                       
                       list(Rpos_train, Rneg_train, behav_pred_pos_test, behav_pred_neg_test, 
                            pos_col_list, neg_col_list)
                     }
  stopCluster(cl)
  
  Rpos_train <- unname(unlist(cpm.loo[[1]]))
  Rneg_train <- unname(unlist(cpm.loo[[2]]))  
  behav_pred_pos_test <- unname(unlist(cpm.loo[[3]]))
  behav_pred_neg_test <- unname(unlist(cpm.loo[[4]]))
  pos_col_list <- cpm.loo[[5]]
  neg_col_list <- cpm.loo[[6]]
  
  Rpos_test <- cor(behav_pred_pos_test, unlist(behav[behav_measure]))
  Rneg_test <- cor(behav_pred_neg_test, unlist(behav[behav_measure]))
  
  cpm_results <- list(Rpos_train, Rneg_train, Rpos_test, Rneg_test, pos_col_list, neg_col_list)
  
  return(cpm_results)
}
