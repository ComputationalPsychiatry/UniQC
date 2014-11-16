function manualMask = draw_mask(this, varargin)
% Displays slices of a 3D volume to manually draw a polygonal mask on
% them and combines output into 3D mask with same image dimensions. 
%
%   Y = MrImage()
%   manualMask = Y.draw_mask('selectedSlices', Inf, 'selectedVolumes', 1)
%
% This is a method of class MrImage.
%
% IN
%   
%   selectedSlices  default: Inf (all) on which mask can be drawn
%   selectedVolumes default: 1 on which mask can be drawn
%
% OUT
%   manualMask      MrImage with same geometry as this image for 1st 3 
%                   dimensions 
%                   Unless number of selectedVolumes is greater than 1,
%                   manualMask will be a 3D image. 
%
% EXAMPLE
%   manualMask = Y.draw_mask('selectedSlices', Inf, 'selectedVolumes', 1)
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-11-13
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
defaults.selectedSlices = Inf;
defaults.selectedVolumes = 1;

args = propval(varargin, defaults);
strip_fields(args);

if isinf(selectedSlices)
    selectedSlices = 1:this.geometry.nVoxels(3);
end

if isinf(selectedVolumes)
    selectedVolumes = 1:this.geometry.nVoxels(4);
end

nSlicesSelected = numel(selectedSlices);
nVolumesSelected = numel(selectedVolumes);

manualMask                      = this.copyobj;
manualMask.geometry.nVoxels(4)  = 2;
manualMask.data                 = zeros(manualMask.geometry.nVoxels);
for iSlice = selectedSlices
    this.plot('selectedSlices', iSlice);
    manualMask.data(:,:,iSlice) = roipoly();
end