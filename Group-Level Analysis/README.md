Codes for the group-level analysis

# 1. Clean up subject-level data, aggregate into a large dataframe

[01-clean_updateOct21.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/01-clean_updateOct21.R). For each subject:

  * Read in 3dNetcorr output
  * Add in missing rows/columns, so that all correlationmatrices from all subjects is 300x300. Have to do this because 3dNetcorr will exclude ROI with high signal dropout, resulting in missing rows/columns and matrices of different dimensions.
  * Calculate average correlation strength of between- and within-network connectivity blocks (91 blocks total, as the extended Power atlas has 13 networks)
  
  Then, create a 238 x 91 dataframe (119 subjects, each had 2 timepoints, data in long format). To this dataframe, add:
  
  * Group (initial grouping, determined by binge drinking pattern prior to the first in-lab session
  * Demographic info, created from [02-demo.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/02-demo.R)
  * Longitudinal substance use from the 24 months between the 2 in-lab sessions, created from [longitudinal_substance_new.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/longitudinal_substance_new.R)
  
# [2. Network-Level Connectivity](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/lmer_Dec28.Rmd)
 
AFNI 3dNetCorr (Taylor and Saad, 2013) was used to obtain the Fisher Z-transformed 300x300 correlation matrix for each participant. Within-network connectivity variables were calculated by averaging the correlations of all seeds affiliated with the same networks. Between-network connectivity variables were calculated by averaging the correlations of all seed-to-seed connections between different networks (off-diagonal portion of the matrix). 

8 a priori chosen networks: Cingulo-Opercular, Default Mode, Dorsal and Ventral Attention Network, Fronto-Parietal, Medial Temporal Lobe, Reward, Salience. 

8 within-network variables and 28 between-network variables were the outcome variables of the mixed-effects models testing the association between binge/extreme bingeing and change in network connectivity. For each model, fixed effects of interest were cumulative standard/extreme bingeing (log-transformed). Cumulative bingeing were calculated by adding up monthly bingeing reported during the 24 months after session 1. We added additional fixed effects to control for baseline grouping (Control, sBinge, eBinge), baseline age, session (time 1 vs. time 2), baseline age × session interaction, sex, scanner, SES, and frame-wise displacement (FD). Participant identifiers were added as random intercepts. Since the log-transformed cumulative standard and extreme bingeing were highly correlated (r=.80), these two variables were not entered in the same model. FDR correction for multiple comparison was run separately for each fixed effect of interest.

# 3. Edge-Level Connectivity

The connectome-based predictive modeling (CPM) was used to examine the association between bingeing with connectivity edges. The protocol was based on previous published methodology (Shen et al., 2017) and was run separately for standard and extreme bingeing. 

 * [cpm_flat-subtract.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/cpm_flat-subtract.R): Create Unique Edges x Subjects matrix, then subtract time 1 from time 2 data. For each subject, a 300x300 matrix has 44850 unique edges (excluding the diagonal).
 * [cpm_functions.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/cpm_functions.R): Leave-one-out CPM functions
 * [cpm_sbinge_0001_job.sh](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/cpm_sbinge_0001_job.sh): example of a CPM job submission on Argon cluster
 * [cpm_sbinge_0001.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/cpm_sbinge_0001.R): wrapper CPM function, applying to standard bingeing frequency, using p=.0001 threshold for CPM step 1
 * [perm_sbinge_0001.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/perm_sbinge_0001.R): permutation to test if prediction accuracy is significant with 500 permutation
 * [final_eval.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/final_eval.R): Examining CPM results
 
Connectivity changes were first calculated by subtracting time 1 from time 2 (code in [cpm_flat-subtract.R](https://github.com/tientong98/RestUICL/blob/main/Group-Level%20Analysis/cpm_flat-subtract.R)). Input data were thus composed of change in connectivity edges, cumulative standard/extreme bingeing, and confound variables including sex, SES, group, scanner (same or different scanners in the two sessions), and change (time 2 minus time 1) in age and FD. These input data were split into training/test sets using leave-one-out cross validation. 

The CPM protocol involved the following steps: 

 * 1) select important edges that demonstrate significant associations with bingeing using Spearman partial correlation
 * 2) fit a model using the training set and apply this model to predict bingeing from change in connectivity edges in the test set
 * 3) calculate model accuracy using the test sets across all cross-validation folds, and 
 * 4) determine if this model accuracy is significant using 500 permutations of the data to create the null distribution.

While the whole CPM protocol allowed us to test weather binge drinking can be predicted by connectivity edges using cross-validation, Step 1 from CPM allowed us to examine consistent patterns of this connectivity-binge drinking association. Specifically, the leave-one-out cross-validation created small perturbations of the sample, as there were 119 folds of cross-validation, and in each fold, 1 participant was excluded from the training set. Thus, the correlation between binge drinking and change in connectivity edges was calculated 119 times, with 1 participant being excluded each time. Edge connectivity changes were defined as showing a consistent pattern of association with cumulative bingeing if they significantly correlated with bingeing in all 119 cross-validation folds.
