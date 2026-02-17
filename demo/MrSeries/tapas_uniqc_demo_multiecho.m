% Script preprocessing
% Example of fMRI preprocessing of multi-echo data from
%
%  doi: https://doi.org/10.1101/2023.07.19.549746
%  subject 3 (small motion) and subject 8 (large instructed motion)
%
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2025-03-12
% Copyright (C) 2025 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


clear;
close all;
clc;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (0) Define data paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% general selection parameters
subjectId = 'sub-08';
nStartVolumesDiscard = 0; % discard start of time series
idxEcho = 1; % single echo analysis first (Echo 1-5)

% assemble file names
pathDataStudy = 'C:\Users\kasperla\OneDrive - University of Toronto\Documents\Personal\Projects\UniQC\data\openneuro\ds004662';
pathSubject = fullfile(pathDataStudy, subjectId);
fileArrayFunctionalEcho = strcat(...
    fullfile(pathSubject, 'func', sprintf('%s_task-handgrasp_run-1_echo-', subjectId)), ...
    {'1_bold.nii.gz'
    '2_bold.nii.gz'
    '3_bold.nii.gz'
    '4_bold.nii.gz'
    '5_bold.nii.gz'});

fileFunctional = fileArrayFunctionalEcho{idxEcho};


% TODO on Windows: deal with soft links in git annex/datalad
% fileFunctional = tapas_uniqc_simplify_path(...
%     fullfile(fileparts(fileFunctional), ...
%     '../../.git/annex/objects/41/0P/SHA256E-s182383883--b19d23dc642a1c6e58b453cfcccc9a0c13ee777d40e8007efd4a3994612720ca.nii.gz/SHA256E-s182383883--b19d23dc642a1c6e58b453cfcccc9a0c13ee777d40e8007efd4a3994612720ca.nii.gz'...
% ));

fileStructural      = fullfile(pathSubject, 'anat', sprintf('%s_T1w.nii.gz', subjectId));

dirResults          = ['preprocessing' filesep];


fileFunctional(end-2:end) = []; % no zipped file
fileStructural(end-2:end) = []; % no zipped file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (0) Load Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% TODO:Debug - the following works, but MrSeries S.data remains empty
X = MrImage(fileFunctional);
X.plot();

% create MrSeries object
S = MrSeries(fileFunctional);
% remove first five samples
S.data = S.data.select('t', (nStartVolumesDiscard+1):S.data.dimInfo.nSamples('t'));
% set save path (pwd/dirResults)
S.parameters.save.path = tapas_uniqc_prefix_files(S.parameters.save.path, ...
    dirResults);
% check geometry
disp(S.data.geometry);
% add anatomy
S.anatomy.load(fileStructural, 'updateProperties', 'none');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (2) Evaluate and Visualize raw data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check data first
S.compute_stat_images();
S.mean.plot('colorBar', 'on');
S.snr.plot('colorBar', 'on', 'displayRange', [0 80]);
S.data.plot('z', 24, 'sliceDimension', 't');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (3) Realign
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% looks good - now realign
S.realign();
% check data again
S.compute_stat_images();
S.mean.plot('colorBar', 'on');
S.snr.plot('colorBar', 'on', 'displayRange', [0 80]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (3) Coregister
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% anatomy --> mean
S.parameters.coregister.nameStationaryImage = 'mean';
S.parameters.coregister.nameTransformedImage = 'anatomy';
S.coregister();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (4) Segment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute tissue probability maps structural
S.parameters.compute_tissue_probability_maps.nameInputImage = 'anatomy';
S.compute_tissue_probability_maps();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (5) Compute Masks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we only want a grey matter mask
S.parameters.compute_masks.nameInputImages = 'tissueProbabilityMapGm';
S.parameters.compute_masks.nameTargetGeometry = 'mean';
S.compute_masks;
% check overlay
S.mean.plot('overlayImages', S.masks{1});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% (6) Smooth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% smooth with twice the voxel size
S.parameters.smooth.fwhmMillimeters = abs(S.data.geometry.resolution_mm) .* 2;
S.smooth;
% check data again
S.compute_stat_images();
S.mean.plot('colorBar', 'on');
S.snr.plot('colorBar', 'on', 'displayRange', [0 80]);