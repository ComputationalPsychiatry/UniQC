function fh = plot(this, varargin)
%plots an MR image per slice
%
%   Y  = MrImage
%   fh = Y.plot('ParameterName', ParameterValue)
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'plotMode',         transformation of data before plotting
%                                   'linear' (default), 'log'
%               'displayRange'      [1,2] vector for pixel value = black and
%                                                    pixel value = white
%               'selectedVolumes'   [1,nVols] vector of selected volumes to
%                                             be displayed
%               'selectedSlices'    [1,nSlices] vector of selected slices to
%                                               be displayed
%                                   choose Inf to display all volumes
%               'sliceDimension'    (default: 3) determines which dimension
%                                   shall be plotted as a slice
%               'rotate90'          default: 0; 0,1,2,3; rotates image
%                                   by multiple of 90 degrees AFTER
%                                   flipping slice dimensions
%               'useSlider'         true or false
%                                   provides interactive slider for
%                                   slices/volumes;
%                                   assumes default:    selectedSlices = Inf
%                                                       selectedVolumes = Inf
%               'fixedWithinFigure' determines what dimension is plotted in
%                                   (subplots of) 1 figure
%                                   'slice(s)'    all slices in 1 figure;
%                                   new figure for each volume
%                                   'volume(s)'   all volumes in 1 figurel
%                                   new figure for each slice
%               'colorMap'          string, any matlab colormap name
%                                   e.g. 'jet', 'gray'
%               'colorBar',         'on' or 'off' (default)
%                                   where applicable, determines whether
%                                   colorbar with displayRange shall be plotted
%                                   in figure;
%               'useSpmDisplay'     true or false (default)
%                                   uses display function in SPM to
%                                   visualize 3D volume with the header
%                                   information applied (first selected
%                                   volume and all slices are displayed)
%               'overlayImages'     (cell of) MrImages that will be
%                                   overlayed
%               'overlayMode'       'edge', 'mask', 'map'
%                                   'edge'  only edges of overlay are
%                                           displayed
%                                   'mask'  every non-zero voxel is
%                                           displayed (different colors for
%                                           different integer values, i.e.
%                                           clusters'
%                                   'map'   thresholded map in one colormap 
%                                           is displayed (e.g. spmF/T-maps)
%                                           thresholds from
%                                           overlayThreshold
%               'overlayThreshold'  [minimumThreshold, maximumThreshold]
%                                   tresholds for overlayMode 'map'
%                                   default: [-Inf, Inf] = [minValue, maxValue]
%                                   everything below minValue will not be
%                                   displayed; 
%                                   everything above maxValue
%                                   will have brightest color
%
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
defaults.rotate90 = 0;
defaults.useSlider = false;
defaults.plotMode = 'linear';
defaults.fixedWithinFigure = 'volume';
defaults.colorMap = 'gray';
defaults.colorBar = 'off';
defaults.useSpmDisplay = false;
defaults.overlayImages = {};
defaults.overlayMode = 'edge';
defaults.overlayThreshold = [-Inf Inf];

args = propval(varargin, defaults);
strip_fields(args);

doPlotColorBar = strcmpi(colorBar, 'on');
doPlotOverlays = ~isempty(overlayImages);

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

dataPlot = this.extract_plot_data('sliceDimension', sliceDimension, ...
    'selectedSlices', selectedSlices, 'selectedVolumes', selectedVolumes, ...
    'plotMode', plotMode, 'rotate90', rotate90);

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
elseif useSpmDisplay
    
    % useSPMDisplay calls the spm_image.m function and plots the first
    % selected volume and all slices
    % get current filename
    fileName = fullfile(this.parameters.save.path, ...
        this.parameters.save.fileUnprocessed);
    
    % select Volume
    fileNameVolArray = get_vol_filenames(fileName);
    % display image
    spm_image('Display', fileNameVolArray{selectedVolumes});
    
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
                if doPlotColorBar
                    colorbar;
                end
                colormap(colorMap);
            end
            
        case {'slice', 'slices'}
            
            for iSlice = 1:nSlices
                stringTitle = sprintf('%s - slice %d', this.name, ...
                    selectedSlices(iSlice));
                fh = figure('Name', stringTitle, 'WindowStyle', 'docked');
                montage(dataPlot(:,:,iSlice,:), ...
                    'DisplayRange', displayRange);
                title(str2label(stringTitle));
                if doPlotColorBar
                    colorbar;
                end
                colormap(colorMap);
            end
            
    end
    
    
    
    
end