function otherImage = rot90(this, K)
% (Multiple of) 90 deg image rotation; mimicks rot90 in matlab functionality
%
%   Y = MrImage()
%   Y.rot90(K)
%
% This is a method of class MrImage.
%
% IN
%   K   multiple of 90 degrees used for counterclockwise rotation 
%       i.e.    K = 0,1,2 (counterclockwise rotation) 
%           or  K = -1,-2,-3,... (clockwise rotation);
%       default : 1
% 
% OUT
%   otherImage      MrImage where data matrix is rotated and header is updated to
%                   reflect that change
%
% EXAMPLE
%   Y = MrImage();
%   Y.rot90(1); % rotate all slices counterclockwise by 90 degrees
%   Y.rot90(-2) % rotate all slices clockwise by 2*90 = 180 degrees
%
%   See also MrImage categorical/rot90
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-08-04
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
if nargin < 2
    K = 1;
end

otherImage = this.copyobj;
geometry = otherImage.geometry;
nVoxels = otherImage.geometry.nVoxels;

% update geometry-header with affine rotation matrix around z (slice) axis
% Note: -1 * K reflects the SPM neurological convention (looking from
% above) compared to the direction of foot/head (bottom to top)
A = eye(4);
A(1,1) = cos(-K*90/180*pi); A(2,1) = sin(-K*90/180*pi); 
A(1,2) = -sin(-K*90/180*pi); A(2,2) = cos(-K*90/180*pi);
geometry.apply_transformation(A);

% do first and second dimension change through rotation?
doSwapDimensions = mod(K,2) == 1;

if doSwapDimensions
    tmpData = zeros(nVoxels([2 1 3 4]));
    % resolution, nVoxels and FoV have to be updated automatically
    geometry.nVoxels = geometry.nVoxels([2 1 3 4]);
    geometry.FOV_mm = geometry.FOV_mm([2 1 3]);
    geometry.resolution_mm = geometry.resolution_mm([2 1 3]);
else
    tmpData = zeros(nVoxels);
end


for t = 1:nVoxels(4)
    for z = 1:nVoxels(3)
        tmpData(:,:,z,t) = rot90(otherImage.data(:,:,z,t),K);
    end
end

otherImage.data = tmpData;