function this = realign(this, varargin)
% Realigns n-dimensional image according to representative derived 4D image(s),
% and applies resulting realignment parameters to respective subsets of the
% n-d image
%
%   Y = MrImage()
%   Y.realign(representationType, splitDimensions)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   realign
%
%   See also MrImage MrImage.wrap_spm_method MrImageSpm4D.realign
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-21
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

% use cases: abs of complex, single index on many!
defaults.representationType = 'sos'; %'abs'
defaults.representationIndexArray = {}; % default: take first index of extra dimensions!
defaults.applicationIndexArray = {}; % default: apply to all
defaults.methodParameters = {{}}; %? quality?
defaults.splitDimLabels = {};

args = propval(varargin, defaults);
strip_fields(args);

%% create 4 SPM dimensions via complement of split dimensions
% if not specified, standard dimensions are taken
if isempty(splitDimLabels)
    dimLabelsSpm4D = {'x','y','z','t'};
    splitDimLabels = setdiff(this.dimInfo.dimLabels, dimLabelsSpm4D);
end

% default representation: take first index of all extra (non-4D) dimensions
% e.g.,  {{'coil'}    {[1]}    {'echo'}    {[1]}}
if isempty(representationIndexArray) && ~isempty(splitDimLabels)
    representationIndexArray = reshape(splitDimLabels, 1, []);
    representationIndexArray(2,:) = {1};
    representationIndexArray = {reshape(representationIndexArray, 1, [])};
end

this.apply_spm_method_on_many_4d_splits(@realign, representationIndexArray, ...
    'methodParameters', methodParameters{:}, ..., ...
    'applicationIndexArray', applicationIndexArray, ...
    'applicationMethodHandle', @apply_realign);

