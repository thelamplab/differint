#!/bin/bash
#
# analyze.sh runs the analysis of a subject
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe and modified for this project
#SBATCH --partition=long
#SBATCH --job-name=fullsub
#SBATCH --ntasks=1 --nodes=1
#SBATCH --time=30:00:00
#SBATCH --mem=4g

set -e # stop immediately when an error occurs


pushd $SLURM_SUBMIT_DIR > /dev/null   # move into the subject's directory, quietly

source ./globals.sh   # load subject-wide settings, such as the subject's ID

# here, we call scripts to make a webpage describing this subject's analysis,
# prepare the subject's data, and then run analyses on it. put in a call to each
# of your high-level analysis scripts (behavioral.sh, fir.sh, ...) where
# indicated, below

echo "== beginning analysis of $SUBJ at $(date) =="

# PREPROCESSING
bash prep.sh

# BRAIN EXTRACTION

bet $ANAT_DIR/${SUBJ}_T1w.nii.gz $ANAT_DIR/${SUBJ}_T1w_brain.nii.gz -f 0.45 -g -0.35
echo "T1 brain-extracted -- $(date)"
sleep 5
if [ -f "$NIFTI_DIR/${SUBJ}_t2.nii.gz" ]; then
  bet $ANAT_DIR/${SUBJ}_T2w.nii.gz $ANAT_DIR/${SUBJ}_T2w_brain.nii.gz -f 0.1
  echo "T2 brain-extracted -- $(date)"
  sleep 5

# REGISTER T1 WITH T2
  T1=$ANAT_DIR/${SUBJ}_T1w_brain.nii.gz
  T2=$ANAT_DIR/${SUBJ}_T2w_brain.nii.gz
  T12T2=$ANAT_DIR/t1_to_t2.nii.gz
  T12T2mat=$ANAT_DIR/t1_to_t2.mat
  flirt -in $T1 -ref $T2 -out $T12T2 -omat $T12T2mat -dof 6 -interp spline -finesearch 18
  echo "T1 registered to T2 -- $(date)"
# RUN ASHS FOR MTL SEGMENTATION
  sbatch scripts/ashs.sh
  echo "ASHS started -- $(date)"
fi

# RUN FREESURFER
ANAT=$ANAT_DIR/${SUBJ}_T1w.nii.gz
sbatch scripts/surf.sh
echo "FreeSurfer started -- $(date)"


# FIELD MAPS
if [ -f "$FM_DIR/${SUBJ}_APmap.nii.gz" ]; then
  bash scripts/fm_topup.sh
  echo "top up done -- $(date)"
fi

# RUN FEATS FOR RUNS
for run in $runList
do
  sbatch scripts/run_feat.sh $run
  echo "${run} feat started -- $(date)"
  sleep 10
done

sleep 200
for run in $runList
do
  bash scripts/wait-for-feat.sh $FIRSTLEVEL_DIR/${run}.feat
  echo "${run} feat finished -- $(date)"
done
echo "all feats finished -- $(date)"

# RUN SEARCHLIGHT
sbatch scripts/stanSpace.sh
sbatch scripts/searchlight.sh 2

# CREATE ANATOMICAL ROIS
sbatch scripts/make-ashs-rois.sh
sbatch scripts/make-surf-rois.sh
echo "ROIs made -- $(date)"

# COMPUTE BASIC PRE-LEARNING CORRELATIONS
python scripts/basicRSA.py $SUBJ $PROJ_DIR ashs $runList
python scripts/basicRSA.py $SUBJ $PROJ_DIR surf $runList


bash scripts/wait-for-surf.sh .
echo "FreeSurfer finished"

echo "== finished analysis of $SUBJ at $(date) =="

popd > /dev/null   # return to the directory this script was run from, quietly
