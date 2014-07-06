function statMrImage = compute_stat_image(this, statImageType, varargin)
% wrapper for computing different statistical images (taken over time series)
% while retaining image geometry information
%
%   Y = MrImage()
%   statMrImage = Y.compute_stat_image(statImageType, ...
%                                       'PropertyName', PropertyValue, ...)
%
% This is a method of class MrImage.
%
% IN
%   statImageType   'snr'       (default), ignoring voxels with sd < 1e-6 
%                   'sd'        standard deviation, 
%                   'mean'
%                   'coeffVar'  (coefficient of variance) = 1/snr;
%                               ignoring voxels with mean < 1e-6
%                               
%   'PropertyName'
%               'selectedVolumes'       [1,nVols] vector of selected
%                                       volumes for statistical calculation
% OUT
%   statMrImage     output statistical image. See also MrImage
%
% EXAMPLE
%   Y = MrImage()
%   snr = Y.compute_stat_image('snr', 'selectedVolumes', [6:100]);
%
%   See also MrImage
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

defaults.selectedVolumes = Inf;

% fills in default arguments not given as input
args = propval(varargin, defaults);

% strips input fields from args-structure,
% i.e. args.selectedVolumes => selectedVolumes
strip_fields(args);

hasSelectedVolumes = ~isinf(selectedVolumes);

if ~hasSelectedVolumes
    selectedVolumes = 1:this.parameters.geometry.nVoxel(4);
end

% setup of output image
statMrImage = MrImage;
statMrImage.parameters = this.parameters;
statMrImage.parameters.geometry.nVoxel(4) = 1; % no time series in stat images
statMrImage.name = sprintf('%s - %s', statImageType, this.name);

switch lower(statImageType)
    case 'mean'
        statMrImage.data = mean(this.data(:,:,:,selectedVolumes), 4);
    case 'sd'
        statMrImage.data = std(this.data(:,:,:,selectedVolumes), 0, 4);
    case 'snr'
        tmpSd = std(this.data(:,:,:,selectedVolumes), 0, 4);
        tmpSd(tmpSd < 1e-6) = 1; % to avoid divisions by zero
        statMrImage.data = mean(this.data(:,:,:,selectedVolumes), 4)...
            ./tmpSd;
    case {'coeffvar', 'coeff_var'}
        tmpMean= mean(this.data(:,:,:,selectedVolumes), 4);
        tmpMean(tmpMean < 1e-6) = 1; % to avoid divisions by zero
        statMrImage.data = std(this.data(:,:,:,selectedVolumes), 0, 4) ...
            ./tmpMean;
end
