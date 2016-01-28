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
%% 1. Construct default dimInfo object: 4D EPI-fMRI array, with fixed TR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% creates standard 4D dim info array 
% presets of nSamples, units, dimLabels, resolutions, 
arraySize = [64 50 33 100];
dimInfo = MrDimInfo('nSamples', arraySize);

 

% creates standard 5D dim info array from arraySize
% presets of units, dimLabels, resolutions
arraySize = [64 50 33 8 3];
dimInfo2 = MrDimInfo('nSamples', arraySize);

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Construct multi-coil dimInfo object: 5D EPI-fMRI array, with fixed TR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dimInfoMultiCoil = MrDimInfo(...
    'nSamples', [128 92 60 32 1000], ...
     'dimLabels', {'x', 'y', 'z', 'coils', 'volumes'}, ...
     'units', {'mm', 'mm', 'mm', '', 's'}, ...
     'resolutions', [2 2 3 1 2.5], ...
     'ranges', {[-128 126], [-92 90], [-90 87], [1 32], [0 2497.5]});

 
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
