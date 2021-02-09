setwd("~/Documents/oleary/rest/substance/")

library(foreign)
library(ggplot2)

all <- read.spss("~/Documents/oleary/Complete_Dataset_fix_missing_values_fixed_MJ_TB_Binge_FU_addAge.sav", 
                 to.data.frame = T, stringsAsFactors = F)

spss.varnames <- data.frame(names(all))
spss.varnames[grep("30Days", spss.varnames$names.all.), "names.all."]

past30days <- c("Subject_ID",
                "BingeGroup_5cat",
                "V1_DaysConsumed1To2Drinks_Past30Days",
                "DaysBingeDrinking_All_Past30Days",
                "DaysExtremeBingeDrinking_All_Past30Days",
                "V1_DaysFeltDrunk_Last30Days",
                "V1_TotalDaysUsedCannabis_Past30Days",          
                "V1_AvgAmountCannabisSmoked_Past30Days",         
                "V1_TotalDaysUsedTobacco_Past30Days",           
                "V1_AvgAmountTobaccoSmoked_Past30Days",  
                "V2_DaysConsumed1To2Drinks_Past30Days",          
                "V2_DaysBingeDrinking_Female_Past30Days",       
                "V2_DaysBingeDrinking_Male_Past30Days",          
                "V2_DaysExtremeBingeDrinking_Female_Past30Days",
                "V2_DaysExtremeBingeDrinking_Male_Past30Days",   
                "V2_DaysFeltDrunk_Last30Days",                  
                "V2_TotalDaysUsedCannabis_Past30Days",           
                "V2_AvgAmountCannabisSmoked_Past30Days",        
                "V2_TotalDaysUsedTobacco_Past30Days",            
                "V2_AvgAmountTobaccoSmoked_Past30Days")


# When you used cannabis during each time period below, 
# please indicate the average amount of cannabis you consumed in a 24 hour period. 
# Please use the events below to help you recall how often you used cannabis:
  
#  Instructions for "Average Amount Consumed In Sitting":
#  You may refer to the following common marijuana intake examples:
#  1 marijuana edible (such as a brownie) = 1
#  1 bowl = 1
#  1 joint = 1
#  1 blunt = 2

# When you used tobacco during each time period below, please indicate the average amount  you consumed over 24 hours. Respond with number of cigarettes, cigars, chews, or dips used. For Hookah quantities, please ask the research assistant for clarification.

pastmonth <- all[past30days] %>%
  rename(V1_DaysBingeDrinking_Past30Days = DaysBingeDrinking_All_Past30Days,
         V1_DaysExtremeBingeDrinking_Past30Days= DaysExtremeBingeDrinking_All_Past30Days)
pastmonth[pastmonth[,] == -9] <- 0
levels(pastmonth$BingeGroup_5cat) <- c("Control", "sBinge", "eBinge", "MJ+sBinge", "MJ+eBinge")

pastmonth$V2_DaysBingeDrinking_Past30Days <- ifelse(!is.na(pastmonth$V2_DaysBingeDrinking_Female_Past30Days),
                                                    pastmonth$V2_DaysBingeDrinking_Past30Days <- pastmonth$V2_DaysBingeDrinking_Female_Past30Days,
                                                    pastmonth$V2_DaysBingeDrinking_Past30Days <- pastmonth$V2_DaysBingeDrinking_Male_Past30Days)
pastmonth$V2_DaysExtremeBingeDrinking_Past30Days <- ifelse(!is.na(pastmonth$V2_DaysExtremeBingeDrinking_Female_Past30Days),
                                                           pastmonth$V2_DaysExtremeBingeDrinking_Past30Days <- pastmonth$V2_DaysExtremeBingeDrinking_Female_Past30Days,
                                                           pastmonth$V2_DaysExtremeBingeDrinking_Past30Days <- pastmonth$V2_DaysExtremeBingeDrinking_Male_Past30Days)


pastmonth_use <- pastmonth[c("Subject_ID",
                             "BingeGroup_5cat",
                             "V1_DaysBingeDrinking_Past30Days",
                             "V1_DaysExtremeBingeDrinking_Past30Days",
                             "V1_TotalDaysUsedCannabis_Past30Days",
                             "V1_TotalDaysUsedTobacco_Past30Days",
                             "V2_DaysBingeDrinking_Past30Days",
                             "V2_DaysExtremeBingeDrinking_Past30Days",
                             "V2_TotalDaysUsedCannabis_Past30Days",
                             "V2_TotalDaysUsedTobacco_Past30Days")]

