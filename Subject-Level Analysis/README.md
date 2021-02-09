
Section List

1. [BIDS Conversion Using Heudiconv](#1-bids-conversion-using-heudiconv)
2. [Check slice timing for Time 2 data](#2-check-slice-timing-for-time-2-data)
3. [Exclude dummy TRs](#3-exclude-dummy-trs)
4. [Test phase encoding direction](#4-test-phase-encoding-direction)
5. [Run FMRIPREP](#5-run-fmriprep)
6. [Run MRIQC](#6-run-mriqc)
7. [Create masks for the extended Power ROI](#7-create-masks-for-the-extended-power-roi)
8. [Post-processing after fMRIPrep: Regression, Filter, ROI timeseries extraction](#8-post-processing-after-fmriprep)


# 1. BIDS Conversion Using Heudiconv

[Heudiconv.ipynb](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/Heudiconv.ipynb)
 
# 2. Check slice timing for Time 2 data

First for data from the Siemens


```bash
%%bash

# if json file didn't include slice timing, echo subid

sub=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))
ses=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt))

bidsdir=/Shared/oleary/functional/UICL/BIDS/rawdata

for n in `seq -s " " 0 1 21` ; do

  json=$bidsdir/sub-${sub[$n]}/ses-${ses[$n]}/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.json

  if ! grep -q "SliceTiming" $json ; then
      echo ${sub[$n]}_${ses[$n]}
  fi

done

# 3011_63029716 USE GE
```

run the [`get_slice_time.py`](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/get_slice_time.py) script to get the slice timing information for GE scanner.

```
usage: python /path/to/get_slice_time.py /path/to/dicom/pattern* /out/path

python /Shared/oleary/functional/UICL/BIDS/code/get_slice_time.py "/Shared/oleary/functional/UICL/dicomdata/3040/63910816/FMRI_004/63910816_004_*" "/Shared/oleary/functional/UICL/BIDS/code/time2/"

```

Then add slice timing infor for GE


```bash
%%bash

sub=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))
ses=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))

bidsdir=/Shared/oleary/functional/UICL/BIDS/rawdata

for n in `seq -s " " 0 1 97` ; do
    json=$bidsdir/sub-${sub[$n]}/ses-${ses[$n]}/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.json
    slicetimetxt=/Shared/oleary/functional/UICL/BIDS/code/time2/SliceTiming.json

    if ! grep -q "SliceTiming" $json ; then
        echo ${sub[$n]}_${ses[$n]} "needs SliceTiming info, adding now"
        chmod 777 $json
        cat $slicetimetxt '\n' >> $json `# this paste things weiredly, have to fix with sed below`
    else
        echo "already had SliceTiming info, moving on"
    fi

    sed -i 's/'}{'/',\\n'/g' $json

done
```

Check all 119 to see if anybody doesn't have slice time info


```bash
%%bash

sub=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses.txt))
ses=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses.txt))

bidsdir=/Shared/oleary/functional/UICL/BIDS/rawdata

for n in `seq -s " " 0 1 118` ; do
    json=$bidsdir/sub-${sub[$n]}/ses-${ses[$n]}/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.json
    slicetimetxt=/Shared/oleary/functional/UICL/BIDS/code/time2/SliceTiming.json

    if ! grep -q "SliceTiming" $json ; then
        echo ${sub[$n]}_${ses[$n]} "needs SliceTiming info"
    else
        echo "already had SliceTiming info, moving on"
    fi

done
```

# 3. Exclude dummy TRs

Once you get the data in BIDS format, you need to get rid of the dummy TRs at the beginning of the run BEFORE running FMRIPREP

Run [exclude_first_TRs.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/exclude_first_TRs.sh). For the resting state scanes in UICL, we will exclude the first 3 TRs (6 seconds)

Remember to make a note of this in a task json file (/oleary/functional/UICL/BIDS/task-rest_bold.json) in the following fields:

`"NumberOfVolumesDiscardedByUser": 3,
"NumberOfVolumesDiscardedByScanner": 2,`

Rest data = 177 volumes x 2s TR = 354s = 5.9 mins

**Time 2**

[exclude_first_TRs_time2.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/exclude_first_TRs_time2.sh)

Check if the non-steady state timepoints have been removed for everybody


```bash
%%bash

sub=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses.txt))
ses=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses.txt))

