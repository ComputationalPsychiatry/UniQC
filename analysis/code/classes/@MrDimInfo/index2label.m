function samplingPointLabels = index2label(this, arrayIndices)
% Returns array of index labels for specified voxel indices
%
%   Y = MrDimInfo()
%   indexLabelArray = index2label(this, arrayIndices)
%
% For 3D data, this usually returns the voxel coordinates of the specified
% voxel indices, for 4D fMRI, it additionally outputs the acquisition onset
% of the specified onsets, and so forth, all in their respective units
%
% This is a method of class MrDimInfo.
%
% IN
%   arrayIndices        matrix [nVoxels, nDims] of index vectors (in rows)
%                       specifying the position of the voxels in the
%                       multi-dimensional array
% OUT
%   samplingPointLabels     cell(nVoxel,1)  of {1,nDims} sample label cells
%                           e.g. {'x = 13 mm', 'y = 20 mm', 'z = -130 mm',
%                           'volume = 30 s', 'coil = 33', 'echo = 17 ms'};
%
% EXAMPLE
%   index2label
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

nVoxels = size(arrayIndices);

samplingPoints= this.index2sample(arrayIndices);

nVoxels = size(arrayIndices,1);

samplingPointLabels = cell(nVoxels,1);
for v = 1:nVoxels
    samplingPointLabels{v} = cell(1,this.nDims);
   
    for d = 1:this.nDims
        samplingPointLabels{v}{d} = sprintf('%s = %f %s', ...
            this.dimLabels{d}, samplingPoints(v,d), this.units{d});
    end
end
