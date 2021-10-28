#!/bin/bash

#SBATCH --partition=short
#SBATCH --job-name=aMasks
#SBATCH --time=20:00
#SBATCH --output=ashsMask-%j.out
#SBATCH --mem=2g



set -e
source globals.sh

OUT_DIR=$FIRSTLEVEL_DIR/rois_ashs

echo $SUBJ

if [ ! -d "$OUT_DIR" ]; then
  mkdir $OUT_DIR
  mkdir $OUT_DIR/t1space
  mkdir $OUT_DIR/t2space
  mkdir $OUT_DIR/func
fi

SUBJECT_ASHS_DIR=ashs
echo $SUBJECT_ASHS_DIR
ANAT=$ANAT_DIR/${SUBJ}_T1w_brain.nii.gz


LH_MASK_FILE=$SUBJECT_ASHS_DIR/final/${SUBJ}_left_lfseg_corr_usegray.nii.gz
RH_MASK_FILE=$SUBJECT_ASHS_DIR/final/${SUBJ}_right_lfseg_corr_usegray.nii.gz
LH_DEST_FILE=$OUT_DIR/lh.ASHS.nii.gz
RH_DEST_FILE=$OUT_DIR/rh.ASHS.nii.gz

convert_xfm -omat $NIFTI_DIR/t2_to_t1.mat -inverse $NIFTI_DIR/t1_to_t2.mat

fslswapdim $LH_MASK_FILE -x z y $LH_DEST_FILE
fslswapdim $RH_MASK_FILE -x z y $RH_DEST_FILE

ROIS=("A-ca1" "P-ca1" "A-ca23" "P-ca23" "A-dg" "P-dg" "A-sub" "P-sub" "ec" "prc" "phc")
NUMS=(1 2 3 4 5 6 7 8 9 10 11)
HEMIS="lh rh"

