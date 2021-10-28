#!/bin/bash

sub_zip_list=$(ls ./data/zip)
start_dir=$(pwd)

subj_list=""
for var in $sub_zip_list; do
  if [[ $var == *".zip" ]]; then
    if [[ $var == "sub-"* ]]; then
      subj_list="${subj_list} ${var}"
    fi
  fi
done

echo $subj_list

for subj in $subj_list; do
  pushd $start_dir/subjects/$subj > /dev/null
  echo $sub
  sbatch ./analyze.sh
  sleep 1
done
