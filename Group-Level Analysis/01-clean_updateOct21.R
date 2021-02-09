rm(list=ls())

setwd("~/Documents/oleary/rest/")
library(psych)
library(dplyr)
library(foreign)
library(tidyr)


#######################################################################################################
####################### excluding ROIs with high signal dropout (few data points) #####################
#######################################################################################################

################################################ GE ###################################################
# Time 1 Siemens Time 2 GE - N = 98 (2 sessions = 196 files)
# List the file names of all subjects with GE time 2 data
gefiles <- data.frame(list.files("all_twovisitGE/raw/"), stringsAsFactors = F)
names(gefiles)[1] <- "files"

# get subid ge
subge <- rep(NA, length(gefiles[,]))
for (subi in 1:length(gefiles[,])) {
  subge[subi] <- strsplit(strsplit(gefiles[subi,], split = "_")[[1]][1], split = "-")[[1]][2]
}

sesge <- rep(NA, length(gefiles[,]))
for (sesi in 1:length(gefiles[,])) {
  sesge[sesi] <- strsplit(strsplit(gefiles[sesi,], split = "_")[[1]][2], split = "-")[[1]][2]
}

# read each subject file, get the ROI index for each subject
# output a text file row = subject/ses, columns = common ROIs
for (i in 1:length(subge)) {
  df <- read.table(file = paste0("all_twovisitGE/raw/sub-",subge[i],"_ses-",sesge[i],"_extendedPower_000.netcc"), header = F)
  roi <- df[1,]
  row.names(roi) <- paste0(subge[i],'_',sesge[i])
  write.table(roi, "roi.txt", quote = F, col.names = F, row.names = T, sep = "\t", append = T)
}

############################################## SIEMENS ##################################################
# Time 1 Siemens Time 2 Siemens - N = 21 (2 sessions = 42 files)
# List the file names of all subjects with Siemens time 2 data
sifiles <- data.frame(list.files("all_twovisitSiemens/raw/"), stringsAsFactors = F)
names(sifiles)[1] <- "files"

# sit subid si
subsi <- rep(NA, length(sifiles[,]))
for (subi in 1:length(sifiles[,])) {
  subsi[subi] <- strsplit(strsplit(sifiles[subi,], split = "_")[[1]][1], split = "-")[[1]][2]
}

sessi <- rep(NA, length(sifiles[,]))
for (sesi in 1:length(sifiles[,])) {
  sessi[sesi] <- strsplit(strsplit(sifiles[sesi,], split = "_")[[1]][2], split = "-")[[1]][2]
}


# read each subject file, get the ROI index for each subject
# output a text file row = subject/ses, columns = common ROIs
for (i in 1:length(subsi)) {
  df <- read.table(file = paste0("all_twovisitSiemens/raw/sub-",subsi[i],"_ses-",sessi[i],"_extendedPower_000.netcc"), header = F)
  roi <- df[1,]
  row.names(roi) <- paste0(subsi[i],'_',sessi[i])
  write.table(roi, "roi.txt", quote = F, col.names = F, row.names = T, sep = "\t", append = T)
}

# excluding ROIs with high signal dropout

roi <- read.table("roi.txt", header = F,  row.names = 1, col.names = paste0("Col",seq_len(300)), fill = TRUE)

#NAcc: R - 175, L - 176 (reward network)  
#Hippo: L posterior - 98, R posterior - 99 (98, 99 default mode), L anterior - 162; R anterior -163 (162, 163 medial temporal)  
#Amygdala: L - 173, R - 174 (reward network)  

# FOR EACH ROI: find out how many people have data for
# 119 subjects * 2 sessions = 238

roi.persub <- matrix(NA, nrow = 300, ncol = 1)
  
for (i in 1:300) {
  roi.persub[i,] <- sum(roi[,] == i, na.rm = T)
}
write.table(roi.persub, "roipersub.txt", quote = F, col.names = NA, row.names = T, sep = '\t')

# index 174, No run = 213 -- 25 runs
# index 173, No run = 223
# index 175, No run = 229
# index 176, No run = 233

roi.persub <- data.frame(roi.persub)
roi.persub$newindex <- row.names(roi.persub)

# exclude 15 ROIs, then get network affiliations of those excluded ROIs
roi.persub.filter <- roi.persub %>% filter(roi.persub >= 213)
exclude <- as.numeric(roi.persub$newindex[!roi.persub$newindex %in% roi.persub.filter$newindex]) # 15 ROIs

network <- read.table("network.txt", header = T)
exclude.network <- subset(network, network$newindex %in% exclude)
library("xlsx")
write.xlsx(exclude.network, "SuppTable.xlsx", sheetName = "Sheet1", col.names = T, row.names = F, append = F)

 
#######################################################################################################
########################                      GET DATA                         ########################
#######################################################################################################