for hemi in $HEMIS
do
  fileList=""
  echo "subsetting ashs segmentation and moving to T1 space"
  for ((i=0;i<${#ROIS[@]};++i))
  do
    outfile=$OUT_DIR/t2space/${hemi}.${ROIS[i]}.nii.gz
    outfile2=$OUT_DIR/t1space/${hemi}.${ROIS[i]}.nii.gz
    fslmaths $OUT_DIR/${hemi}.ASHS.nii.gz -uthr ${NUMS[i]} -thr ${NUMS[i]} $outfile
    fslmaths $outfile -bin $outfile
    flirt -ref $ANAT -in $outfile -applyisoxfm 1.5 -init $NIFTI_DIR/t2_to_t1.mat -out $outfile2
    flirt -ref $ANAT -in $outfile -applyxfm -init $NIFTI_DIR/t2_to_t1.mat -out $outfile2
    fileList="$fileList $outfile2"
  done
  outfile=$OUT_DIR/t2space/${hemi}.hipp.nii.gz
  outfile2=$OUT_DIR/t1space/${hemi}.hipp.nii.gz
  fslmaths $OUT_DIR/${hemi}.ASHS.nii.gz -uthr 8 -thr 1 $outfile
  fslmaths $outfile -bin $outfile
  flirt -ref $ANAT -in $outfile -applyxfm -init $NIFTI_DIR/t2_to_t1.mat -out $outfile2
  dummy=$OUT_DIR/t1space/dummy.nii.gz
  fslmaths $outfile2 -sub $outfile2 $dummy
  fileList="$dummy $fileList"
  fslmerge -t $OUT_DIR/t1space/${hemi}.merged.nii.gz $fileList
  fslmaths $OUT_DIR/t1space/${hemi}.merged.nii.gz -Tmaxn $OUT_DIR/t1space/${hemi}.merged.nii.gz
  for ((i=0;i<${#ROIS[@]};++i))
  do
    outfile2=$OUT_DIR/t1space/${hemi}.${ROIS[i]}.nii.gz
    fslmaths $OUT_DIR/t1space/${hemi}.merged.nii.gz -uthr ${NUMS[i]} -thr ${NUMS[i]} $outfile2
  done
done

fslmaths $OUT_DIR/t1space/rh.A-ca23.nii.gz -add $OUT_DIR/t1space/rh.A-dg.nii.gz $OUT_DIR/t1space/rh.A-ca23dg.nii.gz
fslmaths $OUT_DIR/t1space/rh.P-ca23.nii.gz -add $OUT_DIR/t1space/rh.P-dg.nii.gz $OUT_DIR/t1space/rh.P-ca23dg.nii.gz
fslmaths $OUT_DIR/t1space/lh.A-ca23.nii.gz -add $OUT_DIR/t1space/lh.A-dg.nii.gz $OUT_DIR/t1space/lh.A-ca23dg.nii.gz
fslmaths $OUT_DIR/t1space/lh.P-ca23.nii.gz -add $OUT_DIR/t1space/lh.P-dg.nii.gz $OUT_DIR/t1space/lh.P-ca23dg.nii.gz
fslmaths $OUT_DIR/t1space/rh.A-ca23dg.nii.gz -add $OUT_DIR/t1space/rh.A-ca1.nii.gz $OUT_DIR/t1space/rh.A-hipp.nii.gz
fslmaths $OUT_DIR/t1space/rh.P-ca23dg.nii.gz -add $OUT_DIR/t1space/rh.P-ca1.nii.gz $OUT_DIR/t1space/rh.P-hipp.nii.gz
fslmaths $OUT_DIR/t1space/lh.A-ca23dg.nii.gz -add $OUT_DIR/t1space/lh.A-ca1.nii.gz $OUT_DIR/t1space/lh.A-hipp.nii.gz
fslmaths $OUT_DIR/t1space/lh.P-ca23dg.nii.gz -add $OUT_DIR/t1space/lh.P-ca1.nii.gz $OUT_DIR/t1space/lh.P-hipp.nii.gz


ROIS="ca1 ca23 dg sub ec prc phc ca23dg hipp"

for roi in $ROIS
do
  for hemi in $HEMIS
  do
    if [ -e $OUT_DIR/t1space/${hemi}.A-${roi}.nii.gz ]
    then
      fslmaths $OUT_DIR/t1space/${hemi}.A-${roi}.nii.gz -add $OUT_DIR/t1space/${hemi}.P-${roi}.nii.gz $OUT_DIR/t1space/${hemi}.${roi}.nii.gz
    fi
  done
  fslmaths $OUT_DIR/t1space/rh.${roi}.nii.gz -add $OUT_DIR/t1space/lh.${roi}.nii.gz $OUT_DIR/t1space/${roi}.nii.gz
  fslmaths $OUT_DIR/t1space/${roi}.nii.gz -thr 0.5 -bin $OUT_DIR/t1space/${roi}.nii.gz
  DOWNSAMP=$OUT_DIR/t1space/${roi}_1.5.nii.gz
  IDENT=$FSLDIR/etc/flirtsch/ident.mat
  flirt -ref $ANAT -in $OUT_DIR/t1space/${roi}.nii.gz -out $DOWNSAMP -applyisoxfm 1.5 -init $IDENT
  fslmaths $DOWNSAMP -thr 0.5 -bin $DOWNSAMP
done

# align mask to the run's functional data and binarize

ROIS=("ca1" "ca23" "dg" "sub" "ec" "prc" "phc" "ca23dg" "hipp")
for run in $runList
do
    FUNC=$FIRSTLEVEL_DIR/${run}.feat/reg/example_func.nii.gz
    HIRES2FUNC=$FIRSTLEVEL_DIR/${run}.feat/reg/highres2example_func.mat    
    for ((i=0;i<${#ROIS[@]};++i))
    do
        echo "moving to ${run} space for ${ROIS[i]}"
        INPUT=$OUT_DIR/t1space/${ROIS[i]}.nii.gz
        OUTPUT=$OUT_DIR/func/${ROIS[i]}_${run}.nii.gz
        flirt -ref $FUNC -in $INPUT -out $OUTPUT -applyxfm -init $HIRES2FUNC -interp spline
        fslmaths $OUTPUT -thr 0.35 -bin $OUTPUT
    done
done



