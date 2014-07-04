function this = load_cpx(this, filename, selectedVolumes, selectedCoils)
% loads Philips cpx files (coil-wise image reconstructions) using GyroTools
% code (read_mr_data, read_cpx)
%
%   Y = MrImage()
%   Y.load_cpx(filename, selectedVolumes, selectedCoils)
%
% This is a method of class MrImage.
%
% IN
%   filename    e.g. 'fmri.cpx'
%   selectedVolumes     [1, nVols] vector of volumes to be loaded
%                       Inf = all volumes in file (default)
%   selectedCoils       [1, nCoils] vector of coils to be loaded
%                       0   = Sum of Squares of all coils (default)
%                       Inf = all coils are loaded (TODO: into which
%                             dimension of MrImage?
%
% OUT
%
% EXAMPLE
%   load_cpx
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-04
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

hasSelectedVolumes = ~isinf(selectedVolumes);
hasSelectedCoils = ~isinf(selectedCoils);
computeSoS = selectedCoils == 0;

readParams = create_read_param_struct(filename);

if hasSelectedVolumes
    readParams.dyn = reshape(selectedVolumes, [], 1);
end

if hasSelectedCoils && ~computeSoS
    readParams.coil = reshape(selectedCoils, [], 1);
end

border = 0;
flip = 0;
kspace = 0;
this.data = read_cpx(filename, border, flip, kspace, readParams);

% compute root sum of squares over all coils
if computeSoS
    this.data = sqrt(sum(this.data.*conj(this.data), 5));
end

this.data = abs(double(squeeze(this.data))); % TODO: allow complex data...


% put volumes back into 4th dimension
if numel(readParams.loca) == 1
    this.data = permute(this.data, [1 2 4 3]);
end

