# Dataset from:
### "Increasing stimulus similarity drives nonmonotonic representational change in hippocampus"  
>Wammes, J. D., Norman, K. A., & Turk-Browne, N. B. (2021). Increasing stimulus similarity drives nonmonotonic representational change in hippocampus. *eLife*.

This repository contains the code used for the analyses of this manuscript (**IN PROGRESS**). 

Data will be available via Dryad. 

To starthis repository assumes that the 41 subjects' zip files, as well as fieldmaps.zip, design.zip and sorting_data.zip are housed in the folder `differint/data/zip`

To start, you can either run `. arrange_all.sh` to put all participants in the correct folder organization for the code, or run them one by one by running `. arrange_data sub-${n}` for each of the 41 participant numbers. From there, the code in the github repository will walk you through preprocessing and analyzing the data.

The scan sequences are as follows:

1. **T1 MPRAGE:** TR = 2300 ms, TE = 2.27 ms, flip angle = 8 degrees, matrix = 256 x 256, slices = 208, resolution = 1 mm isotropic, GRAPPA acceleration factor=3  
2. **T2 TSE:** TR = 11390 ms, TE = 90 ms, flip angle = 150 degrees, matrix = 384 x 384, slices = 54, perpindicular to hippocampal long axis, resolution = 0.44 x 0.44 x 1.5 mm    
3. **EPI:** TR = 1.5 s, TE = 32.6 ms, flip angle = 71 degrees, matrix = 128 x 128, slices = 90, resolution = 1.5 mm isotropic  

## Code instructions

Each participants' entire analysis, once their data is places in the appropriate place (see above), is managed by a script in their directory, called `analyze.sh`
* Move to a participants directory (e.g. `subjects/sub-05`)
* Submit the analysis.sh script as a batch job (e.g. `sbatch analyze.sh`)
* This script will call on various others that fit GLMs to the data for each stimulus and run, run ASHS and Freesurfer, and create ROImasks from the ouput of these.
* It will also call on a script to run representational siilarity analyses, and searchlights.

Once these have run, you can move on to the jupyter notebooks (house in `analysis/ipynb`), which will run the analyses reported in the paper.