# first create a blank 300 x 300 matrix
fullcormat <- data.frame(matrix(nrow=300,ncol=300))
fullroiname <- as.character(1:300)
colnames(fullcormat) <- fullroiname

################################################ GE ###################################################

# read in 3dnetcorr output, then grab the cell in the first column whose value == 4 (starting of z correl)
# then name columns and rows by ROI number, add missing ROIs, then save to new text file


for (x in 1:length(gefiles[,])) {
  cormat <- read.table(file = paste0("all_twovisitGE/raw/sub-",subge[x],"_ses-",sesge[x],"_extendedPower_000.netcc"), 
                       header = F)
  roiname <- cormat[1,]
  
  # get the z-transformed matrix only
  cormat <- cormat[(which(cormat$V1 == 4):length(cormat$V1)),]
  
  # name columns and rows as ROI index
  rownames(cormat) <- roiname
  colnames(cormat) <- roiname
  
  # find missing ROIs and add those to the matrix
  add <- fullroiname[!fullroiname %in% roiname]
  for (i in 1:length(add)) {
    cormat[as.character(add[i])] <- NA
    cormat[as.character(add[i]),] <- NA
  }
  
  # re-organize the colnames and rownames to consecutive order
  cormat <- cormat[, fullroiname]
  cormat <- cormat[fullroiname, ]
  diag(cormat) <- NA
  
  # save the new matrix
  write.table(cormat, file = paste0("all_twovisitGE/derivatives/",subge[x],"_",sesge[x],".txt"), 
              quote = F, col.names = NA, row.names = T, sep = "\t")
}


################################################ Siemens ###################################################

# read in 3dnetcorr output, then grab the cell in the first column whose value == 4 (starting of z correl)
# then name columns and rows by ROI number, add missing ROIs, then save to new text file


for (x in 1:length(sifiles[,])) {
  cormat <- read.table(file = paste0("all_twovisitSiemens/raw/sub-",subsi[x],"_ses-",sessi[x],"_extendedPower_000.netcc"), 
                       header = F)
  roiname <- cormat[1,]
  
  # get the z-transformed matrix only
  cormat <- cormat[(which(cormat$V1 == 4):length(cormat$V1)),]
  
  # name columns and rows as ROI index
  rownames(cormat) <- roiname
  colnames(cormat) <- roiname
  
  # find missing ROIs and add those to the matrix
  add <- fullroiname[!fullroiname %in% roiname]
  for (i in 1:length(add)) {
    cormat[as.character(add[i])] <- NA
    cormat[as.character(add[i]),] <- NA
  }
  
  # re-organize the colnames and rownames to consecutive order
  cormat <- cormat[, fullroiname]
  cormat <- cormat[fullroiname, ]
  diag(cormat) <- NA
  
  # save the new matrix
  write.table(cormat, file = paste0("all_twovisitSiemens/derivatives/",subsi[x],"_",sessi[x],".txt"), 
              quote = F, col.names = NA, row.names = T, sep = "\t")
}

#######################################################################################################
### CALCULATE 91 WITHIN- AND BETWEEN-NETWORK CORRELATIONS excluding more ROI but include Amygdala #####
#######################################################################################################

################################################ GE ###################################################

