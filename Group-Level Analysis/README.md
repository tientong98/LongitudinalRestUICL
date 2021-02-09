Codes for the group-level analysis

# 1. Clean up subject-level data, aggregate into a large dataframe

[01-clean_updateOct21.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/01-clean_updateOct21.R). For each subject:

  * Read in 3dNetcorr output
  * Add in missing rows/columns, so that all correlationmatrices from all subjects is 300x300. Have to do this because 3dNetcorr will exclude ROI with high signal dropout, resulting in missing rows/columns and matrices of different dimensions.
  * Calculate average correlation strength of between- and within-network connectivity blocks (91 blocks total, as the extended Power atlas has 13 networks)
  
  Then, create a 238 x 91 dataframe (119 subjects, each had 2 timepoints, data in long format)
