function labelIndexArray = get_indices(this, voxelIndexArray)
% Returns index (coordinate) as given by dim-info for specific voxel indices
%
%   Y = MrDimInfo()
%   labelIndexArray = get_indices(this, voxelIndexArray)
%
% If the indices-arrays are filled explicitly, these values are taken. If
% not, then labelIndex = range(1) + (voxelIndex-1)*resolution is returned
% for the respective dimension
%
% This is a method of class MrDimInfo.
%
% IN
%   voxelIndexArray     cell(nVoxels,1) or vector [1, nDims] of absolute 
%                       voxel indices within array
% OUT
%   labelIndexArray      cell(nVoxels,1) or vector [1, nDims] of voxel
%                       indices in coordinate system given by dimInfo
%   
% EXAMPLE
%   get_indices([3 4 5])
%       => returns
%
%   See also MrDimInfo demo_dim_info MrImageGeometry MrDimInfo.get_voxels
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
if ~iscell(voxelIndexArray)
    voxelIndexArray = {voxelIndexArray};
end

nVoxels = numel(voxelIndexArray);

labelIndexArray = cell(nVoxels,1);

for v = 1:nVoxels
    % generate current output index element
    labelIndexArray{v} = cell(1, this.nDims);
    
    % convert current voxel index to vector, if not already
    voxelIndex = voxelIndexArray{v};
    if iscell(voxelIndex)
        voxelIndex = cell2mat(voxelIndex);
    end
    
    % for each dimension, either take explicit indices, if given, or
    % compute from range and resolution
    for d = 1:this.nDims
        hasExplicitLabels = ~isempty(this.indices{d});
        if hasExplicitLabels
            labelIndexArray{v}{d} = this.indices{v}{d};
        else
            labelIndexArray{v}{d} = this.ranges{d}(1) + ...
                (voxelIndex(d)-1)*this.resolutions(d);
        end
    end
end

% for 1-element input, convert to vector output
if nVoxels == 1
    labelIndexArray = labelIndexArray{1};
end