pastmonth_use_subset <- subset(pastmonth_use,pastmonth_use$Subject_ID %in% fconex$id)
pastmonth_use_subset[is.na(pastmonth_use_subset)] <- 0

pastmonth_use_subset <- pastmonth_use_subset %>%
  rename(id = Subject_ID, group = BingeGroup_5cat)

saveRDS(pastmonth_use_subset, "~/Documents/oleary/rest/substance/pastmonth.RDS")


# CHANGE NA TO 0
# sum(is.na(pastmonth_use_subset$V1_DaysBingeDrinking_Past30Days)) # 0 missing
# sum(is.na(pastmonth_use_subset$V1_DaysExtremeBingeDrinking_Past30Days)) # 0 missing
# sum(is.na(pastmonth_use_subset$V1_TotalDaysUsedCannabis_Past30Days)) # 0 missing
# sum(is.na(pastmonth_use_subset$V1_TotalDaysUsedTobacco_Past30Days)) # 0 mssing
# 
# sum(is.na(pastmonth_use_subset$V2_DaysBingeDrinking_Past30Days)) # 114 NAs, but should only have 102 NA (221-119) -- 12 missing data points
# sum(is.na(pastmonth_use_subset$V2_DaysExtremeBingeDrinking_Past30Days)) # 114 NAs, but should only have 102 NA (221-119) -- 12 missing data points
# sum(is.na(pastmonth_use_subset$V2_TotalDaysUsedCannabis_Past30Days)) # 145 NAs, 43 missing
# sum(is.na(pastmonth_use_subset$V2_TotalDaysUsedTobacco_Past30Days)) # 154 NAs, 52


# CANNABIS AND TOBACCO: days * avg amount?
pastmonth$V1_AvgAmountCannabisSmoked_Past30Days <- ifelse(pastmonth$V1_TotalDaysUsedCannabis_Past30Days != 0,
       pastmonth$V1_AvgAmountCannabisSmoked_Past30Days <- pastmonth$V1_AvgAmountCannabisSmoked_Past30Days,
       pastmonth$V1_AvgAmountCannabisSmoked_Past30Days <- 0)
pastmonth$V1_Cannabis_Past30Days <- pastmonth$V1_TotalDaysUsedCannabis_Past30Days * pastmonth$V1_AvgAmountCannabisSmoked_Past30Days

pastmonth$V2_AvgAmountCannabisSmoked_Past30Days <- ifelse(pastmonth$V2_TotalDaysUsedCannabis_Past30Days != 0,
                                                          pastmonth$V2_AvgAmountCannabisSmoked_Past30Days <- pastmonth$V2_AvgAmountCannabisSmoked_Past30Days,
                                                          pastmonth$V2_AvgAmountCannabisSmoked_Past30Days <- 0)
pastmonth$V2_Cannabis_Past30Days <- pastmonth$V2_TotalDaysUsedCannabis_Past30Days * pastmonth$V2_AvgAmountCannabisSmoked_Past30Days

pastmonth$V1_AvgAmountTobaccoSmoked_Past30Days <- ifelse(pastmonth$V1_TotalDaysUsedTobacco_Past30Days != 0,
                                                         pastmonth$V1_AvgAmountTobaccoSmoked_Past30Days <- pastmonth$V1_AvgAmountTobaccoSmoked_Past30Days,
                                                         pastmonth$V1_AvgAmountTobaccoSmoked_Past30Days <- 0)
pastmonth$V1_Tobacco_Past30Days <- pastmonth$V1_TotalDaysUsedTobacco_Past30Days * pastmonth$V1_AvgAmountTobaccoSmoked_Past30Days

pastmonth$V2_AvgAmountTobaccoSmoked_Past30Days <- ifelse(pastmonth$V2_TotalDaysUsedTobacco_Past30Days != 0,
                                                         pastmonth$V2_AvgAmountTobaccoSmoked_Past30Days <- pastmonth$V2_AvgAmountTobaccoSmoked_Past30Days,
                                                         pastmonth$V2_AvgAmountTobaccoSmoked_Past30Days <- 0)
pastmonth$V2_Tobacco_Past30Days <- pastmonth$V2_TotalDaysUsedTobacco_Past30Days * pastmonth$V2_AvgAmountTobaccoSmoked_Past30Days


##############################################################################################################
##################################### 2 year follow up #######################################################
##############################################################################################################

