#!/bin/bash

#SBATCH --partition=verylong
#SBATCH --job-name=ASHSrun
#SBATCH --time=100:00:00
#SBATCH --output=hippseg-%j.out
#SBATCH --mem=100000

set -e
source globals.sh



T1=$ANAT_DIR/${SUBJ}_T1w.nii.gz
T2=$ANAT_DIR/${SUBJ}_T2w.nii.gz
T1swap=$NIFTI_DIR/${SUBJ}_t1_ashs.nii.gz
T2swap=$NIFTI_DIR/${SUBJ}_t2_ashs.nii.gz

if [ ! -f "$T1swap" ]; then
  fslswapdim $T1 -x z y $T1swap
fi
if [ ! -f "$T2swap" ]; then
  fslswapdim $T2 -x z y $T2swap
fi

if [ ! -d "$SUBJECT_DIR/ashs" ]
then
  mkdir $SUBJECT_DIR/ashs
fi

$ASHS_ROOT/bin/ashs_main.sh -I $SUBJ -a $ASHS_ATLAS -g $T1swap -f $T2swap -w $SUBJECT_DIR/ashs
