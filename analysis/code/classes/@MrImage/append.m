function this = append(this, otherImage)
% appends other MrImage (of same 3D geometry) via 4th dim to end of MrImage
%
%   Y = MrImage()
%   Y.append(otherImage)
%  
%   OR
%   
%   Y.append(fileName);
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   Y = MrImage();
%   otherImage = MrImage();
%
%   Y.append(otherImage);
%   Y.append('single_subj_T1.nii');
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-20
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

if ischar(otherImage) % other image given as fileName;
    fileName = otherImage;
    otherImage = MrImage(fileName);
end

otherGeometry = otherImage.geometry.copyobj;
nVoxelsOther = otherGeometry.nVoxels;

 % for other nVolumes, 
otherGeometry.nVoxels(4) = this.geometry.nVoxels(4);
[hasEqualGeometry, dg1, dg2] = this.geometry.comp(otherGeometry);

if hasEqualGeometry
    this.data(:,:,:, end+1:end+nVoxelsOther(4)) = ...
        otherImage.data;
    this.geometry.nVoxels(4) = this.geometry.nVoxels(4) + ...
        nVoxelsOther(4);
else
    fprintf('Geometries do not match. No appending possible: \n');
    dg1.print;
    dg2.print;
end