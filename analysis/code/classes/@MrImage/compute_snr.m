function snr = compute_snr(this, varargin)
% computes signal-to-noise-ratio image (snr) over 4th dimension of MrImage
% NOTE: short-cut for compute_stat_image('snr')
%
%   Y = MrImage()
%   Y.compute_snr('PropertyName', PropertyValue)
%
% This is a method of class MrImage.
%
% IN
%   'PropertyName'
%               'selectedVolumes'       [1,nVols] vector of selected
%                                       volumes for statistical calculation
% OUT
%   snr         MrImage holding voxel-wise signal-to-noise ratio (snr)
%
% EXAMPLE
%   Y = MrImage()
%   snr = Y.compute_snr('selectedVolumes', [6:100])
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

snr = this.compute_stat_image('snr', varargin{:});