bidsdir=/Shared/oleary/functional/UICL/BIDS/rawdata

for n in `seq -s " " 0 1 118` ; do
    rest=$bidsdir/sub-${sub[$n]}/ses-${ses[$n]}/func/sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.nii.gz
    x=$(fslnvols $rest)

    if [ $x  == 177 ] ; then
    echo "Non-steady state timepoints were already removed"
    fi
done
```

# 4. Test phase encoding direction

"PhaseEncodingDirection": "j-" but is AP


```python
# test with dcm2niix
# Siemens resting state time 1
/Shared/pinc/sharedopt/apps/dcm2niix/Linux/x86_64/1.0.20190902/dcm2niix \
-z y -f %s -o ./ \
/Shared/oleary/functional/UICL/dicomdata/3040/64069714/FMRI_003/

# GE resting state time 2
/Shared/pinc/sharedopt/apps/dcm2niix/Linux/x86_64/1.0.20190902/dcm2niix \
-z y -f %s -o ./ \
/Shared/oleary/functional/UICL/dicomdata/3040/63910816/FMRI_004/
```


```python
# test with Joel's script

source /raid0/homes/tientong/sourcefiles/afni_source.sh
source /raid0/homes/tientong/sourcefiles/fsl_source.sh
source /raid0/homes/tientong/sourcefiles/freesurfer_source.sh
source /raid0/homes/tientong/sourcefiles/gdcm_source.sh

bash /Shared/oleary/functional/UICL/BIDS/code/GE_dcm_to_nii.sh \
-i /Shared/oleary/functional/UICL/dicomdata/3040/63910816/FMRI_004/ \
-o /Shared/oleary/functional/UICL/BIDS/code -B -v

# PhaseEncodingDirection=AP
```


```python
from nipype.utils.filemanip import loadpkl
path = "/Shared/oleary/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep_wf/single_subject_3040_wf/func_preproc_ses_63910816_task_rest_wf/ica_aroma_wf/ica_aroma_confound_extraction/"
res = loadpkl(path + 'result_ica_aroma_confound_extraction.pklz')
res
```

{'in_file': '/mnt/functional/UICL/BIDS/derivatives/fmriprep/rest_time2/fmriprep_wf/single_subject_3203_wf/func_preproc_ses_61778918_task_rest_wf/bold_bold_trans_wf/merge/vol0000_xform-00000_merged.nii.gz',
 'mc_method': 'AFNI'}

# 5. Run FMRIPREP

Note: As of Sep 5 2019 fmriprep version 1.4.1 the ANTs command for fieldmap-less distortion correction (`--use-syn-sdc`) didn't work with the new MNI152 template (details here https://github.com/poldracklab/fmriprep/issues/1665)

Therefore for UICL time 1 resting state data, this option was turned OFF.


```python
# pull the lastest version of fmriprep

singularity pull docker://poldracklab/fmriprep:<version number>
        
# First create a template file for submitting jobs on argon


#!/bin/sh
#$ -pe smp 10
#$ -q PINC,UI,CCOM
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/fmriprep/out/rest
#$ -e /Users/tientong/logs/uicl/fmriprep/err/rest
OMP_NUM_THREADS=8 
singularity run -H /Users/tientong/singularity_home \
-B /Shared/oleary/:/mnt \
/Users/tientong/poldracklab_fmriprep_1.4.1-2019-07-09-86bf8bc4b7d5.img \
/mnt/functional/UICL/BIDS \
/mnt/functional/UICL/BIDS/derivatives/fmriprep/rest \
participant --participant-label SUBJECT --skip_bids_validation \
-t rest --fs-license-file /mnt/functional/FreeSurferLicense/license.txt --fs-no-reconall \
-w /mnt/functional/UICL/BIDS/derivatives/fmriprep/rest --write-graph \
--use-aroma --error-on-aroma-warnings --output-spaces T1w func MNI152NLin6Asym:res-2 --stop-on-first-crash \
--omp-nthreads 8 --nthreads 8 --mem_mb 22500 --notrack
```


```bash
%%bash

