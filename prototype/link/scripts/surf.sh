#!/bin/bash

#SBATCH --partition=verylong
#SBATCH --job-name=SURFrun
#SBATCH --time=40:00:00
#SBATCH --output=surfer-%j.out
#SBATCH --mem=15g

set -e
source globals.sh


ANAT=$ANAT_DIR/${SUBJ}_T1w.nii.gz
recon-all -all -notify donezo -subjid freesurfer -i $ANAT -hippocampal-subfields-T1 &
#recon-all -notify donezo -subjid freesurfer -hippocampal-subfields-T1 &
bash scripts/wait-for-surf.sh .