for (x in 1:length(gefiles[,])) {
  
  # read the z-transformed correlation matrix, with added missing ROIs
  submat <- as.matrix(read.table(file = paste0("all_twovisitGE/derivatives/",subge[x],"_",sesge[x],".txt")), 
                      nrow=300, ncol=300, diag = F)
  
  # exclude ROIs with few subjects have brain coverage for
  roiexclude <- exclude
  for (i in roiexclude) {
    submat[i,] <- NA
    submat[,i] <- NA
  }
  
  # Calculate the 13 within-network correlations and 78 between-network correlations
  Auditory <- mean(submat[1:12, 1:12], na.rm = T)
  CinguloOpercular <- mean(submat[13:42, 13:42], na.rm = T)
  DefaultMode <- mean(submat[43:107, 43:107], na.rm = T)
  DorsalAttention <- mean(submat[108:123, 108:123], na.rm = T)
  FrontoParietal <- mean(submat[124:159, 124:159], na.rm = T)
  MedialTemporal <- mean(submat[160:163, 160:163], na.rm = T)
  ParietoMedial <- mean(submat[164:168, 164:168], na.rm = T)
  Reward <- mean(submat[169:176, 169:176], na.rm = T)
  Salience <- mean(submat[177:189, 177:189], na.rm = T)
  SomatomotorDorsal <- mean(submat[190:229, 190:229], na.rm = T)
  SomatomotorLateral <- mean(submat[230:240, 230:240], na.rm = T)
  VentralAttention <- mean(submat[253:263, 253:263], na.rm = T)
  Visual <- mean(submat[264:300, 264:300], na.rm = T)
  
  Auditory.CinguloOpercular <- mean(submat[13:42, 1:12], na.rm = T)
  Auditory.DefaultMode <- mean(submat[43:107, 1:12], na.rm = T)
  Auditory.DorsalAttention <- mean(submat[108:123, 1:12], na.rm = T)
  Auditory.FrontoParietal <- mean(submat[124:159, 1:12], na.rm = T)
  Auditory.MedialTemporal <- mean(submat[160:163, 1:12], na.rm = T)
  Auditory.ParietoMedial <- mean(submat[164:168, 1:12], na.rm = T)
  Auditory.Reward <- mean(submat[169:176, 1:12], na.rm = T)
  Auditory.Salience <- mean(submat[177:189, 1:12], na.rm = T)
  Auditory.SomatomotorDorsal <- mean(submat[190:229, 1:12], na.rm = T)
  Auditory.SomatomotorLateral <- mean(submat[230:240, 1:12], na.rm = T)
  Auditory.VentralAttention <- mean(submat[253:263, 1:12], na.rm = T)
  Auditory.Visual <- mean(submat[264:300, 1:12], na.rm = T)
  
  CinguloOpercular.DefaultMode <- mean(submat[43:107, 13:42], na.rm = T)
  CinguloOpercular.DorsalAttention <- mean(submat[108:123, 13:42], na.rm = T)
  CinguloOpercular.FrontoParietal <- mean(submat[124:159, 13:42], na.rm = T)
  CinguloOpercular.MedialTemporal <- mean(submat[160:163, 13:42], na.rm = T)
  CinguloOpercular.ParietoMedial <- mean(submat[164:168, 13:42], na.rm = T)
  CinguloOpercular.Reward <- mean(submat[169:176, 13:42], na.rm = T) 
  CinguloOpercular.Salience <- mean(submat[177:189, 13:42], na.rm = T)
  CinguloOpercular.SomatomotorDorsal <- mean(submat[190:229, 13:42], na.rm = T)
  CinguloOpercular.SomatomotorLateral <- mean(submat[230:240, 13:42], na.rm = T)
  CinguloOpercular.VentralAttention <- mean(submat[253:263, 13:42], na.rm = T)
  CinguloOpercular.Visual <- mean(submat[264:300, 13:42], na.rm = T)
  
  DefaultMode.DorsalAttention <- mean(submat[108:123, 43:107], na.rm = T)
  DefaultMode.FrontoParietal <- mean(submat[124:159, 43:107], na.rm = T)
  DefaultMode.MedialTemporal <- mean(submat[160:163, 43:107], na.rm = T)
  DefaultMode.ParietoMedial <- mean(submat[164:168, 43:107], na.rm = T)
  DefaultMode.Reward <- mean(submat[169:176, 43:107], na.rm = T)
  DefaultMode.Salience <- mean(submat[177:189, 43:107], na.rm = T)
  DefaultMode.SomatomotorDorsal <- mean(submat[190:229, 43:107], na.rm = T)
  DefaultMode.SomatomotorLateral <- mean(submat[230:240, 43:107], na.rm = T)
  DefaultMode.VentralAttention <- mean(submat[253:263, 43:107], na.rm = T)
  DefaultMode.Visual <- mean(submat[264:300, 43:107], na.rm = T)
  
  DorsalAttention.FrontoParietal <- mean(submat[124:159, 108:123], na.rm = T)
  DorsalAttention.MedialTemporal <- mean(submat[160:163, 108:123], na.rm = T)
  DorsalAttention.ParietoMedial <- mean(submat[164:168, 108:123], na.rm = T)
  DorsalAttention.Reward <- mean(submat[169:176, 108:123], na.rm = T)
  DorsalAttention.Salience <- mean(submat[177:189, 108:123], na.rm = T)
  DorsalAttention.SomatomotorDorsal <- mean(submat[190:229, 108:123], na.rm = T)
  DorsalAttention.SomatomotorLateral <- mean(submat[230:240, 108:123], na.rm = T)
  DorsalAttention.VentralAttention <- mean(submat[253:263, 108:123], na.rm = T)
  DorsalAttention.Visual <- mean(submat[264:300, 108:123], na.rm = T)
  
  FrontoParietal.MedialTemporal <- mean(submat[160:163, 124:159], na.rm = T)
  FrontoParietal.ParietoMedial <- mean(submat[164:168, 124:159], na.rm = T)
  FrontoParietal.Reward <- mean(submat[169:176, 124:159], na.rm = T)
  FrontoParietal.Salience <- mean(submat[177:189, 124:159], na.rm = T)
  FrontoParietal.SomatomotorDorsal <- mean(submat[190:229, 124:159], na.rm = T)
  FrontoParietal.SomatomotorLateral <- mean(submat[230:240, 124:159], na.rm = T)
  FrontoParietal.VentralAttention <- mean(submat[253:263, 124:159], na.rm = T)
  FrontoParietal.Visual <- mean(submat[264:300, 124:159], na.rm = T)
  
  MedialTemporal.ParietoMedial <- mean(submat[164:168, 160:163], na.rm = T)
  MedialTemporal.Reward <- mean(submat[169:176, 160:163], na.rm = T)
  MedialTemporal.Salience <- mean(submat[177:189, 160:163], na.rm = T)
  MedialTemporal.SomatomotorDorsal <- mean(submat[190:229, 160:163], na.rm = T)
  MedialTemporal.SomatomotorLateral <- mean(submat[230:240, 160:163], na.rm = T)
  MedialTemporal.VentralAttention <- mean(submat[253:263, 160:163], na.rm = T)
  MedialTemporal.Visual <- mean(submat[264:300, 160:163], na.rm = T)
  
  ParietoMedial.Reward <- mean(submat[169:176, 164:168], na.rm = T)
  ParietoMedial.Salience <- mean(submat[177:189, 164:168], na.rm = T)
  ParietoMedial.SomatomotorDorsal <- mean(submat[190:229, 164:168], na.rm = T)
  ParietoMedial.SomatomotorLateral <- mean(submat[230:240, 164:168], na.rm = T)
  ParietoMedial.VentralAttention <- mean(submat[253:263, 164:168], na.rm = T)
  ParietoMedial.Visual <- mean(submat[264:300, 164:168], na.rm = T)
  
  Reward.Salience <- mean(submat[177:189, 169:176], na.rm = T)
  Reward.SomatomotorDorsal <- mean(submat[190:229, 169:176], na.rm = T)
  Reward.SomatomotorLateral <- mean(submat[230:240, 169:176], na.rm = T)
  Reward.VentralAttention <- mean(submat[253:263, 169:176], na.rm = T)
  Reward.Visual <- mean(submat[264:300, 169:176], na.rm = T)
  
  Salience.SomatomotorDorsal <- mean(submat[190:229, 177:189], na.rm = T)
  Salience.SomatomotorLateral <- mean(submat[230:240, 177:189], na.rm = T)
  Salience.VentralAttention <- mean(submat[253:263, 177:189], na.rm = T)
  Salience.Visual <- mean(submat[264:300, 177:189], na.rm = T)
  
  SomatomotorDorsal.SomatomotorLateral <- mean(submat[230:240, 190:229], na.rm = T)
  SomatomotorDorsal.VentralAttention <- mean(submat[253:263, 190:229], na.rm = T)
  SomatomotorDorsal.Visual <- mean(submat[264:300, 190:229], na.rm = T)
  
  SomatomotorLateral.VentralAttention <- mean(submat[253:263, 230:240], na.rm = T)
  SomatomotorLateral.Visual <- mean(submat[264:300, 230:240], na.rm = T)
  
  VentralAttention.Visual <- mean(submat[264:300, 253:263], na.rm = T)
  
  id <- subge[x]
  ses <- sesge[x]
  time2_scanner <- "ge"
  
  subjdata <- data.frame(id,
                         ses,
                         time2_scanner,
                         Auditory,
                         CinguloOpercular,
                         DefaultMode,
                         DorsalAttention,
                         FrontoParietal,
                         MedialTemporal,
                         ParietoMedial,
                         Reward,
                         Salience,
                         SomatomotorDorsal,
                         SomatomotorLateral,
                         VentralAttention,
                         Visual,
                         
                         Auditory.CinguloOpercular,
                         Auditory.DefaultMode,
                         Auditory.DorsalAttention,
                         Auditory.FrontoParietal,
                         Auditory.MedialTemporal,
                         Auditory.ParietoMedial,
                         Auditory.Reward,
                         Auditory.Salience,
                         Auditory.SomatomotorDorsal,
                         Auditory.SomatomotorLateral,
                         Auditory.VentralAttention,
                         Auditory.Visual,
                         
                         CinguloOpercular.DefaultMode,
                         CinguloOpercular.DorsalAttention,
                         CinguloOpercular.FrontoParietal,
                         CinguloOpercular.MedialTemporal,
                         CinguloOpercular.ParietoMedial,
                         CinguloOpercular.Reward,
                         CinguloOpercular.Salience,
                         CinguloOpercular.SomatomotorDorsal,
                         CinguloOpercular.SomatomotorLateral,
                         CinguloOpercular.VentralAttention,
                         CinguloOpercular.Visual,
                         
                         DefaultMode.DorsalAttention,
                         DefaultMode.FrontoParietal,
                         DefaultMode.MedialTemporal,
                         DefaultMode.ParietoMedial,
                         DefaultMode.Reward,
                         DefaultMode.Salience,
                         DefaultMode.SomatomotorDorsal,
                         DefaultMode.SomatomotorLateral,
                         DefaultMode.VentralAttention,
                         DefaultMode.Visual,
                         
                         DorsalAttention.FrontoParietal,
                         DorsalAttention.MedialTemporal,
                         DorsalAttention.ParietoMedial,
                         DorsalAttention.Reward,
                         DorsalAttention.Salience,
                         DorsalAttention.SomatomotorDorsal,
                         DorsalAttention.SomatomotorLateral,
                         DorsalAttention.VentralAttention,
                         DorsalAttention.Visual,
                         
                         FrontoParietal.MedialTemporal,
                         FrontoParietal.ParietoMedial,
                         FrontoParietal.Reward,
                         FrontoParietal.Salience,
                         FrontoParietal.SomatomotorDorsal,
                         FrontoParietal.SomatomotorLateral,
                         FrontoParietal.VentralAttention,
                         FrontoParietal.Visual,
                         
                         MedialTemporal.ParietoMedial,
                         MedialTemporal.Reward,
                         MedialTemporal.Salience,
                         MedialTemporal.SomatomotorDorsal,
                         MedialTemporal.SomatomotorLateral,
                         MedialTemporal.VentralAttention,
                         MedialTemporal.Visual,
                         
                         ParietoMedial.Reward,
                         ParietoMedial.Salience,
                         ParietoMedial.SomatomotorDorsal,
                         ParietoMedial.SomatomotorLateral,
                         ParietoMedial.VentralAttention,
                         ParietoMedial.Visual,
                         
                         Reward.Salience,
                         Reward.SomatomotorDorsal,
                         Reward.SomatomotorLateral,
                         Reward.VentralAttention,
                         Reward.Visual,
                         
                         Salience.SomatomotorDorsal,
                         Salience.SomatomotorLateral,
                         Salience.VentralAttention,
                         Salience.Visual,
                         
                         SomatomotorDorsal.SomatomotorLateral,
                         SomatomotorDorsal.VentralAttention,
                         SomatomotorDorsal.Visual,
                         
                         SomatomotorLateral.VentralAttention,
                         SomatomotorLateral.Visual,
                         
                         VentralAttention.Visual)
  
  write.table(subjdata, row.names = F, col.names =! file.exists("all_twovisitGE/derivatives/allsub_time2ge_excludemore.tsv"), 
              sep = "\t", quote = F, file = "all_twovisitGE/derivatives/allsub_time2ge_excludemore.tsv", append = T)
}



