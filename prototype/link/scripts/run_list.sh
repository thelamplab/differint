#!/bin/bash

funcList=$(ls ./data/func)

runList=""
for var in $funcList
do
  if [[ $var == *".nii.gz" ]]; then
    echo $var
    counter=1
    IFS='_' read -ra FNAME <<< "$var"
    run=""
    for i in "${FNAME[@]}"; do
      if [ $counter == 2 ]; then
        run="${run}${i}";
      fi
      if [ $counter == 3 ]; then
        run="${run}_${i}";
      fi
      counter=$((counter+1))
    done
    runList="${runList} ${run}"
  fi
done

echo $runList
