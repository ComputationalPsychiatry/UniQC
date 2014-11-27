function [fh, dataPlot] = plot_overlays(this, overlayImages, varargin)
% Plots this image with other images overlayed
%
%   Y = MrImage()
%   Y.plot_overlays(inputs)
%
% This is a method of class MrImage.
%
% IN
%   overlayImages               MrImage or cell of MrImages that shall be
%                               overlayed
%
%               'overlayAlpha'  transparency value of overlays 
%                               (0 = transparent; 1 = opaque; default: 0.1)
%               'overlayMode'  'edge', 'mask', 'map'
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
%                                   default: [] = [minValue, maxValue]
%                                   everything below minValue will not be
%                                   displayed;
%                                   everything above maxValue
%                                   will have brightest color
%               'plotMode'          transformation of data before plotting
%                                   'linear' (default), 'log'
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
%
% OUT
%   fh          figure handle;
% EXAMPLE
%   X = MrImage('struct.nii');
%   Z = MrImage('spmF_0001.nii');
%   X.plot_overlays(Z, 'overlayMode', 'map', 'overlayThreshold', ...
%               [4.5, 100], 'selectedSlices', [40:45])
%
%   See also MrImage
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-24
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

defaults.overlayAlpha           = 0.1; 
defaults.colorMap               = 'hot';
defaults.plotMode               = 'linear';
defaults.selectedVolumes        = 1;
defaults.selectedSlices         = Inf;
defaults.sliceDimension         = 3;
defaults.rotate90               = 0;
defaults.overlayMode            = 'mask';
defaults.overlayThreshold       = [];
defaults.colorBar               = 'on';

args = propval(varargin, defaults);
strip_fields(args);


doPlotColorBar = strcmpi(colorBar, 'on');

if ~iscell(overlayImages)
    overlayImages = {overlayImages};
end


% Assemble parameters for data extraction into one structure
argsExtract     = struct('sliceDimension', sliceDimension, ...
        'selectedSlices', selectedSlices, 'selectedVolumes', selectedVolumes, ...
        'plotMode', plotMode, 'rotate90', rotate90);

nColorsPerMap   = 256;

dataPlot        = this.extract_plot_data(argsExtract);


%% Resize overlay images and extract data from all of them

nOverlays       = numel(overlayImages);
dataOverlays    = cell(nOverlays,1);


for iOverlay = 1:nOverlays
    overlay = overlayImages{iOverlay};
    resizedOverlay = overlay.copyobj.resize(this.geometry);
    
    %% for map: overlayThreshold image only, 
    %  for mask: binarize
    %  for edge: binarize, then compute edge
    
    switch overlayMode
        case {'map', 'maps'}
            resizedOverlay.apply_threshold(overlayThreshold);
        case {'mask', 'masks'}
             resizedOverlay.apply_threshold(0, 'exclude');
        case {'edge', 'edges'}
             resizedOverlay.apply_threshold(0, 'exclude');
             % for cluster mask with values 1, 2, ...nClusters, 
             % leave values of edge same as cluster values
             resizedOverlay = edge(resizedOverlay).*...
                 imdilate(resizedOverlay, strel('disk',4));
    end
    dataOverlays{iOverlay} = resizedOverlay.extract_plot_data(argsExtract);
end



%% Define color maps for different cases:
%   map: hot
%   mask/edge: one color per mask image, faded colors for different
%   clusters within same mask

functionHandleColorMaps = {
    @hot
    @cool
    @spring
    @summer
    @winter
    @jet
    @hsv
    };

overlayColorMap = cell(nOverlays,1);
switch overlayMode
    case {'mask', 'edge', 'masks', 'edges'}
        baseColors = hsv(nOverlays);
        
        % determine unique color values and make color map 
        % a shaded version of the base color
        for iOverlay = 1:nOverlays
            indColorsOverlay = unique(dataOverlays{iOverlay});
            nColorsOverlay = round(...
                max(indColorsOverlay) - min(indColorsOverlay));
            overlayColorMap{iOverlay} = get_brightened_color(...
                baseColors(iOverlay,:), 1:nColorsOverlay, ...
                nColorsOverlay, 0.7);
        end
        
    case {'map', 'maps'}
        for iOverlay = 1:nOverlays
            overlayColorMap{iOverlay} = ...
                functionHandleColorMaps{iOverlay}(nColorsPerMap);
        end
        
end



%% Assemble RGB-image for montage by adding overlays with transparency as 
% RGB in right colormap
rangeOverlays   = cell(nOverlays, 1);
rangeImage   = cell(nOverlays, 1);
for iOverlay = 1:nOverlays
    [dataPlot, rangeOverlays{iOverlay}, rangeImage{iOverlay}] = ...
        add_overlay(dataPlot, dataOverlays{iOverlay}, ...
    overlayColorMap{iOverlay}, ...
    overlayThreshold, ...
    overlayAlpha);
end



%% Plot as montage
% TODO: implement this via MrImage.plot as well!

stringTitle = sprintf('Overlay Montage - %s', this.name);
fh = figure('Name', stringTitle);
montage(dataPlot);
title(str2label(stringTitle));



%% Add colorbars as separate axes

if doPlotColorBar
    positionMontage = get(gca, 'Position');
    dxColorBar = 0.01;
    startColorBar = positionMontage(1)+positionMontage(3);
    
    positionAxes = [startColorBar, positionMontage(2), ...
        dxColorBar, positionMontage(4)];
    
    % add colorbar for image
    imageColorMap = gray(nColorsPerMap);
    hax = axes('Position', positionAxes);
    imagesc(permute(imageColorMap, [1 3 2]));
    axis xy;
    set(hax, 'YTick', [0; nColorsPerMap]);
    set(hax, 'YTickLabel', ...
        {sprintf('%d', rangeImage{1}(1)); ...
       sprintf('%d', rangeImage{1}(2))});
    set(hax, 'XTick', [])
    
    % add colorbars for overlays
    for iOverlay = 1:nOverlays
        positionAxes(1) = positionAxes(1) + dxColorBar*4;
        hax = axes('Position', positionAxes);
        imagesc(permute(overlayColorMap{iOverlay}, [1 3 2]));
        axis xy;
        set(hax, 'YTick', [0; size(overlayColorMap{iOverlay},1)]);
        set(hax, 'YTickLabel', ...
            { sprintf('%d', rangeOverlays{iOverlay}(1)); ...
           sprintf('%d', rangeOverlays{iOverlay}(2))});
        set(hax, 'XTick', [])
        ylabel(overlayImages{iOverlay}.name);
    end
    
end

