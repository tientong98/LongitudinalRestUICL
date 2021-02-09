#!/bin/bash

source ~/sourcefiles/afni_source.sh

bidsdir=/Shared/oleary/functional/UICL/BIDS/rawdata/


sub=($(awk '{print $2}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))
ses=($(awk '{print $3}' /Shared/oleary/functional/UICL/BIDS/code/time2/time2_idses_group2.txt))

#for n in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 ; do

for n in `seq -s " " 0 1 118` ; do

########################################################################################################
#################### REST delete the first 3 - Jatin said to exclude first 6s ####################

      cd $bidsdir/sub-${sub[$n]}/ses-${ses[$n]}/func
      3dcalc -a sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.nii.gz'[3..179]' \
             -exp '(a)' -prefix sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold_new.nii.gz
      rm -rf sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.nii.gz
      mv sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold_new.nii.gz sub-${sub[$n]}_ses-${ses[$n]}_task-rest_bold.nii.gz

done