################################################ SIEMENS ###################################################

for (x in 1:length(sifiles[,])) {
  # read the z-transformed correlation matrix, with added missing ROIs
  submat <- as.matrix(read.table(file = paste0("all_twovisitSiemens/derivatives/",subsi[x],"_",sessi[x],".txt")), 
                      nrow=300, ncol=300, diag = F)
  
  # exclude ROIs with few subjects have brain coverage for
  #roiexclude <- c(246, 243)
  roiexclude <- exclude
  for (i in roiexclude) {
    submat[i,] <- NA
    submat[,i] <- NA
  }
  
  # Calculate the 13 within-network correlations and 78 between-network correlations
  Auditory <- mean(submat[1:12, 1:12], na.rm = T)
  CinguloOpercular <- mean(submat[13:42, 13:42], na.rm = T)
  DefaultMode <- mean(submat[43:107, 43:107], na.rm = T)
  DorsalAttention <- mean(submat[108:123, 108:123], na.rm = T)
  FrontoParietal <- mean(submat[124:159, 124:159], na.rm = T)
  MedialTemporal <- mean(submat[160:163, 160:163], na.rm = T)
  ParietoMedial <- mean(submat[164:168, 164:168], na.rm = T)
  Reward <- mean(submat[169:176, 169:176], na.rm = T)
  Salience <- mean(submat[177:189, 177:189], na.rm = T)
  SomatomotorDorsal <- mean(submat[190:229, 190:229], na.rm = T)
  SomatomotorLateral <- mean(submat[230:240, 230:240], na.rm = T)
  VentralAttention <- mean(submat[253:263, 253:263], na.rm = T)
  Visual <- mean(submat[264:300, 264:300], na.rm = T)
  
  Auditory.CinguloOpercular <- mean(submat[13:42, 1:12], na.rm = T)
  Auditory.DefaultMode <- mean(submat[43:107, 1:12], na.rm = T)
  Auditory.DorsalAttention <- mean(submat[108:123, 1:12], na.rm = T)
  Auditory.FrontoParietal <- mean(submat[124:159, 1:12], na.rm = T)
  Auditory.MedialTemporal <- mean(submat[160:163, 1:12], na.rm = T)
  Auditory.ParietoMedial <- mean(submat[164:168, 1:12], na.rm = T)
  Auditory.Reward <- mean(submat[169:176, 1:12], na.rm = T)
  Auditory.Salience <- mean(submat[177:189, 1:12], na.rm = T)
  Auditory.SomatomotorDorsal <- mean(submat[190:229, 1:12], na.rm = T)
  Auditory.SomatomotorLateral <- mean(submat[230:240, 1:12], na.rm = T)
  Auditory.VentralAttention <- mean(submat[253:263, 1:12], na.rm = T)
  Auditory.Visual <- mean(submat[264:300, 1:12], na.rm = T)
  
  CinguloOpercular.DefaultMode <- mean(submat[43:107, 13:42], na.rm = T)
  CinguloOpercular.DorsalAttention <- mean(submat[108:123, 13:42], na.rm = T)
  CinguloOpercular.FrontoParietal <- mean(submat[124:159, 13:42], na.rm = T)
  CinguloOpercular.MedialTemporal <- mean(submat[160:163, 13:42], na.rm = T)
  CinguloOpercular.ParietoMedial <- mean(submat[164:168, 13:42], na.rm = T)
  CinguloOpercular.Reward <- mean(submat[169:176, 13:42], na.rm = T) 
  CinguloOpercular.Salience <- mean(submat[177:189, 13:42], na.rm = T)
  CinguloOpercular.SomatomotorDorsal <- mean(submat[190:229, 13:42], na.rm = T)
  CinguloOpercular.SomatomotorLateral <- mean(submat[230:240, 13:42], na.rm = T)
  CinguloOpercular.VentralAttention <- mean(submat[253:263, 13:42], na.rm = T)
  CinguloOpercular.Visual <- mean(submat[264:300, 13:42], na.rm = T)
  
  DefaultMode.DorsalAttention <- mean(submat[108:123, 43:107], na.rm = T)
  DefaultMode.FrontoParietal <- mean(submat[124:159, 43:107], na.rm = T)
  DefaultMode.MedialTemporal <- mean(submat[160:163, 43:107], na.rm = T)
  DefaultMode.ParietoMedial <- mean(submat[164:168, 43:107], na.rm = T)
  DefaultMode.Reward <- mean(submat[169:176, 43:107], na.rm = T)
  DefaultMode.Salience <- mean(submat[177:189, 43:107], na.rm = T)
  DefaultMode.SomatomotorDorsal <- mean(submat[190:229, 43:107], na.rm = T)
  DefaultMode.SomatomotorLateral <- mean(submat[230:240, 43:107], na.rm = T)
  DefaultMode.VentralAttention <- mean(submat[253:263, 43:107], na.rm = T)
  DefaultMode.Visual <- mean(submat[264:300, 43:107], na.rm = T)
  
  DorsalAttention.FrontoParietal <- mean(submat[124:159, 108:123], na.rm = T)
  DorsalAttention.MedialTemporal <- mean(submat[160:163, 108:123], na.rm = T)
  DorsalAttention.ParietoMedial <- mean(submat[164:168, 108:123], na.rm = T)
  DorsalAttention.Reward <- mean(submat[169:176, 108:123], na.rm = T)
  DorsalAttention.Salience <- mean(submat[177:189, 108:123], na.rm = T)
  DorsalAttention.SomatomotorDorsal <- mean(submat[190:229, 108:123], na.rm = T)
  DorsalAttention.SomatomotorLateral <- mean(submat[230:240, 108:123], na.rm = T)
  DorsalAttention.VentralAttention <- mean(submat[253:263, 108:123], na.rm = T)
  DorsalAttention.Visual <- mean(submat[264:300, 108:123], na.rm = T)
  
  FrontoParietal.MedialTemporal <- mean(submat[160:163, 124:159], na.rm = T)
  FrontoParietal.ParietoMedial <- mean(submat[164:168, 124:159], na.rm = T)
  FrontoParietal.Reward <- mean(submat[169:176, 124:159], na.rm = T)
  FrontoParietal.Salience <- mean(submat[177:189, 124:159], na.rm = T)
  FrontoParietal.SomatomotorDorsal <- mean(submat[190:229, 124:159], na.rm = T)
  FrontoParietal.SomatomotorLateral <- mean(submat[230:240, 124:159], na.rm = T)
  FrontoParietal.VentralAttention <- mean(submat[253:263, 124:159], na.rm = T)
  FrontoParietal.Visual <- mean(submat[264:300, 124:159], na.rm = T)
  
  MedialTemporal.ParietoMedial <- mean(submat[164:168, 160:163], na.rm = T)
  MedialTemporal.Reward <- mean(submat[169:176, 160:163], na.rm = T)
  MedialTemporal.Salience <- mean(submat[177:189, 160:163], na.rm = T)
  MedialTemporal.SomatomotorDorsal <- mean(submat[190:229, 160:163], na.rm = T)
  MedialTemporal.SomatomotorLateral <- mean(submat[230:240, 160:163], na.rm = T)
  MedialTemporal.VentralAttention <- mean(submat[253:263, 160:163], na.rm = T)
  MedialTemporal.Visual <- mean(submat[264:300, 160:163], na.rm = T)
  
  ParietoMedial.Reward <- mean(submat[169:176, 164:168], na.rm = T)
  ParietoMedial.Salience <- mean(submat[177:189, 164:168], na.rm = T)
  ParietoMedial.SomatomotorDorsal <- mean(submat[190:229, 164:168], na.rm = T)
  ParietoMedial.SomatomotorLateral <- mean(submat[230:240, 164:168], na.rm = T)
  ParietoMedial.VentralAttention <- mean(submat[253:263, 164:168], na.rm = T)
  ParietoMedial.Visual <- mean(submat[264:300, 164:168], na.rm = T)
  
  Reward.Salience <- mean(submat[177:189, 169:176], na.rm = T)
  Reward.SomatomotorDorsal <- mean(submat[190:229, 169:176], na.rm = T)
  Reward.SomatomotorLateral <- mean(submat[230:240, 169:176], na.rm = T)
  Reward.VentralAttention <- mean(submat[253:263, 169:176], na.rm = T)
  Reward.Visual <- mean(submat[264:300, 169:176], na.rm = T)
  
  Salience.SomatomotorDorsal <- mean(submat[190:229, 177:189], na.rm = T)
  Salience.SomatomotorLateral <- mean(submat[230:240, 177:189], na.rm = T)
  Salience.VentralAttention <- mean(submat[253:263, 177:189], na.rm = T)
  Salience.Visual <- mean(submat[264:300, 177:189], na.rm = T)
  
  SomatomotorDorsal.SomatomotorLateral <- mean(submat[230:240, 190:229], na.rm = T)
  SomatomotorDorsal.VentralAttention <- mean(submat[253:263, 190:229], na.rm = T)
  SomatomotorDorsal.Visual <- mean(submat[264:300, 190:229], na.rm = T)
  
  SomatomotorLateral.VentralAttention <- mean(submat[253:263, 230:240], na.rm = T)
  SomatomotorLateral.Visual <- mean(submat[264:300, 230:240], na.rm = T)
  
  VentralAttention.Visual <- mean(submat[264:300, 253:263], na.rm = T)
  
  id <- subsi[x]
  ses <- sessi[x]
  time2_scanner <- "siemens"
  
  subjdata <- data.frame(id,
                         ses,
                         time2_scanner,
                         Auditory,
                         CinguloOpercular,
                         DefaultMode,
                         DorsalAttention,
                         FrontoParietal,
                         MedialTemporal,
                         ParietoMedial,
                         Reward,
                         Salience,
                         SomatomotorDorsal,
                         SomatomotorLateral,
                         VentralAttention,
                         Visual,
                         
                         Auditory.CinguloOpercular,
                         Auditory.DefaultMode,
                         Auditory.DorsalAttention,
                         Auditory.FrontoParietal,
                         Auditory.MedialTemporal,
                         Auditory.ParietoMedial,
                         Auditory.Reward,
                         Auditory.Salience,
                         Auditory.SomatomotorDorsal,
                         Auditory.SomatomotorLateral,
                         Auditory.VentralAttention,
                         Auditory.Visual,
                         
                         CinguloOpercular.DefaultMode,
                         CinguloOpercular.DorsalAttention,
                         CinguloOpercular.FrontoParietal,
                         CinguloOpercular.MedialTemporal,
                         CinguloOpercular.ParietoMedial,
                         CinguloOpercular.Reward,
                         CinguloOpercular.Salience,
                         CinguloOpercular.SomatomotorDorsal,
                         CinguloOpercular.SomatomotorLateral,
                         CinguloOpercular.VentralAttention,
                         CinguloOpercular.Visual,
                         
                         DefaultMode.DorsalAttention,
                         DefaultMode.FrontoParietal,
                         DefaultMode.MedialTemporal,
                         DefaultMode.ParietoMedial,
                         DefaultMode.Reward,
                         DefaultMode.Salience,
                         DefaultMode.SomatomotorDorsal,
                         DefaultMode.SomatomotorLateral,
                         DefaultMode.VentralAttention,
                         DefaultMode.Visual,
                         
                         DorsalAttention.FrontoParietal,
                         DorsalAttention.MedialTemporal,
                         DorsalAttention.ParietoMedial,
                         DorsalAttention.Reward,
                         DorsalAttention.Salience,
                         DorsalAttention.SomatomotorDorsal,
                         DorsalAttention.SomatomotorLateral,
                         DorsalAttention.VentralAttention,
                         DorsalAttention.Visual,
                         
                         FrontoParietal.MedialTemporal,
                         FrontoParietal.ParietoMedial,
                         FrontoParietal.Reward,
                         FrontoParietal.Salience,
                         FrontoParietal.SomatomotorDorsal,
                         FrontoParietal.SomatomotorLateral,
                         FrontoParietal.VentralAttention,
                         FrontoParietal.Visual,
                         
                         MedialTemporal.ParietoMedial,
                         MedialTemporal.Reward,
                         MedialTemporal.Salience,
                         MedialTemporal.SomatomotorDorsal,
                         MedialTemporal.SomatomotorLateral,
                         MedialTemporal.VentralAttention,
                         MedialTemporal.Visual,
                         
                         ParietoMedial.Reward,
                         ParietoMedial.Salience,
                         ParietoMedial.SomatomotorDorsal,
                         ParietoMedial.SomatomotorLateral,
                         ParietoMedial.VentralAttention,
                         ParietoMedial.Visual,
                         
                         Reward.Salience,
                         Reward.SomatomotorDorsal,
                         Reward.SomatomotorLateral,
                         Reward.VentralAttention,
                         Reward.Visual,
                         
                         Salience.SomatomotorDorsal,
                         Salience.SomatomotorLateral,
                         Salience.VentralAttention,
                         Salience.Visual,
                         
                         SomatomotorDorsal.SomatomotorLateral,
                         SomatomotorDorsal.VentralAttention,
                         SomatomotorDorsal.Visual,
                         
                         SomatomotorLateral.VentralAttention,
                         SomatomotorLateral.Visual,
                         
                         VentralAttention.Visual)
  
  write.table(subjdata, row.names = F, col.names =! file.exists("all_twovisitSiemens/derivatives/allsub_time2si_excludemore.tsv"), 
              sep = "\t", quote = F, file = "all_twovisitSiemens/derivatives/allsub_time2si_excludemore.tsv", append = T)
}


