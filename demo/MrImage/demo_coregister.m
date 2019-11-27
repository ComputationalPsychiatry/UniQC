clear;
close all;
clc;
%% load data

pathData        = get_path('examples');

fileFunctional      = fullfile(pathData, 'nifti', 'rest', 'fmri_short.nii');
fileFunctionalMean  = fullfile(pathData, 'nifti', 'rest', 'meanfmri.nii');
fileStructural      = fullfile(pathData, 'nifti', 'rest', 'struct.nii');

% stationary image is the mean functional
S = MrImageSpm4D(fileFunctionalMean);
S.parameters.save.fileName = 'funct.nii';
% moving image is the structural
M = MrImageSpm4D(fileStructural);
M.parameters.save.fileName = 'struct.nii';
%% and plot (voxel space)
S.plot;
M.plot;

% spm check registration
M.plot('plotType', 'spmi', 'overlayImages', S);

%% Coregister, but only update geometry
[cZG, rigidCoregistrationTrafoG] = M.coregister_to(S, ...
    'applyTransformation', 'geometry');
disp(rigidCoregistrationTrafoG);

% looks the same as before (voxel-space plot)
cZG.plot(); 

% but looks different in checkreg... (respects world space)
% Note: A good way to check the alignment of images is the contour plot
% option offered in the SPM checkreg view. Simply right-click on the mean
% functional image and select 'contour -> Display onto -> all'. The corpus
% callosum and the ventricles are an area with good contrast to check the
% registration.
cZG.plot('plotType', 'spmi', 'overlayImages', {S, M});

%% Coregister with reslicing of data
[cZD, rigidCoregistrationTrafoD] = M.coregister_to(S, ...
'applyTransformation', 'data');
disp(rigidCoregistrationTrafoD);

% compare to the mean functional image - both are now in the same voxel
% space
cZD.plot();

%% Coregister with other images
otherImages = M.log();
otherImages.plot();

[cMO, rigidCoregistrationTrafoO, otherImagesO] = M.coregister_to(S, ...
    'applyTransformation', 'data', 'otherImages', otherImages);

S.plot();
cMO.plot();
otherImagesO{1}.plot;

%% estimate affine coregistration for comparison
[cZAffine, affineTrafo] = M.coregister_to(S, ...
    'applyTransformation', 'geometry', 'trafoParameters', 'affine');
% rigid transformation
disp(rigidCoregistrationTrafoG);
% affine transformation
disp(affineTrafo);

%% estimate using Normalised Cross Correlation as objective function
[outImageNCC, rigidCoregTrafoNCC] = M.coregister_to(S, ...
'applyTransformation', 'geometry', 'objectiveFunction', 'ncc');
disp(rigidCoregTrafoNCC);

%% estimate using smaller separation
[outImageSeparation, rigidCoregTrafoSeparation] = M.coregister_to(S, ...
'applyTransformation', 'geometry', 'separation', [4 2 1 0.5]);
disp(rigidCoregTrafoSeparation); % doesn't change much

%% estimate using higher tolerances
% tolerances are given for the upt to 12 affine transformation parameters,
% namely translation, rotation, scaling and shear
% here, we only use the first 6 for a rigid body estimation
[outImageTolerances, rigidCoregTrafoTolerances] = M.coregister_to(S, ...
'applyTransformation', 'geometry', 'tolerances', [0.1 0.1 0.1 0.01 0.01 0.01]);
disp(rigidCoregTrafoTolerances); % not too bad

%% estimate with more histogram smoothing
[outImageHistSmoothing, rigidCoregTrafohistSmoothing] = M.coregister_to(S, ...
'applyTransformation', 'geometry', 'histSmoothingFwhm', [14 14]);
disp(rigidCoregTrafohistSmoothing); % pretty similar as well