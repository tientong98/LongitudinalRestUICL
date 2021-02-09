#!/bin/bash
function Usage {
    cat <<USAGE
`basename $0` will create a BOLD that is motion corrected, slice timing corrected, denoised non-aggressively with ICA_AROMA but NOT SMOOTHED, then extract average WM and CSF timeseries
Usage:
`basename $0`  -s subject_id -v study_visit -d fmriprep_dir
               -h <help>
Example:
  bash $0 -s 3003 -v 60307416 -d /Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep
Arguments:
  -s subject_id    The subject id
  -d fmriprep_dir  The fMRIPrep base output directory
  -v study_visit   The session id
  -h help
USAGE
    exit 1
}

# Parse input operators -------------------------------------------------------
while getopts “s:v:d:h” OPTION
do
  case $OPTION in
  s) # subject_id
    subid=${OPTARG}
    ;;
  v) # study_visit
    sesid=${OPTARG}
    ;;
  d) # fmriprep_dir
    fmriprepdir=${OPTARG}
    ;;
  h) # help
    Usage >&2
    exit 0
    ;;
  *) # unknown options
    echo "ERROR: Unrecognized option $OPTION $OPTARG"
    exit 1
    ;;
  esac
done


export FSLDIR="/Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.8/"
. ${FSLDIR}/etc/fslconf/fsl.sh
export PATH=${PATH}:${FSLDIR}/bin
export PATH=$PATH:/Shared/pinc/sharedopt/apps/afni/Linux/x86_64/20.0.03



# created a BOLD that is motion corrected, slice timing corrected, denoised non-aggressively with ICA_AROMA but NOT SMOOTHED
fsl_regfilt -i $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz \
    -f $(cat $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_AROMAnoiseICs.csv) \
    -d $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_desc-MELODIC_mixing.tsv \
    -o $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-unsmoothAROMAnonaggr_bold.nii.gz

# create WM and CSF rois with voxels that are >= 95% probabilty to be in WM/CSF
fslmaths \
    $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-CSF_probseg.nii.gz \
    -thr 0.95 -bin \
    $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-CSF_probseg95.nii.gz

fslmaths \
    $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-WM_probseg.nii.gz \
    -thr 0.95 -bin \
    $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-WM_probseg95.nii.gz

# resample WM and CSF rois to non-aggressively denoised unsmoothed BOLD registered to MNI
3dresample \
    -master $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-unsmoothAROMAnonaggr_bold.nii.gz \
    -prefix $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-CSF_probseg95BOLD.nii.gz \
    -input $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-CSF_probseg95.nii.gz

3dresample \
    -master $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-unsmoothAROMAnonaggr_bold.nii.gz \
    -prefix $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-WM_probseg95BOLD.nii.gz \
    -input $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-WM_probseg95.nii.gz

# get WM and CSF time series
3dmaskave \
    -mask $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-CSF_probseg95BOLD.nii.gz \
    -quiet \
    $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-unsmoothAROMAnonaggr_bold.nii.gz > $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_CSFts.txt

3dmaskave \
    -mask $fmriprepdir/sub-${subid}/anat/sub-${subid}_space-MNI152NLin6Asym_label-WM_probseg95BOLD.nii.gz \
    -quiet \
    $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-unsmoothAROMAnonaggr_bold.nii.gz > $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_WMts.txt