#########################################################################################################
###############################  CREATE FUNC CONNECTIVITY DF  ###########################################
#########################################################################################################

gettimeline <- function(inputdataframe, subject_id){
  sub <- inputdataframe %>% filter(id == subject_id)
  sub$ses <- as.character(sub$ses)
  sub[1,"year"] <- as.numeric(paste0(strsplit(sub$ses, split = '')[[1]][7], 
                                     strsplit(sub$ses, split = '')[[1]][8]))
  sub[2,"year"] <- as.numeric(paste0(strsplit(sub$ses, split = '')[[2]][7], 
                                     strsplit(sub$ses, split = '')[[2]][8]))
  if (sub[1,"year"]  > sub[2,"year"]) {
    sub[1,"ses_ord"] <- 2 
    sub[2,"ses_ord"] <- 1
  } else {
    sub[1,"ses_ord"] <- 1
    sub[2,"ses_ord"] <- 2}
  
  inputdataframe[inputdataframe$id == subject_id, "ses_ord"][1] <- sub[1, "ses_ord"]
  inputdataframe[inputdataframe$id == subject_id, "ses_ord"][2] <- sub[2, "ses_ord"]
  
  return(inputdataframe)
}

gefconex <- read.table("~/Documents/oleary/rest/all_twovisitGE/derivatives/allsub_time2ge_excludemore.tsv", header = T)
sifconex <- read.table("~/Documents/oleary/rest/all_twovisitSiemens/derivatives/allsub_time2si_excludemore.tsv", header = T)
fconex <- merge(gefconex, sifconex, all = T)

