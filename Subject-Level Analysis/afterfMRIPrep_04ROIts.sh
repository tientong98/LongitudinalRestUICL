#!/bin/bash
function Usage {
    cat <<USAGE
`basename $0` run nuisance regression (mean WM, CSF), bandpass, then normalizing and scaling residualized and bandpassed BOLD. Lastly, calculate get correlation matrices
Usage:
`basename $0`  -s subject_id -v study_visit -d fmriprep_dir -o output_dir
               -h <help>
Example:
  bash $0 -s 3003 -v 60307416 -d /Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep \
	  -o /Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest
Arguments:
  -s subject_id    The subject id
  -d fmriprep_dir  The fMRIPrep base output directory
  -v study_visit   The session id
  -o output_dir    The output directory
  -h help
USAGE
    exit 1
}

# Parse input operators -------------------------------------------------------
while getopts "s:v:d:o:h" option
do
case "${option}"
in
  s) # subject_id
    subid=${OPTARG}
    ;;
  v) # study_visit
    sesid=${OPTARG}
    ;;
  d) # fmriprep_dir
    fmriprepdir=${OPTARG}
    ;;
  o) # output_dir
    outdir=${OPTARG}
    ;;
  h) # help
    Usage >&2
    exit 0
    ;;
  *) # unknown options
    echo "ERROR: Unrecognized option -$OPT $OPTARG"
    exit 1
    ;;
esac
done

export FSLDIR="/Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/5.0.8/"
. ${FSLDIR}/etc/fslconf/fsl.sh
export PATH=${PATH}:${FSLDIR}/bin
export PATH=$PATH:/Shared/pinc/sharedopt/apps/afni/Linux/x86_64/20.0.03


# script was modified from https://github.com/mwvoss/RestingState/blob/master/removeNuisanceRegressor.sh#L147


##################################### NUISANCE REGRESSION AND BANDPASS #########################################

mkdir -p $outdir/sub-${subid}/ses-${sesid}

3dTproject \
    -input $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz \
    -prefix $outdir/sub-${subid}/ses-${sesid}/tmp_bp.nii.gz \
    -automask -bandpass 0.009 0.08 \
    -ort $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_confound.txt -verb &&\

# add mean back in more details in the links below
# https://github.com/HBClab/RestingState/issues/111
# https://afni.nimh.nih.gov/afni/community/board/read.php?1,84353,84356

3dTstat \
    -mean \
    -prefix $outdir/sub-${subid}/ses-${sesid}/orig_mean.nii.gz \
    $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz &&\

3dcalc \
    -a $outdir/sub-${subid}/ses-${sesid}/tmp_bp.nii.gz \
    -b $outdir/sub-${subid}/ses-${sesid}/orig_mean.nii.gz \
    -expr "a+b" -prefix ${outdir}/sub-${subid}/ses-${sesid}/bp_res4d.nii.gz

################################################ Post-regression data-scaling ########################################

3dAutomask \
    -prefix ${outdir}/sub-${subid}/ses-${sesid}/mask.nii.gz \
    ${outdir}/sub-${subid}/ses-${sesid}/bp_res4d.nii.gz

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/mask.nii.gz \
    -mul 1000 ${outdir}/sub-${subid}/ses-${sesid}/mask1000.nii.gz \
    -odt float

####################################################### normalize res4d here ##########################################

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/bp_res4d.nii.gz \
    -Tmean \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_tmean

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/bp_res4d.nii.gz \
    -Tstd \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_std

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/bp_res4d.nii.gz \
    -sub ${outdir}/sub-${subid}/ses-${sesid}/res4d_tmean \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_dmean

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_dmean \
    -div ${outdir}/sub-${subid}/ses-${sesid}/res4d_std \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_normed

fslmaths \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_normed \
    -add ${outdir}/sub-${subid}/ses-${sesid}/mask1000.nii.gz \
    ${outdir}/sub-${subid}/ses-${sesid}/res4d_normandscaled \
    -odt float


# reorient roi masks from RPI to LPI
#3dresample -master /oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest/sub-3004/ses-60642114/res4d_normandscaled.nii.gz -prefix /oleary/atlas/greeneatlas/greene300LPI.nii.gz -input /oleary/atlas/greeneatlas/greene300.nii.gz


####################################################### get time series from ROIs ######################################################
# cite Taylor PA, Saad ZS (2013).  FATCAT: (An Efficient) Functional And Tractographic Connectivity Analysis Toolbox. Brain Connectivity 3(5):523-535.

3dNetCorr \
 -inset $outdir/sub-${subid}/ses-${sesid}/res4d_normandscaled.nii.gz \
 -in_rois /Shared/oleary/atlas/greeneatlas/greene300LPI.nii.gz \
 -mask $outdir/sub-${subid}/ses-${sesid}/mask.nii.gz -fish_z \
 -prefix $outdir/sub-${subid}/ses-${sesid}/sub-${subid}_ses-${sesid}_extendedPower         
  
