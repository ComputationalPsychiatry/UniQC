function this = t_filter(this, trSeconds, cutoffSeconds)
% high-pass filters temporally (4th dimension of the image) as SPM
%
%   MrImage = t_filter(MrImage)
%
% This is a method of class MrImage.
%
% IN
%   trSeconds       repetition time between subsequent scans/volumes (4th
%                   dim samples)
%   cutoffSeconds   slower drifts than this will be filtered out
%
% OUT
%
% EXAMPLE
%   t_filter
%
%   See also MrImage spm_filter
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-02
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

% convert to 2D
nVoxel = this.parameters.geometry.nVoxel;
Y = reshape(this.data, [], nVoxel(4));
nVoxel3D = prod(nVoxel(1:3));

% create K for spm_filter and do it
K.row = (1:nVoxel3D)';
K.RT = trSeconds;
K.HParam = cutoffSeconds;

Y = spm_filter(K, Y);

% back-conversion to 4D image
this.data = reshape(Y, nVoxel);
