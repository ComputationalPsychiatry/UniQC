function voxelIndexArray = get_voxels(this, labelIndexArray)
% Returns voxel indices corresponding to label (coordinate) indices
%
%   Y = MrDimInfo()
%   voxelIndexArray = get_voxels(this, labelIndexArray)
%
% Inverse operation to get_indices
%
% This is a method of class MrDimInfo.
%
% IN
%   labelIndexArray     cell(nVoxels,1) or vector [1, nDims] of voxel
%                       indices in coordinate system given by dimInfo
%
% OUT
%   voxelIndexArray     cell(nVoxels,1) or vector [1, nDims] of absolute 
%                       voxel indices within array
%
% EXAMPLE
%   get_voxels
%
%   See also MrDimInfo MrDimInfo.get_indices
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
if ~iscell(labelIndexArray)
    labelIndexArray = {labelIndexArray};
end

nVoxels = numel(labelIndexArray);

voxelIndexArray = cell(nVoxels,1);

for v = 1:nVoxels
    % generate current output index element
    voxelIndexArray{v} = cell(1, this.nDims);
    
    % convert current voxel index to vector, if not already
    labelIndex = labelIndexArray{v};
    if iscell(labelIndex)
        labelIndex = cell2mat(labelIndex);
    end
    
    % for each dimension, either take explicit indices, if given, or
    % compute from range and resolution
    for d = 1:this.nDims
        hasExplicitLabels = ~isempty(this.indices{d});
        if hasExplicitLabels
            voxelIndexArray{v}{d} = find(this.indices{v},1);
        else
            voxelIndexArray{v}{d} = (labelIndex(d)-this.ranges{d}(1))...
                /this.resolutions(d) + 1;
        end
    end
end

% for 1-element input, convert to vector output
if nVoxels == 1
    voxelIndexArray = voxelIndexArray{1};
end