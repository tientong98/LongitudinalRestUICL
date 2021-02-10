#!/bin/bash
#$ -pe 56cpn 56
#$ -q CCOM
#$ -M tien-tong@uiowa.edu
#$ -m e
#$ -o /Users/tientong/rest
#$ -e /Users/tientong/rest

cd /Shared/tientong_scratch/abcd/code/postfmriprep/template
module load R/3.5.1

Rscript /Users/tientong/rest/cpm_sbinge_0001.R
