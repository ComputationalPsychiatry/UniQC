%% Demonstrates basic and high dimensional functionality of (affine) image coregistration
% wrapping spm_coreg
clear;
close all;
clc;

%% load data

pathData        = get_path('examples');

fileFunctional      = fullfile(pathData, 'nifti', 'rest', 'fmri_short.nii');
fileFunctionalMean  = fullfile(pathData, 'nifti', 'rest', 'meanfmri.nii');
fileStructural      = fullfile(pathData, 'nifti', 'rest', 'struct.nii');

% stationary image is the mean functional
func = MrImage(fileFunctionalMean);
func.parameters.save.fileName = 'funct.nii';
% moving image is the structural
anat = MrImage(fileStructural);
anat.parameters.save.fileName = 'struct.nii';

%% 0) Introducing the data and plot (voxel space)
func.plot;
anat.plot;

% spm check registration
anat.plot('plotType', 'spmi', 'overlayImages', func);


%% I. Cases directly mimicking SPM's coreg behavior for different parameter settings
% nomenclature: 
% this          altered image (source, moving)
% stationary    reference image (coregister_to(stationary))
% other         other images to which estimated coregistration is applied after
%               estimation of this -> stationary trafo
% 
%% 1a) this: 3D; stationary: 3D; but only update geometry
%  -> trivial case, directly mimicking SPM's coregister and passing to
%  MrImageSpm4D
[cZG, rigidCoregistrationTrafoG] = anat.coregister_to(func, ...
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
cZG.plot('plotType', 'spmi', 'overlayImages', {func, anat});

%% 1b) Coregister with reslicing of data
[cZD, rigidCoregistrationTrafoD] = anat.coregister_to(func, ...
'applyTransformation', 'data');
disp(rigidCoregistrationTrafoD);

% compare to the mean functional image - both are now in the same voxel
% space
cZD.plot();
cZD.plot('overlayImages', func, 'overlayMode', 'edge');
%% 1c) Coregister with other images
otherImages = {anat.log(), anat.^-1};
otherImages{1}.plot(); otherImages{2}.plot()

[cMO, rigidCoregistrationTrafoO, otherImagesO] = anat.coregister_to(func, ...
    'applyTransformation', 'data', 'otherImages', otherImages);

func.plot();
cMO.plot();
otherImagesO{1}.plot;
otherImagesO{2}.plot;

%% 1d) Estimate affine coregistration for comparison
[cZAffine, affineTrafo] = anat.coregister_to(func, ...
    'applyTransformation', 'geometry', 'trafoParameters', 'affine');
% rigid transformation
disp(rigidCoregistrationTrafoG);
% affine transformation
disp(affineTrafo); % somewhat different

%% 1e) Estimate using Normalised Cross Correlation as objective function
[outImageNCC, rigidCoregTrafoNCC] = anat.coregister_to(func, ...
'applyTransformation', 'geometry', 'objectiveFunction', 'ncc');
disp(rigidCoregTrafoNCC);

%% 1f) Estimate using smaller separation
[outImageSeparation, rigidCoregTrafoSeparation] = anat.coregister_to(func, ...
'applyTransformation', 'geometry', 'separation', [4 2 1 0.5]);
disp(rigidCoregTrafoSeparation); % doesn't change much

%% 1g) Estimate using higher tolerances
% tolerances are given for the upt to 12 affine transformation parameters,
% namely translation, rotation, scaling and shear
% here, we only use the first 6 for a rigid body estimation
[outImageTolerances, rigidCoregTrafoTolerances] = anat.coregister_to(func, ...
'applyTransformation', 'geometry', 'tolerances', [0.1 0.1 0.1 0.01 0.01 0.01]);
disp(rigidCoregTrafoTolerances); % not too bad

%% 1h) Estimate with more histogram smoothing
[outImageHistSmoothing, rigidCoregTrafohistSmoothing] = anat.coregister_to(func, ...
'applyTransformation', 'geometry', 'histSmoothingFwhm', [14 14]);
disp(rigidCoregTrafohistSmoothing); % pretty similar as well

%% II. High-dimensional extensions

%% 2) this: nD; stationary: 3D; other: cell(nSplits,nOtherImages) of 3D images
pathExamples = get_path('examples');
pathMultiEcho = fullfile(pathExamples, 'nifti', 'data_multi_echo');

% loads all 4D nifti files (one per echo) in 5D array; takes dim name of
% 5th dimension from file name
ME = MrImage(fullfile(pathMultiEcho, 'multi_echo*.nii'));

TE = [9.9, 27.67 45.44];
ME.dimInfo.set_dims('echo', 'units', 'ms', 'samplingPoints', TE);

% plotting of pain
ME.plot('plotType', 'spmi', 'overlayImages', func)

%% 2a) representation: 3D; application: nD
%  -> one 3D part represents "this" image for the coregistration to
%  stationary, and the estimated coreg parameters are then applied to all
%  images in the application selections.

c2ME = ME.coregister_to(func, 'representationIndexArray', {'echo', 1}, ...
    'applicationIndexArray', {'echo', 1:3});

%% 2b) representation: nD; application: nD
%  -> individual 3D parts of "this" image are used for coregistration and
%  to the same stationary image; the estimated coreg parameters are then
%  applied to the corresponding application dimensions
%  Note: representation and application dimensions need to have the same
%  number of indices, and the corresponding images are always resliced
%  ('applyTransfomration', 'data'), such that one nD image object can be
%  formed in the end

c2ME = ME.coregister_to(func, 'representationIndexArray', {{'echo', 1}, ...
    {'echo', 2}, {'echo', 3}}, 'applicationIndexArray', {{'echo', 1}, ...
    {'echo', 2}, {'echo', 3}});

%% 3) this: nD; stationary: nD; other cell(nStationary, nOtherImages)
%  representation: nD; application: nD
%  -> Each 3D part representation of "this" is coregistered to the corresponding part of
%  stationary image as defined in representationIndexArray (i.e. the same
%  selection is applied to "this" and "stationaryImage") and the
%  corresponding parameters are then applied to the image defined in
%  applicationIndexArray
%  Note: The stationary image has to have the same dimensions for all
%  specified dimensions in the representationArray (e.g., echo), but other
%  unused dimensions might differ
%  Note2: for each representation selection, a set of unique application selections
%  has to be specified, e.g,. {'echo',1} ->  {'echo',1,'t',1:nVolumes}
%  and the corresponding images are always resliced ('applyTransformation',
%  'data'), such that one nD image object can be formed in the end

% replication of stationary image to match dimensions (representation per
% echo)
funcND = func.combine(repmat({func},3,1), 'echo');

c2ME = ME.coregister_to(funcND, 'representationIndexArray', {{'echo', 1}, ...
    {'echo', 2}, {'echo', 3}}, 'applicationIndexArray', {{'echo', 1}, ...
    {'echo', 2}, {'echo', 3}});