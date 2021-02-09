#!/usr/bin/env Rscript
suppressPackageStartupMessages(require(optparse))
suppressPackageStartupMessages(require(dplyr))

# organize the re-calculated WM and CSF signals (from unsmoothed denoised BOLD) into a confound txt file - get ready for GLM
# Usage:/Shared/oleary/functional/UICL/BIDS/code/afterfMRIPrep_03makeconfound.R -s 3003 --ses 60307416 -d /Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep

option_list = list(
  optparse::make_option(c("-s", "--sub"), action="store", default=NA, type='character'),
  optparse::make_option(c("-v", "--vit"), action="store", default=NA, type='character'),
  optparse::make_option(c("-d", "--dir"), action="store", default=NA, type='character'))

opt = parse_args(OptionParser(option_list=option_list))

subject <- opt$s
session <- opt$v
fmriprepdir <- opt$d


csf <- read.table(paste0(fmriprepdir,"/sub-",subject,"/ses-",session,"/func/sub-",subject,"_ses-",session,"_task-rest_CSFts.txt"))  
wm <- read.table(paste0(fmriprepdir,"/sub-",subject,"/ses-",session,"/func/sub-",subject,"_ses-",session,"_task-rest_WMts.txt"))  
df <- merge(csf, wm, by = "row.names") 
df$Row.names <- as.numeric(df$Row.names)
df <- df %>% arrange(Row.names) %>% select(2,3)
  
write.table(df, file = paste0(fmriprepdir,"/sub-",subject,"/ses-",session,"/func/sub-",subject,"_ses-",session,"_task-rest_confound.txt"), sep = '\t', row.names = F, col.names = F, quote = F)
