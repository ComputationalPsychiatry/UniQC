function this = extract(this, image, mask)
% Extracts data within mask from given image
%
%   Y = MrRoi()
%   Y.extract(image, mask)
%
% This is a method of class MrRoi.
%
% IN
%   image       MrImage of which data shall be extracted within mask
%   mask        MrImage (binary mask), of which voxels shall be extracted
% OUT
%   this.perSlice.data
%   this.perVolume.data
%
% EXAMPLE
%   extract
%
%   See also MrRoi
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-18
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
nSlices  = image.geometry.nVoxels(3);
nVolumes = image.geometry.nVoxels(4);
this.data = cell(nSlices,1);
this.perSlice.nVoxels = zeros(nSlices,1);

maskGeometry = mask.geometry.copyobj;

% we don't care about difference in nVolumes
if maskGeometry.nVoxels(4) == 1
    maskGeometry.nVoxels(4) = image.geometry.nVoxels(4);
end
    

tolerance = 1e-5;
[hasEqualGeometry, diffGeom1, diffGeom2] = image.geometry.comp(...
   	maskGeometry, tolerance);

if ~hasEqualGeometry
    error('Roi extraction: Image geometries do not match. Resize Image or Mask');
else
    for iSlice = 1:nSlices    
        % reshape data of slice into nVoxelX * nVoxelY, nVolumes 2D Matrix
        dataSlice = reshape(image.data(:,:,iSlice, :), [], nVolumes);
        
        % create 1-dimensional vector of indices for voxels within mask
        maskSlice = find(mask.data(:,:,iSlice));
        
        this.data{iSlice} = dataSlice(maskSlice,:);
        this.perSlice.nVoxels(iSlice,1) = (size(this.data{iSlice}, 1));
    end
    
    
    this.nSlices = nSlices;
    this.nVolumes = nVolumes;
    this.perVolume.nVoxels = sum(this.perSlice.nVoxels);
    this.name = sprintf('roi (%s), image (%s)', mask.name, image.name);
end