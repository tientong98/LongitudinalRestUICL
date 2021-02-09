setwd("~/Documents/oleary/rest/")

#######################################################################################################
########################                      GET DATA                         ########################
#######################################################################################################

spss <- foreign::read.spss("~/Documents/oleary/Complete_Dataset_fix_missing_values_fixed_MJ_TB_Binge_FU_addAge.sav", 
                  to.data.frame = T, stringsAsFactors = F)

myvars <- c(
  "Subject_ID",
  "BingeGroup_5cat",
  "Sub_Gender.1",
  "age_time1",
  "age_time2",
  "Race",
  "Ethnicity",
  "V1_Mother_HighestDegree",
  "V2_Mother_HighestDegree",
  "V1_Father_HighestDegree",
  "V2_Father_HighestDegree",
  "V1_Mother_SES",
  "V2_Mother_SES",
  "V1_Father_SES",
  "V2_Father_SES")

demo <- spss[myvars]
levels(demo$BingeGroup_5cat) <- c("Control", "sBinge", "eBinge", "MJ+sBinge", "MJ+eBinge")
demo$V1_Mother_SES <- droplevels(demo$V1_Mother_SES, exclude="-9")
demo$V1_Father_SES <- droplevels(demo$V1_Father_SES, exclude="-9")

edufunc <- function(ses_variable){
  levels(demo[,ses_variable]) <- c("Less than high school", 
                                   "High school GED", 
                                   "High school diploma",
                                   "Some college", 
                                   "Trade school/technical school/training certificate",
                                   "Associates",
                                   "Bachelors",
                                   "Masters",
                                   "Doctorate")
  demo[,ses_variable] <- factor(demo[,ses_variable], ordered = TRUE)
  return(demo[,ses_variable])
}

demo$V1_Mother_HighestDegree <- edufunc("V1_Mother_HighestDegree")
demo$V2_Mother_HighestDegree <- edufunc("V2_Mother_HighestDegree")
demo$V1_Father_HighestDegree <- edufunc("V1_Father_HighestDegree")
demo$V2_Father_HighestDegree <- edufunc("V2_Father_HighestDegree")

sesfunc <- function(ses_variable){
  levels(demo[,ses_variable]) <- c("wealthy/top-rank social prestige",
                                  "professional/high rank manager",
                                  "white collar/skilled worker",
                                  "Semi-skilled worker/HS grad",
                                  "Unskilled/semi-skilled worker/elementary")
  demo[,ses_variable] <- forcats::fct_rev(factor(demo[,ses_variable], ordered = TRUE))
  return(demo[,ses_variable])
}

demo$V1_Mother_SES <- sesfunc("V1_Mother_SES")
demo$V2_Mother_SES <- sesfunc("V2_Mother_SES")
demo$V1_Father_SES <- sesfunc("V1_Father_SES")
demo$V2_Father_SES <- sesfunc("V2_Father_SES")

# missing value from ses 1, get infor from ses 2 - not do this for now
demo[98, "V1_Mother_SES"] <- "professional/high rank manager"
demo[98, "V1_Father_SES"] <- "professional/high rank manager"

# subset to get 119 subjects
demo_subset <-subset(demo, demo$Subject_ID %in% fconex$id)

# parent education and SES (choose higher number between father and mother)
demo_subset$V1_ParentHighestDegree <- 
  dplyr::if_else(demo_subset$V1_Mother_HighestDegree > demo_subset$V1_Father_HighestDegree,
         demo_subset$V1_ParentHighestDegree <- demo_subset$V1_Mother_HighestDegree,
         demo_subset$V1_ParentHighestDegree <- demo_subset$V1_Father_HighestDegree)

demo_subset$V1_ParentSES <- 
  dplyr::if_else(demo_subset$V1_Mother_SES > demo_subset$V1_Father_SES,
         demo_subset$V1_ParentSES <- demo_subset$V1_Mother_SES,
         demo_subset$V1_ParentSES <- demo_subset$V1_Father_SES)

demo_subset <- demo_subset %>% select(Subject_ID, BingeGroup_5cat, Sub_Gender.1, Race, Ethnicity,
                                      V1_ParentHighestDegree, V1_ParentSES, age_time1, age_time2) %>%
  rename(id = Subject_ID, group = BingeGroup_5cat, sex = Sub_Gender.1)


# wide to long
demo_subset.long <- reshape(demo_subset, direction='long', 
                              varying=c("age_time1",
                                        "age_time2"), 
                              timevar='ses_ord',
                              times=c(1, 2),
                              v.names=c("age"),
                              idvar=c('id'))
row.names(demo_subset.long) <- NULL

saveRDS(demo_subset.long, "~/Documents/oleary/rest/demo_subsetlong.RDS")