# month 6 - 18 (first 12 months)
getFUdata <- function(pattern){
  if (pattern == "CannabisConsumption" | pattern == "TobaccoConsumption") {
    temp <- names(all)[grep(pattern, names(all))]
    temp2 <- sort(temp[grep("FU", temp)])
    sort(temp2[-grep("FormOf", temp2)])
    } else {
    temp <- names(all)[grep(pattern, names(all))]
    sort(temp[grep("FU", temp)])}
}

#not inlude DaysConsumed1To2Drinks
interested.pattern <- c("Consumed4To6Drinks",        
                        "ConsumedOver8Drinks",            
                        "CannabisConsumption",
                        "CannabisTimesPer",
                        "TobaccoConsumption",
                        "TobaccoTimesPer")

first12 <- lapply(interested.pattern, getFUdata)
first12 <- sort(unlist(first12))
         
followup_first12 <- all[c("Subject_ID",
                   "BingeGroup_5cat",
                   first12)] 
levels(followup_first12$BingeGroup_5cat) <- c("Control", "sBinge", "eBinge", "MJ+sBinge", "MJ+eBinge")


# last 12 months
getlast12data <- function(pattern){
  if (pattern == "CannabisConsumption" | pattern == "TobaccoConsumption") {
    temp <- names(all)[grep(pattern, names(all))]
    temp2 <- sort(temp[grep("V2Month", temp)])
    sort(temp2[-grep("FormOf", temp2)])
  } else {
    temp <- names(all)[grep(pattern, names(all))]
    sort(temp[grep("V2Month", temp)])}
}

#not inlude DaysConsumed1To2Drinks
last12 <- lapply(interested.pattern, getlast12data)
last12 <- sort(unlist(last12))

followup_last12 <- all[c("Subject_ID",
                          "BingeGroup_5cat",
                         last12)] 
levels(followup_last12$BingeGroup_5cat) <- c("Control", "sBinge", "eBinge", "MJ+sBinge", "MJ+eBinge")


followup <- full_join(followup_first12, followup_last12)

colnames(followup) <- sub("V2", "", colnames(followup))

colnames(followup) <- sub("FU6Month1", "Month01", colnames(followup))
colnames(followup) <- sub("FU6Month2", "Month02", colnames(followup))  
colnames(followup) <- sub("FU6Month3", "Month03", colnames(followup))  
colnames(followup) <- sub("FU6Month4", "Month04", colnames(followup))  
colnames(followup) <- sub("FU6Month5", "Month05", colnames(followup)) 
colnames(followup) <- sub("FU6Month6", "Month06", colnames(followup)) 


colnames(followup) <- sub("FU12Month7", "Month07", colnames(followup))
colnames(followup) <- sub("FU12Month8", "Month08", colnames(followup))
colnames(followup) <- sub("FU12Month9", "Month09", colnames(followup))
colnames(followup) <- sub("FU12Month10", "Month10", colnames(followup))
colnames(followup) <- sub("FU12Month11", "Month11", colnames(followup))
colnames(followup) <- sub("FU12Month12", "Month12", colnames(followup))
colnames(followup) <- sub("FU12Month1", "Month07", colnames(followup))
colnames(followup) <- sub("FU12Month2", "Month08", colnames(followup))  
colnames(followup) <- sub("FU12Month3", "Month09", colnames(followup))  
colnames(followup) <- sub("FU12Month4", "Month10", colnames(followup))  
colnames(followup) <- sub("FU12Month5", "Month11", colnames(followup)) 
colnames(followup) <- sub("FU12Month6", "Month12", colnames(followup))


colnames(followup) <- sub("FU18Month13", "Month13", colnames(followup))
colnames(followup) <- sub("FU18Month14", "Month14", colnames(followup))
colnames(followup) <- sub("FU18Month15", "Month15", colnames(followup))
colnames(followup) <- sub("FU18Month16", "Month16", colnames(followup))
colnames(followup) <- sub("FU18Month17", "Month17", colnames(followup))
colnames(followup) <- sub("FU18Month18", "Month18", colnames(followup))
colnames(followup) <- sub("FU18Month1", "Month13", colnames(followup))
colnames(followup) <- sub("FU18Month2", "Month14", colnames(followup))  
colnames(followup) <- sub("FU18Month3", "Month15", colnames(followup))  
colnames(followup) <- sub("FU18Month4", "Month16", colnames(followup))  
colnames(followup) <- sub("FU18Month5", "Month17", colnames(followup)) 
colnames(followup) <- sub("FU18Month6", "Month18", colnames(followup)) 


