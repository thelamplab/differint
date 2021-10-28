#!/bin/bash


if [ $# -ne 1 ]; then
  echo "
usage: `basename $0` subject_dir


REQUIREMENTS:
 - feat_output_dir must be a directory into which FSL's FEAT is placing output,
   otherwise this script will never end
"
  exit
fi


subject_dir=$1

SLEEP_INTERVAL=10   # this is in seconds

while [ ! -e "${subject_dir}/donezo" ]; do
  # freesurfer is still running...
  sleep $SLEEP_INTERVAL
done

