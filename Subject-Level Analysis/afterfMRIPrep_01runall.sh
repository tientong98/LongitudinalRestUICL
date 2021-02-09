#!/bin/bash

# run all the necessary steps after fMRIPrep

################################################## Time 1 only #######################################################

subid_time1=($(cut -f1 /Shared/oleary/functional/UICL/BIDS/subject_list/time1only.txt))
sesid_time1=($(cut -f2 /Shared/oleary/functional/UICL/BIDS/subject_list/time1only.txt))
fmriprepdir_time1=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest/fmriprep
outputdir_time1=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/time1only
codedir=/Shared/oleary/functional/UICL/BIDS/code

for index in "${!subid_time1[@]}" ; do

  sh $codedir/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh \
    -s ${subid_time1[$index]} \
    -v ${sesid_time1[$index]} \
    -d ${fmriprepdir_time1}

  $codedir/afterfMRIPrep_03makeconfound.R \
    -s ${subid_time1[$index]} \
    -v ${sesid_time1[$index]} \
    -d ${fmriprepdir_time1}

  sh $codedir/afterfMRIPrep_04ROIts.sh \
    -s ${subid_time1[$index]} \
    -v ${sesid_time1[$index]} \
    -d ${fmriprepdir_time1} \
    -o ${outputdir_time1}

done

################################################## Two Visits Siemens - Visit 2 #######################################################

subid_twovisitSiemens=($(cut -f2 /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))
sesid_twovisitSiemens=($(cut -f3 /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))
fmriprepdir_twovisitSiemens=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep
outputdir_twovisitSiemens=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/twovisitSiemens
codedir=/Shared/oleary/functional/UICL/BIDS/code

for index in "${!subid_twovisitSiemens[@]}" ; do

  sh $codedir/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens}

  $codedir/afterfMRIPrep_03makeconfound.R \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens}

  sh $codedir/afterfMRIPrep_04ROIts.sh \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens} \
    -o ${outputdir_twovisitSiemens}

done

################################################## Two Visits Siemens - Visit 1 #######################################################

subid_twovisitSiemens=($(cut -f2 /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))
sesid_twovisitSiemens=($(cut -f4 /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))
fmriprepdir_twovisitSiemens=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep
outputdir_twovisitSiemens=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/twovisitSiemens
codedir=/Shared/oleary/functional/UICL/BIDS/code

for index in "${!subid_twovisitSiemens[@]}" ; do

  sh $codedir/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens}

  $codedir/afterfMRIPrep_03makeconfound.R \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens}

  sh $codedir/afterfMRIPrep_04ROIts.sh \
    -s ${subid_twovisitSiemens[$index]} \
    -v ${sesid_twovisitSiemens[$index]} \
    -d ${fmriprepdir_twovisitSiemens} \
    -o ${outputdir_twovisitSiemens}

done

################################################## Two Visits GE - Visit 2 #######################################################

subid_twovisitGE=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))
sesid_twovisitGE=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))
fmriprepdir_twovisitGE=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep
outputdir_twovisitGE=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/twovisitGE
codedir=/Shared/oleary/functional/UICL/BIDS/code

for index in "${!subid_twovisitGE[@]}" ; do

  sh $codedir/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE}

  $codedir/afterfMRIPrep_03makeconfound.R \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE}

  sh $codedir/afterfMRIPrep_04ROIts.sh \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE} \
    -o ${outputdir_twovisitGE}

done

################################################## Two Visits GE - Visit 1 #######################################################

subid_twovisitGE=($(cut -f2 /Shared/oleary/functional/UICL/BIDS/code/time2/ge_time1time2.txt))
sesid_twovisitGE=($(cut -f4 /Shared/oleary/functional/UICL/BIDS/code/time2/ge_time1time2.txt))
fmriprepdir_twovisitGE=/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep
outputdir_twovisitGE=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/twovisitGE
codedir=/Shared/oleary/functional/UICL/BIDS/code

for index in "${!subid_twovisitGE[@]}" ; do

  sh $codedir/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE}

  $codedir/afterfMRIPrep_03makeconfound.R \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE}

  sh $codedir/afterfMRIPrep_04ROIts.sh \
    -s ${subid_twovisitGE[$index]} \
    -v ${sesid_twovisitGE[$index]} \
    -d ${fmriprepdir_twovisitGE} \
    -o ${outputdir_twovisitGE}

done
