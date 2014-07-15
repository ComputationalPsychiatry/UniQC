function fh = plot(this, varargin)
%plots an MR image per slice
%
%   Y  = MrImage
%   fh = Y.plot('ParameterName', ParameterValue)
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'plotMode', transformation of data before plotting
%                           'linear' (default), 'log'
%               'displayRange' [1,2] vector for pixel value = black and
%                                               pixel value = white
%               'selectedVolumes' [1,nVols] vector of selected volumes to
%                                           be displayed
%               'selectedSlices' [1,nSlices] vector of selected slices to
%                                           be displayed
%                                 choose Inf to display all volumes
%               'useSlider'     true or false
%                               provides interactive slider for
%                               slices/volumes; 
%                               assumes default: selectedSlices = Inf
%                                                selectedVolumes = Inf
% OUT
%
% EXAMPLE
%   Y.plot('selectedVolumes', [6:10])
%   Y.plot('displayRange', [0 1000])
%   Y.plot('useSlider', true, 'selectedVolumes', Inf);
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-05-21
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Analysis Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

defaults.displayRange = [0 0.8*max(max(max(this.data(:,:,:,1))))];
defaults.selectedVolumes = 1;
defaults.selectedSlices = Inf;
defaults.useSlider = false;
defaults.plotMode = 'linear';
args = propval(varargin, defaults);
strip_fields(args);

% slider enables output of all Slices and Volumes per default, strip data
% again under this assumption, if slider is used for display
if useSlider
    defaults.selectedVolumes = Inf;
    defaults.selectedSlices = Inf;
    args = propval(varargin, defaults);
    strip_fields(args);
end

% convert Inf to actual number of volumes/slices
if isinf(selectedVolumes)
    selectedVolumes = 1:this.geometry.nVoxels(4);
end

if isinf(selectedSlices)
    selectedSlices = 1:this.geometry.nVoxels(3);
end

if isempty(this.data)
    error(sprintf('Data matrix empty for MrImage-object %s', this.name));
end

dataPlot = this.data(:,:,selectedSlices,selectedVolumes);

switch plotMode
    case 'linear' %nothing happens'
    case 'log'
        dataPlot = log(abs(dataPlot));
        displayRange = [0 0.8*max(max(max(dataPlot)))];
end

nVolumes = numel(selectedVolumes);
nSlices = numel(selectedSlices);

% slider view
if useSlider
    slider4d(dataPlot, @plot_abs_image, ...
        nSlices);
% to also plot phase:
%    slider4d(dataPlot, @plot_image_diagnostics, ...
%        nSlices);
else
    for iVol = 1:nVolumes 
        stringTitle = sprintf('%s - volume %d', this.name, ...
            selectedVolumes(iVol));
        fh = figure('Name', stringTitle, 'WindowStyle', 'docked');
        montage(permute(dataPlot(:,:,:,iVol), [1, 2, 4, 3]), ...
            'DisplayRange', displayRange);
        title(str2label(stringTitle));
    end    
end