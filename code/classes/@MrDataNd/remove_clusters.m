function outputImage = remove_clusters(this, nPixelsPerClusterRange, applicationDimension)
% Removes all voxel clusters within in given range of voxel counts, either
% slice-wise or volume-wise (8 or 26 neighbours) using Matlab's bwareaopen
% and sets the values of that area to a specified value (default: 0);
%
%   Y = MrImage()
%   clusterRemovedImage = Y.remove_clusters(nPixelsPerClusterRange, ...
%           applicationDimension)
%
% This is a method of class MrImage.
%
% IN
%   nPixelsPerClusterRange
%   applicationDimension      
%           dimensionality to perform operation
%           '2d' = slicewise application, separate 2d images (cluster
%           neighbours only considered within slice)
%           '3d' = neighbourhood considered as volume
%
% OUT
%   outputImage
%           MrImage where data matrix does not contain removed clusters
%
% EXAMPLE
%   Y = MrImage();
%   % remove all pixel clusters with 15 or less pixels (3D neighbourhood)
%   Y.remove_clusters([0 15], '3D');
%
%   See also MrImage imdilate MrImage.imerode perform_unary_operation bwareaopen

% Author:   Lars Kasper
% Created:  2019-11-03
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

BW = this.copyobj.binarize(0, 'exclude');

if nargin < 2
    nPixelsPerClusterRange = [0 0];
end

if nargin < 3
    is3D = true;
    applicationDimension = '3D';
else
    is3D = strcmpi(applicationDimension, '3D');
end

if is3D
    conn = 26; % use 26 neighbours in 3D (all faces and corners connected)
else
    conn = 8; % use 8 neighbours (in 2D)
end

% only crop, if required (i.e., connectivity components greater than 1)
if nPixelsPerClusterRange(1) > 1
    BW1 = BW.perform_unary_operation(@(x) bwareaopen(x, nPixelsPerClusterRange(1), conn), ...
        applicationDimension);
else
    BW1 = BW.copyobj;
end

if nPixelsPerClusterRange(2) > 0
    BW2 = BW.perform_unary_operation(@(x) bwareaopen(x, nPixelsPerClusterRange(2) + 1, conn), ...
        applicationDimension);
else
    BW2 = BW.copyobj;
end

% by the following subtraction, excluded voxels in both BW1 and BW2 will be 
% reincluded, hence, an exclusive or is reached, only removing clusters in
% the range between BW1 and BW2
BW = abs(BW - BW1 - BW2); 

outputImage = this.*BW;