import nibabel as nib
import numpy as np
import sys
import time
from mpi4py import MPI
from brainiak.searchlight.searchlight import Searchlight


#########
# THIS RUNS A SEARCHLIGHT FINDING SIGNIFICANT CORRELATION BETWEEN 
# MODEL SIMILARITY LEVEL, AND REPRESENTATIONAL SIMILARITY OF IMAGE PAIRS
# IN ONLY PRE-LEARNING RUNS
#########

# What subject are you running
subject = sys.argv[1]
projdir = sys.argv[2]
try:
    radius = int(sys.argv[3])
    print("Using user-selected radius of {}".format(radius))
except:
    print("NO SL RADIUS ENTERED: Using radius of 2")
    radius = 2
corrType = 'pearson'



output = ('{}subjects/{}/analysis/searchlight/{}_vissim_pearson_func_r{}.nii.gz'.format(projdir, subject, subject, radius))
print(output)

def ModelSim(data, sl_mask):
    data4d = data[0]
    bolddata_sl = data4d.reshape(sl_mask.shape[0] * sl_mask.shape[1] * sl_mask.shape[2], data4d.shape[3]).T
    corrs = np.corrcoef(bolddata_sl)
    All_Corrs = [corrs[0,1], corrs[2,3], corrs[4,5], corrs[6,7], corrs[8,9], corrs[10,11], corrs[12,13], corrs[14,15]]
    if np.isnan(All_Corrs).any():
        Struct = np.nan
    else:
        Struct = np.corrcoef(np.arange(8), All_Corrs)[0,1]
    return Struct
    


# Get information
copes = []
for cope in range(1, 17):
    copeIm = nib.load('{}subjects/{}/analysis/firstlevel/task-random_run-01.feat/stats/cope{}.nii.gz'.format(projdir, subject, cope))
    copes.append(copeIm)
    affine_mat = copeIm.affine
nii = nib.funcs.concat_images(copes, check_affines=True)

dimsize = copeIm.header.get_zooms()

# Preset the variables
data = nii.get_data()
print(data.shape)

mask = nib.load('{}subjects/{}/analysis/firstlevel/task-random_run-01.feat/mask.nii.gz'.format(projdir, subject)).get_data()

print('mask dimensions: {}'. format(mask.shape))
print('number of voxels in mask: {}'.format(np.sum(mask)))

sl_rad = radius
max_blk_edge = 5
pool_size = 1

# Pull out the MPI information
comm = MPI.COMM_WORLD
rank = comm.rank
size = comm.size

# Create the searchlight object
sl = Searchlight(sl_rad=sl_rad,max_blk_edge=max_blk_edge)

# Distribute the information to the searchlights (preparing it to run)
sl.distribute([data], mask)
sl.broadcast(bcvar)
starttime = time.time()
sl_result = sl.run_searchlight(ModelSim)
total = time.time() - starttime
print('total time: {}, estimated time for whole brain: {}'.format(total, (total / np.sum(mask)) * 1474560))

# Only save the data if this is the first core
if rank == 0: 

    # Convert the output into what can be used
    sl_result = sl_result.astype('double')
    sl_result[np.isnan(sl_result)] = 0  # If there are nans we want this

    # Save the volume
    sl_nii = nib.Nifti1Image(sl_result.astype('double'), affine_mat)
    hdr = sl_nii.header
    hdr.set_zooms((dimsize[0], dimsize[1], dimsize[2]))
    nib.save(sl_nii, output)  # Save
    
    print('Finished searchlight')

