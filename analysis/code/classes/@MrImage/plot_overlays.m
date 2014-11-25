function this = plot_overlays(this, overlayImages, varargin)
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
%               'mode'              'edge', 'mask', 'map'
%                                   'edge'  only edges of overlay are
%                                           displayed
%                                   'mask'  every non-zero voxel is
%                                           displayed (different colors for
%                                           different integer values, i.e.
%                                           clusters'
%                                   'map'   thresholded map in one colormap
%                                           is displayed (e.g. spmF/T-maps)
%                                           thresholds from
%                                           threshold
%               'threshold'     [minimumThreshold, maximumThreshold]
%                                   tresholds for overlayMode 'map'
%                                   default: [-Inf, Inf] = [minValue, maxValue]
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
%
% EXAMPLE
%   plot_overlays
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

defaults.plotMode               = 'linear';
defaults.selectedVolumes        = 1;
defaults.selectedSlices         = Inf;
defaults.sliceDimension         = 3;
defaults.rotate90               = 0;
defaults.mode                   = 'mask';
defaults.threshold              = [-Inf, Inf];

args = propval(varargin, defaults);
strip_fields(args);



% Assemble parameters for data extraction into one structure
argsExtract = struct('sliceDimension', sliceDimension, ...
        'selectedSlices', selectedSlices, 'selectedVolumes', selectedVolumes, ...
        'plotMode', plotMode, 'rotate90', rotate90);


dataPlot = this.extract_plot_data(argsExtract);

if ~iscell(overlayImages)
    overlayImages = {overlayImages};
end

nOverlays = numel(overlayImages);

dataOverlays = cell(nOverlays,1);



%% Resize overlay images and extract data from all of them
for iOverlay = 1:nOverlays
    overlay = overlayImages{iOverlay};
    resizedOverlay = overlay.copyobj.resize(this.geometry);
    
    %% for map: threshold image only, 
    %  for mask: binarize
    %  for edge: binarize, then compute edge
    
    switch mode
        case 'map'
            resizedOverlay.apply_threshold(threshold);
        case 'mask'
             resizedOverlay.apply_threshold(0, 'exclude');
        case 'edge'
             resizedOverlay.apply_threshold(0, 'exclude');
             resizedOverlay.perform_unary_operation(@edge);
    end
    dataOverlays{iOverlay} = resizedOverlay.extract_plot_data(argsExtract);
end


%% 
