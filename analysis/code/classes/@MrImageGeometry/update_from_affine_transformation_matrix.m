function this = update_from_affine_transformation_matrix(this, ...
    affineTransformationMatrix)
% Updates properties of MrImageGeometry from affine 4x4 transformation
% matrix
%
%   Y = MrImageGeometry()
%   Y.update_from_affine_transformation_matrix(affineTransformationMatrix)
%
% This is a method of class MrImageGeometry.
%
% IN
%
% OUT
%
% EXAMPLE
%   update_from_affine_transformation_matrix
%
%   See also MrImageGeometry spm_matrix, spm_imatrix
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-27
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
P = spm_imatrix(affineTransformationMatrix);
this.offcenterMillimeters       = P(1:3);
this.rotationDegrees        = P(4:6)/pi*180;
this.resolutionMillimeters   = P(7:9);
this.shearMillimeters        = P(10:12);