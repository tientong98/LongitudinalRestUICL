setwd("/oleary/functional/UICL/BIDS/code/time2")

df <- read.table("/oleary/functional/UICL/BIDS/code/time2/allscanslist.txt", stringsAsFactors = F, header = F)
names(df) <- "info"

df$sub <- NA
df$ses <- NA
df$scan <- NA
df$scannum <-NA

for (i in 1:length(df$info)) {
  df$sub[i] <- as.numeric(strsplit(df$info, "/")[[i]][7])
  df$ses[i] <- as.numeric(strsplit(df$info, "/")[[i]][8])
  df$scan[i] <- as.character(strsplit(df$info, "/")[[i]][9])
  df$scannum[i] <- as.numeric(strsplit(df$scan[i], "_")[[1]][2])
}

library(dplyr)
move <- df %>% filter(df$scannum > 100)
subjectvec <- unique(move$sub)

library(ff)
for (i in 2:length(subjectvec)) {
  subject <- move %>% filter(sub == subjectvec[i])
    if (dir.exists(paste0("/Shared/oleary/functional/UICL/dicomdata/extra/",subject$sub[1],"/",subject$ses[1])) == F) {
      icesTAF::mkdir(paste0("/Shared/oleary/functional/UICL/dicomdata/extra/",subject$sub[1],"/",subject$ses[1]))
      for (j in 1:length(subject$scan)) {
        from <- paste0("/Shared/oleary/functional/UICL/dicomdata/",subject$sub[1],"/",subject$ses[1])            #Current path of your folder
        to   <- paste0("/Shared/oleary/functional/UICL/dicomdata/extra/",subject$sub[1],"/",subject$ses[1])      #Path you want to move it.
        path1 <- paste0(from, subject$scan[j])
        path2 <- paste0(to, subject$scan[j])
        file.move(path1, path2)
      }}
  
    else {
      for (j in 1:length(subject$scan)) {
        from <- paste0("/Shared/oleary/functional/UICL/dicomdata/",subject$sub[1],"/",subject$ses[1])            #Current path of your folder
        to   <- paste0("/Shared/oleary/functional/UICL/dicomdata/extra/",subject$sub[1],"/",subject$ses[1])      #Path you want to move it.
        path1 <- paste0(from,"/",subject$scan[j])
        path2 <- paste0(to,"/",subject$scan[j])
        file.move(path1, path2)
      }}}

