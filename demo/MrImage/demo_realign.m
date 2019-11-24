% Script demo_realign
% Shows realignment for n-dimensional data with different scenarios of 4D
% subsets feeding into estimation, and parameters applied to other subsets,
% e.g.
%   - standard 4D MrImageSpm realignment, with or without weighting of
%     particular voxels
%   - multi-echo data, 1st echo realigned, applied to all echoes
%   - complex data, magnitude data realigned, phase data also shifted
%   - multi-coil data, root sum of squares realigned, applied to each coil
%
%  demo_realign
%
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-25
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. 4D fMRI, real valued, standard realignment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

Y = MrImage(fileTest);
[rY,rp] = Y.realign();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. 4D fMRI, real valued, weighted realignment with manual mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

Y = MrImage(fileTest);

% mask including only 90 percentile mean voxel intensities
M = Y.mean('t');
M = M.threshold(M.prctile(90));

[rY2,rp2] = Y.realign('weighting', M);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. 5D multi-echo fMRI, realignment variants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples = get_path('examples');
pathMultiEcho = fullfile(pathExamples, 'nifti', 'data_multi_echo');

% loads all 4D nifti files (one per echo) in 5D array; takes dim name of
% 5th dimension from file name
I = MrImage(fullfile(pathMultiEcho, 'multi_echo*.nii'));

TE = [9.9, 27.67 45.44];
I.dimInfo.set_dims('echo', 'units', 'ms', 'samplingPoints', TE);

%% Realign 10 volumes via 1st echo

rI = I.realign('applicationIndexArray', {'echo', 1:3});
plot(rI-I, 't', 11);

%% Realign 10 volumes via mean of echoes

meanI2 = I2.mean('echo');
r2I2 = I2.copyobj.realign('representationIndexArray', meanI2, ...
    'applicationIndexArray', {'echo', 1:3});
plot(r2I2-I2, 't', 11);
