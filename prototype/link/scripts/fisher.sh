#!/usr/bin/env bash
# Input python command to be submitted as a job

#SBATCH --output=fish-%j.out
#SBATCH --job-name fisher
#SBATCH --partition=education
#SBATCH --time=4:00:00
#SBATCH --mem=2500


#########
# THIS RUNS A SEARCHLIGHT FINDING SIGNIFICANT CORRELATION BETWEEN 
# MODEL SIMILARITY LEVEL, AND REPRESENTATIONAL SIMILARITY OF IMAGE PAIRS
# IN ONLY PRE-LEARNING RUNS
#########

# Set up the environment
module load Langs/Python/3.5-anaconda
module load Pypkgs/brainiak/0.5-anaconda
module load Pypkgs/NILEARN/0.4.0-anaconda

source globals.sh

if [ ! -d "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight" ]
then
  mkdir "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight"
  echo "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight"
fi


# Run the python script
python ./scripts/fisher.py $SUBJ $PROJ_DIR
