#!/bin/bash -e
# author: mgsimon@princeton.edu
# this script sets up global variables for the whole project

#set -e # stop immediately when an error occurs


# add necessary directories to the system path
#module load FSL/5.0.9
#module load Python/Anaconda3
#module load FreeSurfer/6.0.0
#module load BXH_XCEDE_TOOLS
#module load brainiak
#module load nilearn
#module load AFNI/2020.1.01

#module load Apps/Matlab/R2012b
#module load Apps/AFNI/2017-08-11
#module load Apps/FSL/5.0.10
#module load Langs/Python/3.5-anaconda
#module load Pypkgs/NILEARN/0.4.0-anaconda
#module load Apps/FREESURFER/6.0.0
#module load Tools/BXH_XCEDE/1.11.14
#. /nexsan/apps/hpc/Apps/FSL/5.0.10/etc/fslconf/fsl.sh
#. /apps/hpc/Apps/FREESURFER/6.0.0/FreeSurferEnv.sh



PROJECT_DIR=$(pwd)
SUBJECTS_DIR=subjects
GROUP_DIR=group

#below variables are needed for roi.sh
ROI_RESULTS_DIR=results
SUBJ_ROI_DIR=results/roi #path to each subject's roi directory -- the script assumes that
# each subject's roi data is in the same place within his/her directory

function exclude {
  for subj in $1; do
    if [ -e $SUBJECTS_DIR/$subj/EXCLUDED ]; then continue; fi
    echo $subj
  done
}

function visexclude {
  for subj in $1; do
    if [ -e $SUBJECTS_DIR/$subj/visexclude ]; then continue; fi
    echo $subj
  done
}

if [ -d $SUBJECTS_DIR ]; then
ALL_SUBJECTS=$(ls -1d $SUBJECTS_DIR/*/ | cut -d / -f 2)
NON_EXCLUDED_SUBJECTS=$(exclude "$ALL_SUBJECTS")
VIS_INCLUSIONS=$(visexclude "$ALL_SUBJECTS")
ALL_SUBJECTS=$NON_EXCLUDED_SUBJECTS
echo $ALL_SUBJECTS
echo $VIS_INCLUSIONS
fi