# then run this on argon

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects.txt | tr '\n' ' ') ; do
sed -e "s|SUBJECT|${sub}|" fmriprep_rest_TEMPLATE.job > fmriprep_rest_sub-${sub}.job
done

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/subjects.txt | tr '\n' ' ') ; do
    nohup qsub fmriprep_rest_sub-${sub}.job
done 
```

### FMRIPREP Time 2

template file


```bash
%%bash

#!/bin/sh
#$ -pe smp 10
#$ -q PINC,UI,CCOM
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/fmriprep/out/rest_time2
#$ -e /Users/tientong/logs/uicl/fmriprep/err/rest_time2
OMP_NUM_THREADS=8
singularity run -H /Users/tientong/singularity_home \
-B /Shared/oleary/:/mnt \
/Users/tientong/poldracklab_fmriprep_1.4.1-2019-07-09-86bf8bc4b7d5.img \
/mnt/functional/UICL/BIDS \
/mnt/functional/UICL/BIDS/derivatives/fmriprep/rest \
participant --participant-label SUBJECT --skip_bids_validation \
-t rest --fs-license-file /mnt/functional/FreeSurferLicense/license.txt --fs-no-reconall \
-w /mnt/functional/UICL/BIDS/derivatives/fmriprep/rest --write-graph \
--use-aroma --error-on-aroma-warnings --output-spaces T1w MNI152NLin6Asym:res-2 --stop-on-first-crash \
--omp-nthreads 8 --nthreads 8 --mem_mb 22500 --notrack
```
submit fMRIPrep jobs on Argon

```bash
# then run this on argon

for sub in $(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt) ; do
  sed -e "s|SUBJECT|${sub}|" fmriprep_rest_TEMPLATE.job > fmriprep_rest_sub-${sub}.job
  nohup qsub fmriprep_rest_sub-${sub}.job
done
 
```
### 5.1. Get Framewise Displacement and counts of excessive movements (> 3mm)

(get_fd.R)[https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/get_fd.R]
(get_movement.R)[https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/get_movement.R]

# 6. Run MRIQC


```bash
# pull the lastest version of mriqc

singularity pull docker://poldracklab/mriqc:<version number>

# run the code below on Argon

#!/bin/sh
#$ -pe smp 10
#$ -q PINC,UI,CCOM
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/mriqc/out
#$ -e /Users/tientong/logs/uicl/mriqc/err

singularity run -H /Users/tientong/singularity_home \
/Users/tientong/mriqc_0.15.1.sif \
/Shared/oleary/functional/UICL/BIDS/rawdata \
/Shared/oleary/functional/UICL/BIDS/derivatives/mriqc \
participant --participant_label SUBJECT --no-sub -m T1w \
-w /Shared/oleary/functional/UICL/BIDS/derivatives/mriqc \
--verbose-reports --write-graph \
--n_procs 8 --mem_gb 22 --profile
```


```bash
#!/bin/sh
#$ -pe smp 10
#$ -q PINC,UI,CCOM
#$ -m e
#$ -M tien-tong@uiowa.edu
#$ -o /Users/tientong/logs/uicl/mriqc/out
#$ -e /Users/tientong/logs/uicl/mriqc/err

singularity run -H /Users/tientong/singularity_home \
/Users/tientong/mriqc_0.15.1.sif \
/Shared/oleary/functional/UICL/BIDS/rawdata \
/Shared/oleary/functional/UICL/BIDS/derivatives/mriqc \
participant --participant_label SUBJECT --no-sub -m bold --task-id rest \
-w /Shared/oleary/functional/UICL/BIDS/derivatives/mriqc \
--verbose-reports --write-graph --hmc-fsl --correct-slice-timing \
--n_procs 8 --mem_gb 22 --profile
```


```bash
%%bash

