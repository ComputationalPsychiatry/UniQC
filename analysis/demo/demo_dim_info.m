% Script demo_dim_info
% Exemplifies creation and usage of MrDimInfo class for retrieving and
% manipulating indices of multi-dimensional array
%
%  demo_dim_info
%
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-01-23
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Construct common dimInfo objects: 
%   a) 4D EPI-fMRI array, with fixed TR
%   b) 5D multi-coil time series 
%   c) 5D multi-echo time series
%   d) Create 5D multi-coil time series via nSamples and ranges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% a) creates standard 4D dim info array from arraySize
% presets: units, dimLabels, resolutions
arraySize   = [64 50 33 100];
dimInfo     = MrDimInfo('nSamples', arraySize);


% b) creates standard 5D dim info array from arraySize and resolutions
% presets of dimLabels, startingPoint = [1 1 1 1 1];
arraySize   = [64 50 33 100 8];
resolutions = [3 3 3 2.5 1];
units       = {'mm', 'mm', 'mm', 's', ''};
dimInfo2    = MrDimInfo('nSamples', arraySize, 'resolutions', resolutions, ...
    'units', units);


% c) creates standard 5D dim info array from arraySize, resolutions,
% startingPoints
% no presets
arraySize   = [64 50 33 8 3];
resolutions = [3 3 3 2.5 25];
units       = {'mm', 'mm', 'mm', 's', 'ms'};
dimLabels   = {'x', 'y', 'z', 's', 'echo'};
firstSamplingPoint = [-110, -110, -80, 0, 15];
dimInfo3    = MrDimInfo('nSamples', arraySize, 'resolutions', resolutions, ...
    'units', units, 'firstSamplingPoint', firstSamplingPoint);

 
% d) Create 5D multi-coil time series via nSamples and ranges
% no presets, resolutions computed automatically
dimInfo4 = MrDimInfo(...
    'nSamples', [128 96 35 8 1000], ...
     'dimLabels', {'x', 'y', 'z', 'coils', 'volumes'}, ...
     'units', {'mm', 'mm', 'mm', '', 's'}, ...
     'ranges', {[2 256], [2 192], [3 105], [1 8], [0 2497.5]});

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Modify dimInfo-dimensions via set_dims-command
% a) Specify non-consecutive sampling-points (e.g. coil channels)
% b) Shift start sample of dimensions (e.g. centre FOV in x/y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% a) Specify non-consecutive sampling-points (e.g. coil channels)
dimInfo3.set_dims('coil', 'samplingPoints', [2 3 4 7 8 10 11 12])
% Note that there is no concept of resolution here anymore, since there is
% equidistant spacing!
dimInfo3.resolutions

% b) Shift start sample of dimensions (e.g. centre FOV in x/y)
dimInfo4.set_dims([1 2], 'arrayIndex', [65 49], 'samplingPoint', [0 0]);
dimInfo4.ranges(:,1:2)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Display absolute indices of selected first/center/last voxel
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% voxelIndexFirst = [1,1,1,1,1];
% voxelIndexCenter = [64, 46, 30, 16, 500];
% voxelIndexLast = [128 92 60 32 1000];
% 
% voxelIndexArray = {
%     voxelIndexFirst
%     voxelIndexCenter
%     voxelIndexLast
%     };
% 
% nVoxels = numel(voxelIndexArray);
% 
% absoluteIndexArray = dimInfoMultiCoil.get_indices(...
%    voxelIndexArray);
% 
% fprintf('===\ndimInfo.get_indices(voxelIndexArray): \n');
% for iVoxel = 1:nVoxels
%    fprintf('absolute Voxel Index, voxel %d:', iVoxel);
%    disp(absoluteIndexArray{iVoxel});
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% 2. Display strings with units: absolute indices of selected 
% %   first/center/last voxel
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% indexLabelArray = dimInfoMultiCoil.get_index_dimLabels(...
%     voxelIndexArray);
% 
% fprintf('===\ndimInfo.get_index_dimLabels(voxelIndexArray): \n');
% for iVoxel = 1:nVoxels
%     fprintf('Voxel %d: ', iVoxel);
%     fprintf('%s ',indexLabelArray{iVoxel}{:});
%     fprintf('\n\n');
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% 3. Back-transform: Retrieve voxel index from absolute index
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% retrievedVoxelIndexArray = dimInfoMultiCoil.get_voxels(absoluteIndexArray);
% 
% fprintf('===\ndimInfo.get_voxels(absoluteIndexArray): \n');
% for iVoxel = 1:nVoxels
%    fprintf('retrieved Voxel Index in Array, voxel %d:', iVoxel);
%    disp(retrievedVoxelIndexArray{iVoxel});
% end
