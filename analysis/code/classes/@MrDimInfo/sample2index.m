function arrayIndices = sample2index(this, samplingPoints)
% Returns voxel samplingPoints corresponding to label (coordinate) samplingPoints
%
%   Y = MrDimInfo()
%   arrayIndices = sample2index(this, samplingPoints)
%
% Inverse operation to get_samplingPoints
%
% This is a method of class MrDimInfo.
%
% IN
%   samplingPoints     [nVoxels, nDims] of voxel samplingPoints
%                      (one per row) in coordinate system given by dimInfo
%
% OUT
%   arrayIndices        [nVoxels, nDims] of absolute
%                       voxel samplingPoints within array
%
% EXAMPLE
%   sample2index
%
%   See also MrDimInfo MrDimInfo.get_samplingPoints
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

nVoxels = size(samplingPoints,1);

arrayIndices = zeros(nVoxels,this.nDims);

for v = 1:nVoxels
    % find voxel index with closest (euclidean) sampling point in array
    for d = 1:this.nDims
        [~, arrayIndices{v}(d)] = ...
            min(abs(this.samplingPoints{d} - samplingPoints(v,d)));
    end
end