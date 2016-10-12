function this = read_matrix_from_workspace(this, inputMatrix)
% Reads in matrix from workspace, updates dimInfo according to data
% dimensions
%
%   Y = MrDataNd()
%   Y.read_matrix_from_workspace()
%
% This is a method of class MrDataNd.
%
% IN
%
% OUT
%
% EXAMPLE
%   read_matrix_from_workspace
%
%   See also MrDataNd
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-10-12
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

% check whether valid dimInfo now

% TODO: update dimInfo, but keeping information that is unaltered by 
% changing data dimensions...
% e.g. via dimInfo.merge
hasDimInfo = isa(this.dimInfo, 'MrDimInfo');


this.data = inputMatrix;

% remove singleton 2nd dimension kept by size command
nSamples = size(this.data);
if numel(nSamples) == 2
    nSamples(nSamples==1) = [];
    resolutions = ones(1, numel(nSamples));
end

% set dimInfo or update according to actual number of samples
if hasDimInfo
    this.dimInfo = MrDimInfo('nSamples', nSamples, ...
        'resolutions', resolutions);
else
    if any(nSamples) % only update dimInfo, if any samples loaded
        if numel(nSamples) ~= this.dimInfo.nDims
            error('Number of dimensions in dimInfo (%d) does not match dimensions in data (%d)', ...
                this.dimInfo.nDims, numel(nSamples));
        else
            this.dimInfo.set_dims(1:this.dimInfo.nDims, 'nSamples', nSamples);
        end
    end
end
