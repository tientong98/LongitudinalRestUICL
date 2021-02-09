#!/bin/bash

source ~/sourcefiles/afni_source.sh
source ~/sourcefiles/fsl_source.sh

#### resample from the downloaded ROI

3dresample -master master+orig -prefix new.dset -input old+orig

####2mm

3dUndump \
 -prefix greene300-5.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
 -orient LPI \
 -srad 5 \
 -xyz afniinput5.txt

3dUndump \
 -prefix greene300-4.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
 -orient LPI \
 -srad 4 \
 -xyz afniinput4.txt

fslmaths \
 greene300-5.nii.gz \
 -add greene300-4.nii.gz \
 greene300.nii.gz


####1mm
3dUndump \
 -prefix greene300-5_1mm.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_1mm_brain.nii.gz \
 -orient LPI \
 -srad 5 \
 -xyz afniinput5.txt

3dUndump \
 -prefix greene300-4_1mm.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_1mm_brain.nii.gz \
 -orient LPI \
 -srad 4 \
 -xyz afniinput4.txt

fslmaths \
 greene300-5_1mm.nii.gz \
 -add greene300-4_1mm.nii.gz \
 greene300_1mm.nii.gz

####### Default mode

3dUndump \
 -prefix DMN_5.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_1mm_brain.nii.gz \
 -orient LPI \
 -srad 5 \
 -xyz dmn_5.txt

3dUndump \
 -prefix DMN_4.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
 -orient LPI \
 -srad 4 \
 -xyz dmn_4.txt

fslmaths \
  DMN_5.nii.gz \
  -add DMN_4.nii.gz \
  DMN.nii.gz

####### Ventral Attention

3dUndump \
 -prefix VAN_5.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
 -orient LPI \
 -srad 5 \
 -xyz van_5.txt

3dUndump \
 -prefix VAN_4.nii.gz \
 -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
 -orient LPI \
 -srad 4 \
 -xyz van_4.txt

fslmaths \
  VAN_5.nii.gz \
  -add VAN_4.nii.gz \
  VAN.nii.gz

fslmaths \
  DMN.nii.gz \
  -add VAN.nii.gz \
  DMN-VAN.nii.gz

###### old index

3dUndump -prefix greene300-5oldindex.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 5 -xyz afniinput5oldindex.txt

3dUndump -prefix greene300-4oldindex.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz afniinput4oldindex.txt

fslmaths greene300-5oldindex.nii.gz -add greene300-4oldindex.nii.gz greene300oldindex.nii.gz

###### create seed

echo "-20.3 -2.27 -22.21" | 3dUndump -prefix LAmyg_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "19.51 -1.85 -23.11" | 3dUndump -prefix RAmyg_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "-12.49 17.05 -4.49" | 3dUndump -prefix LNAcc_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

echo "12.66 17.32 -5.06" | 3dUndump -prefix RNAcc_mask.nii.gz \
         -master /Shared/pinc/sharedopt/apps/fsl/Linux/x86_64/6.0.1_multicore/data/standard/MNI152_T1_2mm_brain.nii.gz \
         -orient LPI -srad 4 -xyz -

