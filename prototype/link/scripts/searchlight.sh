#!/usr/bin/env bash
# Input python command to be submitted as a job

#SBATCH --output=search-%j.out
#SBATCH --job-name searchlight
#SBATCH --partition=education
#SBATCH --time=4:00:00
#SBATCH --mem=250000
#SBATCH -n 2


#########
# THIS RUNS A SEARCHLIGHT FINDING SIGNIFICANT CORRELATION BETWEEN 
# MODEL SIMILARITY LEVEL, AND REPRESENTATIONAL SIMILARITY OF IMAGE PAIRS
# IN ONLY PRE-LEARNING RUNS
#########

# Set up the environment
module load Langs/Python/3.5-anaconda
module load Pypkgs/brainiak/0.5-anaconda
module load Pypkgs/NILEARN/0.4.0-anaconda
module load MPI/OpenMPI

source globals.sh

if [ ! -d "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight" ]
then
  mkdir "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight"
  echo "${PROJ_DIR}subjects/${SUBJ}/analysis/searchlight"
fi


# Run the python script
radius=$1
space=$3

srun --mpi=pmi2 python ./scripts/searchlight.py $SUBJ $PROJ_DIR $radius
