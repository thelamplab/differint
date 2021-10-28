#!/bin/bash
#SBATCH --partition=short   
#SBATCH --job-name=sMasks
#SBATCH --time=20:00
#SBATCH --output=surfMask-%j.out
#SBATCH --mem=2g


set -e
source globals.sh

OUT_DIR=$FIRSTLEVEL_DIR/rois_surf

echo $SUBJ

if [ ! -d "$OUT_DIR" ]; then
  mkdir $OUT_DIR
  mkdir $OUT_DIR/t1space
  mkdir $OUT_DIR/t2space
  mkdir $OUT_DIR/func
fi

SUBJECT_SURF_DIR=freesurfer
ANAT=$NIFTI_DIR/${SUBJ}_t1_brain.nii.gz
T2=$NIFTI_DIR/${SUBJ}_t2_brain.nii.gz
SUBJECT=freesurfer

FILLTHRESH=0.0 # threshold for incorporating a voxel in the mask, default = 0
REGISTERDAT=${SUBJECT_SURF_DIR}/register.dat
echo "must run the following command from command line in interactive session"
echo "tkregister2 --s $SUBJECT --mov $ANAT --regheader --reg $REGISTERDAT"


ROIS="V1 V2 perirhinal"

# If wanting to go to functional voxel size, first create a functional in anatomical space using applyisoxfm and flirt, then use that as the template
# for mri_label2vol -temp and mri_convert -rl
for ROI in $ROIS
do
  echo $ROI
  for HEMI in lh rh
  do
    LABEL=${SUBJECT_SURF_DIR}/label/${HEMI}.${ROI}_exvivo.label
    DEST=${OUT_DIR}/t1space/${HEMI}.${ROI}.nii.gz
    DEST2=${OUT_DIR}/t2space/${HEMI}.${ROI}.nii.gz
#    mri_label2vol --label $LABEL --o $DEST --reg $REGISTERDAT --temp $REFERENCEVOLUME --fillthresh $FILLTHRESH --proj frac 0 1 0.1 --subject $SUBJECT --hemi $HEMI --surf white
#    mri_label2vol --label $LABEL --reg $REGISTERDAT --temp $REFERENCEFUNC --o $DEST --fillthresh $FILLTHRESH --proj frac 0 1 0.1 --subject $SUBJECT --hemi $HEMI --surf white
    mri_label2vol --label $LABEL --reg $REGISTERDAT --temp $ANAT --o $DEST --fillthresh $FILLTHRESH --proj frac 0 1 0.1 --subject $SUBJECT --hemi $HEMI --surf white > /dev/null
    flirt -ref $T2 -in $DEST -applyxfm -init $NIFTI_DIR/t1_to_t2.mat -out $DEST2  > /dev/null
  done
done


mri_convert -rl $ANAT -rt nearest ${SUBJECT_SURF_DIR}/mri/aparc+aseg.mgz ${OUT_DIR}/aparc+aseg.nii.gz  > /dev/null


# names of labels can be looked up in $FREESURFER_HOME/FreeSurferColorLUT.txt

ROIS=("IT" "EC" "PHC" "LOC" "Fus")
LEFT=(1009 1006 1016 1011 1007)
RIGHT=(2009 2006 2016 2011 2007)
HEMIS="lh rh"
for hemi in $HEMIS
do
  mri_convert -rl $ANAT -rt nearest ${SUBJECTS_DIR}/freesurfer/mri/${hemi}.hippoSfLabels-T1.v10.FSvoxelSpace.mgz ${OUT_DIR}/${hemi}.hippoSfLabels.nii.gz  > /dev/null
  fileList=""
  echo "subsetting ${hemi} surf segmentation and moving to T2 space"
  for ((i=0;i<${#ROIS[@]};++i))
  do
    echo ${ROIS[i]}
    outfile=$OUT_DIR/t2space/${hemi}.${ROIS[i]}.nii.gz
    outfile2=$OUT_DIR/t1space/${hemi}.${ROIS[i]}.nii.gz
    if [ $i -gt 5 ]; then basefile=${OUT_DIR}/${hemi}.hippoSfLabels.nii.gz; else basefile=${OUT_DIR}/aparc+aseg.nii.gz; fi
    if [ "$hemi" = "lh" ]
    then
      fslmaths $basefile -uthr ${LEFT[i]} -thr ${LEFT[i]} $outfile2
    else
      fslmaths $basefile -uthr ${RIGHT[i]} -thr ${RIGHT[i]} $outfile2
    fi
    fslmaths $outfile2 -bin $outfile2
    if [ "${ROIS[i]}" = "LOC" ]; then 
      fslmaths $outfile2 -sub $OUT_DIR/t1space/${hemi}.V1.nii.gz -sub $OUT_DIR/t1space/${hemi}.V2.nii.gz $outfile2
      fslmaths $outfile2 -bin $outfile2
    fi
    flirt -ref $T2 -in $outfile2 -applyxfm -init $NIFTI_DIR/t1_to_t2.mat -out $outfile
    fileList="$fileList $outfile2"
  done
done
ROIS=("V1" "V2" "perirhinal" "IT" "EC" "PHC" "LOC" "Fus")

for ((i=0;i<${#ROIS[@]};++i))
do
  echo "merging hemispheres for ${ROIS[i]}"
  outfile=$OUT_DIR/t2space/${ROIS[i]}.nii.gz
  outfile2=$OUT_DIR/t1space/${ROIS[i]}.nii.gz
  fslmaths $OUT_DIR/t2space/lh.${ROIS[i]}.nii.gz -add $OUT_DIR/t2space/rh.${ROIS[i]}.nii.gz $outfile
  fslmaths $OUT_DIR/t1space/lh.${ROIS[i]}.nii.gz -add $OUT_DIR/t1space/rh.${ROIS[i]}.nii.gz $outfile2
  fslmaths $outfile2 -bin $outfile2
  fslmaths $outfile -bin $outfile
  DOWNSAMP=$OUT_DIR/t1space/${ROIS[i]}_1.5.nii.gz
  IDENT=$FSLDIR/etc/flirtsch/ident.mat
  flirt -ref $ANAT -in $outfile2 -out $DOWNSAMP -applyisoxfm 1.5 -init $IDENT
  fslmaths $DOWNSAMP -thr 0.5 -bin $DOWNSAMP
done

# align mask to the run's functional data and binarize

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
        fslmaths $OUTPUT -thr 0.5 -bin $OUTPUT
        
    done
done


