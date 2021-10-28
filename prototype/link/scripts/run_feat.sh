#!/bin/bash
#
# prep.sh prepares for analysis of the subject's data
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs
#
#SBATCH --partition=short
#SBATCH --job-name=FEATrun
#SBATCH --ntasks=1 --nodes=1
#SBATCH --time=6:00:00
#SBATCH --output=feat-%j.out
#SBATCH --mem=15g

set -e

# Set up the environment
source globals.sh

. /apps/hpc/Apps/FREESURFER/6.0.0/FreeSurferEnv.sh
. /nexsan/apps/hpc/Apps/FSL/5.0.10/etc/fslconf/fsl.sh

running=$1
feat fsf/${running}.fsf &
sleep 20
bash scripts/wait-for-feat.sh $FIRSTLEVEL_DIR/${running}.feat

