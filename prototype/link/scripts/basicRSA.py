#/usr/bin/env python

import os
import sys
import numpy as np
from nilearn import image

subject = sys.argv[1]
projdir = sys.argv[2]
sourceROI = sys.argv[3]
runList = sys.argv[4:len(sys.argv)]

elif sourceROI == 'ashs':
    roiList = ['ca1', 'ca23', 'dg', 'sub', 'ec', 'prc', 'phc', 'ca23dg', 'hipp']
elif sourceROI == 'surf':
    roiList = ['V1', 'V2', 'perirhinal', 'IT', 'HC', 'EC', 'PHC', 'LOC', 'Fus', 'paraSub', 'preSub', 'Sub', 'CA1', 'CA3', 'CA4', 'DG']

def load_cope(projDir, subID, runNum, copeNum):
    filePath = '{}subjects/{}/analysis/firstlevel/{}.feat/stats/cope{}.nii.gz'.format(projDir, subID, runNum, copeNum)
    cope = image.load_img(filePath)
    copeDat = cope.get_data()
    return copeDat

def load_mask(projDir, subID, runNum, ROI):
    maskPath = '{}subjects/{}/analysis/firstlevel/rois_{}/func/{}_{}.nii.gz'.format(projDir, subID, sourceROI, ROI, runNum)
    mask = image.load_img(maskPath)
    maskDat = mask.get_data()
    voxels = np.sum(maskDat)
    return maskDat, voxels

def mask_cope(copeDat, maskDat):
    return copeDat[maskDat==1]

def all_rois_copes(projDir, subID, roiList, runNum):
    ROIs = []
    for ROI in roiList:
        mask, shape = load_mask(projDir, subID, runNum, ROI)
        allCopes = np.empty((16, shape))
        for copeNum in range(1,17):
            cope = load_cope(projDir, subID, runNum, copeNum)
            masked = mask_cope(cope, mask)
            allCopes[copeNum-1] = masked
        ROIs.append(allCopes)
    return ROIs

def all_corrs(projDir, subID, roiList, runNum):
    ROIs = all_rois_copes(projDir, subID, roiList, runNum)
    allCorrs = np.empty((len(roiList), 8))
    Master = np.empty((len(roiList), 16, 16))
    for x, ROI in enumerate(ROIs):
        corrs = np.corrcoef(ROI)
        allPairs = np.empty((8))
        for i in range(8):
            allPairs[i] = corrs[(i*2), (i*2)+1]
        allCorrs[x] = allPairs
        Master[x] = corrs
    return allCorrs, Master


for run in runList:
    print('--------')
    print(run)
    print('--------')
    if not os.path.exists('{}subjects/{}/analysis/firstlevel/{}.feat/{}'.format(projdir, subject, run, sourceROI)):
        os.makedirs('{}subjects/{}/analysis/firstlevel/{}.feat/{}'.format(projdir, subject, run, sourceROI))
    ROI_corr, full = all_corrs(projdir, subject, roiList, run)
    np.save('{}subjects/{}/analysis/firstlevel/{}.feat/{}/all_corrs_both.npy'.format(projdir, subject, run, sourceROI),
            full)
    ROI_corr = np.around(ROI_corr,2)
    for i, roi in enumerate(roiList):
        print(roi)
        print(ROI_corr[i])
        print()
        np.save('{}subjects/{}/analysis/firstlevel/{}.feat/{}/both_{}_corrs.npy'.format(projdir, subject, run,
                                                                                      sourceROI, roi), ROI_corr[i])
    print(np.around(np.mean(ROI_corr, axis=0),2))
