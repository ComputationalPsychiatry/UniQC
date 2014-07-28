function this = apply_transformation(this, otherGeometry)
% Performs affine transformation on Geometry by multiplying of 4x4 affine matrix
%
%   Y = MrImageGeometry()
%   Y.apply_transformation(otherGeometry)
%
% This is a method of class MrImageGeometry.
%
% IN
%   otherGeometry   MrImageGeometry holding the affine transformation to be
%                   applied
% OUT
%
% EXAMPLE
%   apply_transformation
%
%   See also MrImageGeometry
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-28
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
% in spm_coreg: MM
rawAffineMatrix = this.geometry.get_affine_transformation_matrix();

% in spm_coreg: M
affineCoregistrationMatrix = otherGeometry.get_affine_transformation_matrix();

% compute inverse transformation via \, efficient version of:
% pinv(affineCoregistrationMatrix) * rawAffineMatrix 
processedAffineMatrix = affineCoregistrationMatrix * ...
    rawAffineMatrix;
this.geometry.update_from_affine_transformation_matrix(processedAffineMatrix);