#!/bin/bash
# author: mgsimon@princeton.edu
# this script sets up global variables for the analysis of the current subject

#set -e # stop immediately when an error occurs


###### MILGRAM REFS ######
export BXH_DIR=/nexsan/apps/hpc/Tools/BXH_XCEDE/1.11.14/bin
export ASHS_ROOT=/gpfs/milgram/project/turk-browne/projects/differint/ASHS/ashs-fastashs_beta
PACKAGES_DIR=/gpfs/milgram/project/turk-browne/packages/
ATLAS_DIR=/gpfs/milgram/project/turk-browne/shared_resources/atlases/
ASHS_ATLAS=/gpfs/milgram/project/turk-browne/projects/differint/ASHS/princeton_atlas/
SCHEDULER=slurm
SHORT_PARTITION=short # Partition for jobs <6 hours
LONG_PARTITION=verylong # Partition for jobs >24 hours
export LD_LIBRARY_PATH=/apps/hpc/Apps/FREESURFER/6.0.0/MCRv80/glnxa64


. ${FSLDIR}/etc/fslconf/fsl.sh

module load AFNI/2017.08.11
module load FSL/5.0.10
module load Python/Anaconda3
module load nilearn/0.5.0-Python-Anaconda3
module load FreeSurfer/6.0.0
module load BXH_XCEDE_TOOLS/1.11.1
module load ANTs/2.3.1-foss-2018a
. /nexsan/apps/hpc/Apps/FSL/5.0.10/etc/fslconf/fsl.sh
. /apps/hpc/Apps/FREESURFER/6.0.0/FreeSurferEnv.sh


source scripts/subject_id.sh  # this loads the variable SUBJ
source scripts/run_list.sh  # this loads the variable runList

PROJ_DIR=../../
SUBJECT_DIR=${PROJ_DIR}subjects/$SUBJ

# for freesurfer
SUBJECTS_DIR=$SUBJECT_DIR

FUNC_DIR=data/func
FM_DIR=data/fieldmap
ANAT_DIR=data/anat

SCRIPT_DIR=scripts
FIRSTLEVEL_DIR=analysis/firstlevel

FSF_DIR=fsf
EV_DIR=design


