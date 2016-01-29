function samplingPoints = index2sample(this, arrayIndices)
% Returns index (coordinate) as given by dim-info for specific voxel samplingPoints
%
%   Y = MrDimInfo()
%   samplingPoints = Y.index2sample(arrayIndices)
%
% If the samplingPoints-arrays are filled explicitly, these values are taken. If
% not, then labelIndex = range(1) + (arrayIndex-1)*resolution is returned
% for the respective dimension
%
% This is a method of class MrDimInfo.
%
% IN
%   arrayIndices        matrix [nVoxels, nDims] of absolute 
%                       voxel samplingPoints (one per row) within array
% OUT
%   samplingPoints      matrix [nVoxels, nDims] of voxel
%                       samplingPoints in coordinate system given by dimInfo
%   
% EXAMPLE
%   index2sample([3 4 5])
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

nVoxels = size(arrayIndices,1);

samplingPoints = zeros(nVoxels,this.nDims);

for v = 1:nVoxels
    % for each dimension, take explicit samplingPoints
    for d = 1:this.nDims
        samplingPoints(v,d) = this.samplingPoints{d}(arrayIndices(v,d));
    end
end