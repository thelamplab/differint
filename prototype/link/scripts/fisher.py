import nibabel as nib
from nilearn import image
import numpy as np
import sys


#########
# This removes the relevant data from the output numpy array
#########

# What subject are you running
subject = sys.argv[1]
projdir = sys.argv[2]

for sType, space in zip(['poly', 'vissim'], ['stan', 'func']):
    for radius in [2]:
        for corrType in ['pearson']:
            inputname = ('{}subjects/{}/analysis/searchlight/{}_{}_{}_{}_r{}.nii.gz'.format(projdir, subject, subject, sType, corrType, space, radius))
            outputname = ('{}subjects/{}/analysis/searchlight/{}_{}fish_{}_{}_r{}.nii.gz'.format(projdir, subject, subject, sType, corrType, space, radius))
            try:
                result = nib.load(inputname).get_data()
                fish = np.arctanh(result)
                output = image.new_img_like(inputname, fish)
                output.to_filename(outputname)

                print('Finished {} {} {} r{}'.format(sType, space, corrType, radius))
            except:
                print('UNAVAILABLE {} {} {} r{}'.format(sType, space, corrType, radius))

