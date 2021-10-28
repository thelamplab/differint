#!/usr/bin/env bash
# Input python command to be submitted as a job

#SBATCH --output=anat-%j.out
#SBATCH --job-name anat
#SBATCH --partition=verylong
#SBATCH --time=4:00:00
#SBATCH --mem=50000
#SBATCH -n 2


source globals.sh

stan=/nexsan/apps/hpc/Apps/FSL/5.0.10/data/standard/MNI152_T1_2mm_brain
for run in $runList
do
  runDir=./analysis/firstlevel/${run}.feat
  transform=${runDir}/reg/example_func2standard.mat
  for ((i=1;i<17;++i))
    do
      echo $i
      cope=${runDir}/stats/cope${i}.nii.gz
      copeOut=${runDir}/stats/cope${i}_stan.nii.gz
      if [ ! -f ${copeOut} ]; then
        echo $copeOut
        flirt -ref $stan -in $cope -out $copeOut -applyisoxfm 1.5 -init $transform
      fi  
    done
done
      
