#!/bin/bash
#
# prep.sh prepares for analysis of the subject's data
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs
#
#SBATCH -p short
#SBATCH -t 600
#SBATCH --mem 10000

#set -e

# Set up the environment
source globals.sh

. /apps/hpc/Apps/FREESURFER/6.0.0/FreeSurferEnv.sh
. /nexsan/apps/hpc/Apps/FSL/5.0.10/etc/fslconf/fsl.sh


echo "==render-fsf-template=="
echo $(date)
echo ' '
if [ ! -f "fsf/func01_temp.fsf" ]
then
bash scripts/render-fsf-templates.sh
fi
echo "==Finished=="
echo $(date)
