library(dplyr)
datafile <- "/Users/tientong/rest/finaldfex_final.RDS"
finaldfex <- readRDS(datafile)
subject <- unique(finaldfex$id)

####################################################################################
################   FCON cleaning: time2-time1 + flatten matrix   ###################
####################################################################################

for (i in 1:119) {
  subdf <- finaldfex %>% filter(id==subject[i])
  
  # substract connectivity: time 2 - time 1
  time1 <- read.table(paste0("/Users/tientong/rest/matrix/", subdf[1,'id'], '_', subdf[1,'ses'], '.txt'), 
                      header = T, row.names = 1)
  time2 <- read.table(paste0("/Users/tientong/rest/matrix/", subdf[1,'id'], '_', subdf[2,'ses'], '.txt'), 
                      header = T, row.names = 1)
  subtract <- time2 - time1
  ltr <- subtract[lower.tri(as.matrix(subtract), diag = FALSE)]
  df <- as.data.frame(t(ltr)) %>% 
    mutate(id = subdf[1,'id']) %>% 
    dplyr::select(id, everything())

  write.table(df, "/Users/tientong/rest/flat_subtract.txt", quote = F, sep = '\t', 
              row.names = F, append = T,
              col.names =! file.exists("/Users/tientong/rest/flat_subtract.txt"))
}

# flat_subtract <- read.table("/Users/tientong/rest/flat_subtract.txt", header = T)

####################################################################################
############################   imputing missing data   #############################
####################################################################################

# library(missForest)
# # it builds a random forest model for each variable. Then it uses the model to predict 
# # missing values in the variable with the help of observed values.
# flat_subtract.imputed <- missForest(flat_subtract %>% dplyr::select(-id))
# 
# write.table(flat_subtract.imputed, "/Users/tientong/rest/flat_subtract_imputed.txt", quote = F, 
#             sep = '\t', row.names = F, col.names = T)