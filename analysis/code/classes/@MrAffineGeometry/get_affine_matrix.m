function affineTransformationMatrix = get_affine_matrix(this)
% Transforms geometry parameters into affine 4x4 matrix (T*R*Z*S)
% with T = Translation, R = Rotation, Z = Zooming (Scaling with Resolution)
%      S = Shearing
% i.e. performing operations in the order from right to left, in particular
% rotation before translation
%
%   Y = MrAffineGeometry()
%   Y.get_affine_matrix(inputs)
%
% This is a method of class MrAffineGeometry.
%
% IN
%
% OUT
%
% EXAMPLE
%   get_affine_matrix
%
%   See also MrAffineGeometry spm_matrix
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-15
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

geometryNifti = this;

P(1:3) = geometryNifti.offcenter_mm;
P(4:6) = geometryNifti.rotation_deg*pi/180;
P(7:9) = geometryNifti.resolution_mm;
P(10:12) = geometryNifti.shear_mm;

affineTransformationMatrix = spm_matrix(P);