for (subid in fconex$id) {
  fconex <- gettimeline(fconex, subid)
}

fconex <- fconex %>% dplyr::select(id, ses, ses_ord, time2_scanner, everything()) %>%
  arrange(id, ses_ord)


write.table(fconex, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/rest/fconex.txt")

# lapply(fconex[5:95], function(x) 
#   t.test(x ~ fconex$ses_ord, paired = TRUE, na.action = na.pass))

#########################################################################################################
###############################  ADD FRAMEWISE DISPLACEMENT  ############################################
#########################################################################################################

fd <- read.table("~/Documents/oleary/rest/qc/fd_rest.txt", header = T)

# add FD infor to fcon data (91 variables + 4 id variables)

fconex <- merge(fconex, fd, by = 'ses') %>% dplyr::select(-id.y) %>%
  dplyr::select(id.x, ses, ses_ord, time2_scanner, mean.fd, everything()) %>%
  rename(id = id.x, fd = mean.fd) %>%
  arrange(id, ses_ord)

write.table(fconex, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/rest/fconex-fd.txt")

#########################################################################################################
##################################  ADD DEMOGRAPHIC INFO  ###############################################
#########################################################################################################

# demo_subset.long created in 02-demo.R
demo_subset.long <- readRDS("~/Documents/oleary/rest/demo_subsetlong.RDS")

fconex_demo <- merge(fconex, demo_subset.long, by = c('id','ses_ord')) %>%
  select(id, ses, ses_ord, time2_scanner, fd, group, sex, Race, Ethnicity, 
         V1_ParentHighestDegree, V1_ParentSES, age, everything())

write.table(fconex_demo, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/rest/fconex_demo.txt")

#########################################################################################################
###############################  ADD FOLLOW-UP SUBSTANCE USE  ###########################################
#########################################################################################################

# demo_subset.long created in substance/longitudinal_substance_new.R
substance_fin.long <- readRDS("~/Documents/oleary/rest/substance/substance_long.RDS")

finaldfex <- full_join(substance_fin.long, fconex_demo)

write.table(finaldfex, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/rest/finaldfex.txt")

saveRDS(finaldfex, "~/Documents/oleary/rest/finaldfex.RDS")
