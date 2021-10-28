#!/bin/bash
#
# render-fsf-templates.sh fills in templated fsf files so FEAT can use them
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs
#
# refer to the secondlevel neuropipe tutorial to see an example of how
# to use this script

#set -e

source globals.sh

function render_firstlevel {
  fsf_template=$1
  output_dir=$2
  standard_brain=$3
  data_file_prefix=$4
  highres_file=$5
  ev_dir=$6
  ev_root=$7
  subject=$8
  fm_dir=$9

  subject_dir=$(pwd)

  # note: the following replacements put absolute paths into the fsf file. this
  #       is necessary because FEAT changes directories internally
  cat $fsf_template \
    | sed "s:<?= \$OUTPUT_DIR ?>:$subject_dir/$output_dir:g" \
    | sed "s:<?= \$STANDARD_BRAIN ?>:$standard_brain:g" \
    | sed "s:<?= \$DATA_FILE_PREFIX ?>:$subject_dir/$data_file_prefix:g" \
    | sed "s:<?= \$HIGHRES_FILE ?>:$subject_dir/$highres_file:g" \
    | sed "s:<?= \$EV_FILE ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_uni.txt:g" \
    | sed "s:<?= \$EV_FILE1 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c56-68_0A.txt:g" \
    | sed "s:<?= \$EV_FILE2 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c56-68_0B.txt:g" \
    | sed "s:<?= \$EV_FILE3 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c17-85_14A.txt:g" \
    | sed "s:<?= \$EV_FILE4 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c17-85_14B.txt:g" \
    | sed "s:<?= \$EV_FILE5 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c47-34_29A.txt:g" \
    | sed "s:<?= \$EV_FILE6 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c47-34_29B.txt:g" \
    | sed "s:<?= \$EV_FILE7 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c40-20_43A.txt:g" \
    | sed "s:<?= \$EV_FILE8 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c40-20_43B.txt:g" \
    | sed "s:<?= \$EV_FILE9 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c102-109_57A.txt:g" \
    | sed "s:<?= \$EV_FILE10 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c102-109_57B.txt:g" \
    | sed "s:<?= \$EV_FILE11 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c11-5_71A.txt:g" \
    | sed "s:<?= \$EV_FILE12 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c11-5_71B.txt:g" \
    | sed "s:<?= \$EV_FILE13 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c79-97_86A.txt:g" \
    | sed "s:<?= \$EV_FILE14 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c79-97_86B.txt:g" \
    | sed "s:<?= \$EV_FILE15 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c83-101_100A.txt:g" \
    | sed "s:<?= \$EV_FILE16 ?>:$subject_dir/$ev_dir/${subject}_${ev_root}_c83-101_100B.txt:g" \
    | sed "s:<?= \$RADS ?>:$subject_dir/$fm_dir/${subject}_FM_rads.nii.gz:g" \
    | sed "s:<?= \$MAG ?>:$subject_dir/$fm_dir/${subject}_FM_mag_brain.nii.gz:g"
}


if [ -f "$FM_DIR/${SUBJ}_APmap.nii.gz" ]
then
  TEMPFILE=fm_runs.fsf.template
else
  TEMPFILE=runs.fsf.template
fi

for r in $runList
do
  render_firstlevel $FSF_DIR/${TEMPFILE} \
                    $FIRSTLEVEL_DIR/${r}.feat \
                    /nexsan/apps/hpc/Apps/FSL/5.0.10/data/standard/MNI152_T1_2mm_brain \
                    $FUNC_DIR/${SUBJ}_${r}_bold \
                    $ANAT_DIR/${SUBJ}_T1w_brain \
                    $EV_DIR \
                    $r \
                    $SUBJ \
                    $FM_DIR \
		    > $FSF_DIR/${r}.fsf
done
