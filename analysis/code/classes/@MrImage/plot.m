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
%               'sliceDimension' (default: 3) determines which dimension
%                                shall be plotted as a slice
%               'useSlider'     true or false
%                               provides interactive slider for
%                               slices/volumes;
%                               assumes default: selectedSlices = Inf
%                                                selectedVolumes = Inf
%               'fixedWithinFigure' determines what dimension is plotted in
%                                  (subplots of) 1 figure
%                             'slice(s)'    all slices in 1 figure; new figure
%                                           for each volume
%                             'volume(s)'   all volumes in 1 figurel new figure
%                                           for each slice
%               'colorMap'    string, any matlab colormap name
%                               e.g. 'jet', 'gray'
%               'colorBar',     'on' or 'off' (default)
%                               where applicable, determines whether
%                               colorbar with displayRange shall be plotted 
%                               in figure;
% OUT
%
% EXAMPLE
%
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
defaults.sliceDimension = 3;
defaults.useSlider = false;
defaults.plotMode = 'linear';
defaults.fixedWithinFigure = 'volume';
defaults.colorMap = 'gray';
defaults.colorBar = 'off';
args = propval(varargin, defaults);
strip_fields(args);

doPlotColorBar = strcmpi(colorBar, 'on');

% slider enables output of all Slices and Volumes per default, strip data
% again under this assumption, if slider is used for display
if useSlider
    defaults.selectedVolumes = Inf;
    defaults.selectedSlices = Inf;
    args = propval(varargin, defaults);
    strip_fields(args);
end


if isempty(this.data)
    error(sprintf('Data matrix empty for MrImage-object %s', this.name));
end

% permute data dimensions for adjustible slice direction
switch sliceDimension
    case 1
        dataPlot = permute(this.data, [3 2 1 4]);
    case 2
        dataPlot = permute(this.data, [1 3 2 4]);
    case 3
        dataPlot = this.data;
end

% convert Inf to actual number of volumes/slices
if isinf(selectedVolumes)
    selectedVolumes = 1:size(dataPlot,4);
end

if isinf(selectedSlices)
    selectedSlices = 1:size(dataPlot,3);
end


dataPlot = dataPlot(:,:,selectedSlices,selectedVolumes);

switch plotMode
    case 'linear' %nothing happens'
    case 'log'
        dataPlot = log(abs(dataPlot));
        displayRange = [0 0.8*max(max(max(max(dataPlot))))];
end

nVolumes = numel(selectedVolumes);
nSlices = numel(selectedSlices);

% slider view
if useSlider
    
   % slider4d(dataPlot, @(varargin) ...
   %      plot_abs_image(varargin{:}, colorMap), ...
   %     nSlices);
   
    
    slider4d(dataPlot, @(Y,iDynSli, fh, yMin, yMax) ...
         plot_abs_image(Y,iDynSli, fh, yMin, yMax, colorMap, colorBar), ...
        nSlices);
   
    % to also plot phase:
    %    slider4d(dataPlot, @plot_image_diagnostics, ...
    %        nSlices);
else
    
    switch lower(fixedWithinFigure);
        case {'volume', 'volumes'}
            
            for iVol = 1:nVolumes
                stringTitle = sprintf('%s - volume %d', this.name, ...
                    selectedVolumes(iVol));
                fh = figure('Name', stringTitle, 'WindowStyle', 'docked');
                montage(permute(dataPlot(:,:,:,iVol), [1, 2, 4, 3]), ...
                    'DisplayRange', displayRange);
                title(str2label(stringTitle));
            end
            
        case {'slice', 'slices'}
            
            for iSlice = 1:nSlices
                stringTitle = sprintf('%s - slice %d', this.name, ...
                    selectedSlices(iSlice));
                fh = figure('Name', stringTitle, 'WindowStyle', 'docked');
                montage(dataPlot(:,:,iSlice,:), ...
                    'DisplayRange', displayRange);
                title(str2label(stringTitle));
            end
            
    end
    
    colormap(colorMap);
    
    if doPlotColorBar
        colorbar;
    end
end