followup <- followup[c("Subject_ID", "BingeGroup_5cat",
                       sort((names(followup)[3:242])))] %>%
  rename(id = Subject_ID, group = BingeGroup_5cat)

############################ standard bingeing ###################################

sbingenames <- names(followup)[grep("Consumed4To6Drinks", names(followup))]
followup_sbinge <- followup[c("id", "group", sbingenames)]
followup_sbinge <- subset(followup_sbinge, followup_sbinge$id %in% fconex$id)

combine_func <- function(x){
  as.numeric(as.character(x))
}
followup_sbinge[,3:26] <- sapply(followup_sbinge[,3:26], combine_func)

sub <- unique(followup_sbinge$id)

for (i in 1:length(sub)) {
  subdata <- followup_sbinge %>% filter(id == sub[i])
  min.sbinge <- min(subdata[3:26], na.rm = T)
  max.sbinge <- max(subdata[3:26], na.rm = T)
  median.sbinge <- median(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  mean.sbinge <- mean(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  sd.sbinge <- sd(subdata[3:26], na.rm = T)
  sum.sbinge <- sum(subdata[3:26], na.rm = T)
  recent_6month.sbinge <- mean(as.numeric(as.vector(subdata[21:26])), na.rm = T) #19-24
  
  id <- subdata$id[1]
  save <- data.frame(id,
                     min.sbinge,
                     max.sbinge,
                     median.sbinge,
                     mean.sbinge,
                     sd.sbinge,
                     sum.sbinge,
                     recent_6month.sbinge)
  
  write.table(save, row.names = F, col.names = !file.exists("~/Documents/oleary/rest/substance/sbinge.tsv"), 
              sep = "\t", quote = F, file = "~/Documents/oleary/rest/substance/sbinge.tsv", append = T)
  
}


################################## extreme bingeing ############################################

ebingenames <- names(followup)[grep("ConsumedOver8Drinks", names(followup))]
followup_ebinge <- followup[c("id", "group", ebingenames)]
followup_ebinge <- subset(followup_ebinge, followup_ebinge$id %in% fconex$id)

followup_ebinge[,3:26] <- sapply(followup_ebinge[,3:26], combine_func)

for (i in 1:length(sub)) {
  subdata <- followup_ebinge %>% filter(id == sub[i])
  min.ebinge <- min(subdata[3:26], na.rm = T)
  max.ebinge <- max(subdata[3:26], na.rm = T)
  median.ebinge <- median(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  mean.ebinge <- mean(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  sd.ebinge <- sd(subdata[3:26], na.rm = T)
  sum.ebinge <- sum(subdata[3:26], na.rm = T)
  recent_6month.ebinge <- mean(as.numeric(as.vector(subdata[21:26])), na.rm = T)
  
  id <- subdata$id[1]
  save <- data.frame(id,
                     min.ebinge,
                     max.ebinge,
                     median.ebinge,
                     mean.ebinge,
                     sd.ebinge,
                     sum.ebinge,
                     recent_6month.ebinge)
  
  write.table(save, row.names = F, col.names = !file.exists("~/Documents/oleary/rest/substance/ebinge.tsv"), 
              sep = "\t", quote = F, file = "~/Documents/oleary/rest/substance/ebinge.tsv", append = T)
  
}

######################################## cannabis ###############################################

mjnames <- names(followup)[grep("CannabisConsumptionPerMonth", names(followup))]
followup_mjnames <- followup[c("id", "group", mjnames)]
followup_cannabis <- subset(followup_mjnames, followup_mjnames$id %in% fconex$id)

followup_cannabis[,3:26] <- sapply(followup_cannabis[,3:26], combine_func)

for (i in 1:length(sub)) {
  subdata <- followup_cannabis %>% filter(id == sub[i])
  min.cannabis <- min(subdata[3:26], na.rm = T)
  max.cannabis <- max(subdata[3:26], na.rm = T)
  median.cannabis <- median(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  mean.cannabis <- mean(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  sd.cannabis <- sd(subdata[3:26], na.rm = T)
  sum.cannabis <- sum(subdata[3:26], na.rm = T)
  recent_6month.cannabis <- mean(as.numeric(as.vector(subdata[21:26])), na.rm = T)
  month.use.cannabis <- sum(subdata[,3:26]!=0, na.rm = T)
  
  id <- subdata$id[1]
  save <- data.frame(id,
                     min.cannabis,
                     max.cannabis,
                     median.cannabis,
                     mean.cannabis,
                     sd.cannabis,
                     sum.cannabis,
                     recent_6month.cannabis,
                     month.use.cannabis)
  
  write.table(save, row.names = F, col.names = !file.exists("~/Documents/oleary/rest/substance/cannabis.tsv"), 
              sep = "\t", quote = F, file = "~/Documents/oleary/rest/substance/cannabis.tsv", append = T)
}

######################################## tobacco ###############################################

tobnames <- names(followup)[grep("TobaccoConsumptionPerMonth", names(followup))]
followup_tobnames <- followup[c("id", "group", tobnames)]
followup_tobacco <- subset(followup_tobnames, followup_tobnames$id %in% fconex$id)

followup_tobacco[,3:26] <- sapply(followup_tobacco[,3:26], combine_func)

for (i in 1:length(sub)) {
  subdata <- followup_tobacco %>% filter(id == sub[i])
  min.tobacco <- min(subdata[3:26], na.rm = T)
  max.tobacco <- max(subdata[3:26], na.rm = T)
  median.tobacco <- median(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  mean.tobacco <- mean(as.numeric(as.vector(subdata[3:26])), na.rm = T)
  sd.tobacco <- sd(subdata[3:26], na.rm = T)
  sum.tobacco <- sum(subdata[3:26], na.rm = T)
  recent_6month.tobacco <- mean(as.numeric(as.vector(subdata[21:26])), na.rm = T)
  month.use.tobacco <- sum(subdata[,3:26]!=0, na.rm = T)
  
  id <- subdata$id[1]
  save <- data.frame(id,
                     min.tobacco,
                     max.tobacco,
                     median.tobacco,
                     mean.tobacco,
                     sd.tobacco,
                     sum.tobacco,
                     recent_6month.tobacco,
                     month.use.tobacco)
  
  write.table(save, row.names = F, col.names = !file.exists("~/Documents/oleary/rest/substance/tobacco.tsv"), 
              sep = "\t", quote = F, file = "~/Documents/oleary/rest/substance/tobacco.tsv", append = T)
  
}

sbingeFU <- read.table("~/Documents/oleary/rest/substance/sbinge.tsv", header = T, sep = "\t")
ebingeFU <- read.table("~/Documents/oleary/rest/substance/ebinge.tsv", header = T, sep = "\t")
cannabisFU <- read.table("~/Documents/oleary/rest/substance/cannabis.tsv", header = T, sep = "\t")
tobaccoFU <- read.table("~/Documents/oleary/rest/substance/tobacco.tsv", header = T, sep = "\t")

substance_fin <- Reduce(function(x,y) merge(x = x, y = y, by = "id"), 
       list(pastmonth_use_subset, sbingeFU, ebingeFU, cannabisFU, tobaccoFU))

substance_fin.long <- reshape(substance_fin, direction='long', 
                              varying=c("V1_DaysBingeDrinking_Past30Days",
                                        "V1_DaysExtremeBingeDrinking_Past30Days",
                                        "V1_TotalDaysUsedCannabis_Past30Days",
                                        "V1_TotalDaysUsedTobacco_Past30Days",
                                        "V2_DaysBingeDrinking_Past30Days",
                                        "V2_DaysExtremeBingeDrinking_Past30Days",
                                        "V2_TotalDaysUsedCannabis_Past30Days",
                                        "V2_TotalDaysUsedTobacco_Past30Days"), 
                              timevar='ses_ord',
                              times=c(1, 2),
                              v.names=c("DaysBingeDrinking_Past30Days",
                                        "DaysExtremeBingeDrinking_Past30Days",
                                        "DaysUsedCannabis_Past30Days",
                                        "DaysUsedTobacco_Past30Days"),
                              idvar=c('id')) %>%
  select(id, group, ses_ord, DaysBingeDrinking_Past30Days, DaysExtremeBingeDrinking_Past30Days,
         DaysUsedCannabis_Past30Days, DaysUsedTobacco_Past30Days, everything())


saveRDS(substance_fin, "~/Documents/oleary/rest/substance/substance_wide.RDS")
saveRDS(substance_fin.long, "~/Documents/oleary/rest/substance/substance_long.RDS")

write.table(followup, row.names = F, col.names = T, sep = "\t", quote = F, 
            file = "~/Documents/oleary/rest/substance/followup.txt")