for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/allsub.txt | tr '\n' ' ') ; do
  sed -e "s|SUBJECT|${sub}|g" mriqc_t1w_TEMPLATE.job > mriqc_t1w_${sub}.job
  qsub mriqc_t1w_${sub}.job
done



for sub in $(cat /Shared/oleary/functional/UICL/BIDS/subject_list/test.txt | tr '\n' ' ') ; do
  sed -e "s|SUBJECT|${sub}|g" mriqc_rest_TEMPLATE.job > mriqc_rest_${sub}.job
  qsub mriqc_rest_${sub}.job
done

```
MRIQC group analysis

```bash
singularity run -H /Users/tientong/singularity_home \
  /Users/tientong/mriqc_0.15.1.sif \
  /Shared/oleary/functional/UICL/BIDS/rawdata \
  /Shared/oleary/functional/UICL/BIDS/derivatives/mriqc \
  group
```

# 7. Create masks for the extended Power ROI 

Links: https://greenelab.wustl.edu/data_software

Downloaded to: /oleary/atlas/greeneatlas/orig

Then run 

* [01-create-coord.R](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/01-create-coord.R)
* [02-3dundump.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/02-3dundump.sh)

to create 300 spherical ROIs, or any other seeds of interest from this atlas

# 8. Post-processing after fMRIPrep

Code in: [afterfMRIPrep_01runall.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_01runall.sh). A wrapper to run all steps after fMRIPrep

1. Non-aggressively denoise unsmooth BOLD with ICA-AROMA. [afterfMRIPrep_02aromaunsmooth_WMCSFts.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh)
2. Extract WM and CSF time series from the output of 1. [afterfMRIPrep_02aromaunsmooth_WMCSFts.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_02aromaunsmooth_WMCSFts.sh)
3. Organize WM and CSF time series into a confound text file [afterfMRIPrep_03makeconfound.R](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_03makeconfound.R) 
3. Nuisance regression and bandpass filter(3dTproject), standardize and scale [afterfMRIPrep_04ROIts.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_04ROIts.sh) 
4. Calculate correlation matrix of the 300 ROIs from the extended Power atlas (3dNetCorr) [afterfMRIPrep_04ROIts.sh](https://github.com/tientong98/RestUICL/blob/main/Subject-Level%20Analysis/afterfMRIPrep_04ROIts.sh) 

Run this step:

```bash
%%bash
dir=/Shared/oleary/functional/UICL/BIDS/code
sh $dir/afterfMRIPrep_01runall.sh 2>&1 | tee $dir/afterfMRIPrep_01runall.sh.log

```


```bash
3dresample \
  -master $fmriprepdir/sub-${subid}/ses-${sesid}/func/sub-${subid}_ses-${sesid}_task-rest_space-MNI152NLin6Asym_desc-smoothAROMAnonaggr_bold.nii.gz \
  -prefix /oleary/atlas/greeneatlas/greene300LPI.nii.gz \
  -input /oleary/atlas/greeneatlas/greene300.nii.gz
```

## Check if correlation matrices had been created for all subject


```bash
%%bash

dir=/Shared/oleary/functional/UICL/BIDS/derivatives/subject_level_glm/rest

# time 1 only N = 102
ls $dir/time1only/sub-*/ses-*/sub-*-*_extendedPower_000.netcc > time1only.txt
# check against this file
gedit /Shared/oleary/functional/UICL/BIDS/subject_list/time1only.txt


# twovisitSiemens N = 21
ls $dir/twovisitSiemens/sub-*/ses-*/sub-*-*_extendedPower_000.netcc > twovisitSiemens.txt
# check against this file
gedit /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_siemens.txt


# twovisitGE N = 98
ls $dir/twovisitGE/sub-*/ses-*/sub-*-*_extendedPower_000.netcc > twovisitGE.txt
# check against this file
gedit /Shared/oleary/functional/UICL/BIDS/code/time2/ge_time1time2.txt


##############################################################################

for type in time1only twovisitSiemens twovisitGE ; do
 cp $(cat $dir/${type}.txt | tr '\n' ' ') $dir/${type}/all_${type}/
 cd $dir/${type}
 zip -r all_${type}.zip all_${type}
done
```


