function sd = compute_sd(this, varargin)
% computes standard deviation image (sd) over 4th dimension of MrImage
% NOTE: short-cut for compute_stat_image('sd')
%
%   Y = MrImage()
%   Y.compute_sd('PropertyName', PropertyValue)
%
% This is a method of class MrImage.
%
% IN
%   'PropertyName'
%               'selectedVolumes'       [1,nVols] vector of selected
%                                       volumes for statistical calculation
% OUT
%   sd         MrImage holding voxel-wise standard deviation image (sd)
%
% EXAMPLE
%   Y = MrImage()
%   sd = Y.compute_sd('selectedVolumes', [6:100])
%
%   See also MrImage compute_stat_image
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-06
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

sd = this.compute_stat_image('sd', varargin{:});
