#!/bin/bash

set -e
source globals.sh

#script to run topup and process field maps

if [ ! -d "$FM_DIR/topup" ]; then
  mkdir $FM_DIR/topup
fi

# MERGE AP AND PA FIELD MAPS
fslmerge -t $FM_DIR/${SUBJ}_FM.nii.gz $FM_DIR/${SUBJ}_APmap.nii.gz $FM_DIR/${SUBJ}_PAmap.nii.gz

# INPUT ACQUISITION PARAMETERS
ACQ=$FM_DIR/topup/acqparams.txt
cat > $ACQ << EOF
0 -1 0 0.0646
0 -1 0 0.0646
0 -1 0 0.0646
0 1 0 0.0646
0 1 0 0.0646
0 1 0 0.0646
EOF

# RUN TOPUP
OUT=$FM_DIR/topup/topup_output
IOUT=$FM_DIR/topup/topup_iout
LOGOUT=$FM_DIR/topup/topup_logout
FOUT=$FM_DIR/topup/topup_fout
topup --imain=$FM_DIR/${SUBJ}_FM.nii.gz --datain=$ACQ --config=b02b0.cnf --out=$OUT --iout=$IOUT --fout=$FOUT --logout=$LOGOUT

# PROCESS TOPUP - convert Hz to rad/s, average fm across time, brain extract field map, and replace zero voxels.
fslmaths $FM_DIR/topup/topup_fout -mul 6.28 $FM_DIR/${SUBJ}_FM_rads.nii.gz
fslmaths $FM_DIR/topup/topup_iout -Tmean $FM_DIR/${SUBJ}_FM_mag.nii.gz
bet2 $FM_DIR/${SUBJ}_FM_mag.nii.gz $FM_DIR/${SUBJ}_FM_mag_brain.nii.gz -f 0.75 -g -0.01
fslmaths $FM_DIR/${SUBJ}_FM_mag_brain.nii.gz -ero $FM_DIR/${SUBJ}_FM_mag_brain.nii.gz

