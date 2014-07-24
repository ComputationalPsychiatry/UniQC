function this = coregister_to(this, otherImage)
% Coregister this MrImage to another given MrImage
% NOTE: Also does reslicing of image
%
%   Y = MrImage()
%   Y.coregister_to(inputs)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   coregister_to
%
%   See also MrImage spm_coreg
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-24
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

% save data for spm as nifti

% run coregister job

% load back processed resliced image into this object
