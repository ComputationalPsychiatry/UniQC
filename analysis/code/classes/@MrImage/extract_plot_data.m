function [dataPlot, displayRange] = extract_plot_data(this, varargin)
% Extracts (and manipulates) data for plotting with arguments from MrImage.plot
%
%   Y = MrImage()
%   Y.extract_plot_data('ParameterName', 'ParameterValue' ...)
%
% This is a method of class MrImage.
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%
%               'signalPart'        for complex data, defines which signal 
%                                   part shall be extracted for plotting
%                                       'abs'       - absolute value
%                                       'phase'     - phase of signal
%                                       'real'      - real part of signal
%                                                     (default)
%                                       'imag'      - imaginary part of
%                                                     signal
%               'plotMode',         transformation of data before plotting
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
% OUT
%   dataPlot    data matrix 
%               [nVoxelX, nVoxelY, nSelectedSlices, nSelectedVolumes],
%               permuted via slice dimension
%   displayRange
%               suggested display range [min(dataPlot), 0.8*max(dataPlot)]
%           
% EXAMPLE
%   Y.extract_plot_data('selectedVolumes', 1, 'selectedSlices', 3:5, ...
%                       'sliceDimension', 2);
%
%   See also MrImage MrImage.plot
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
defaults.signalPart         = 'real';
defaults.selectedVolumes    = 1;
defaults.selectedSlices     = Inf;
defaults.sliceDimension     = 3;
defaults.plotMode           = 'linear';
defaults.rotate90           = 0;

args = propval(varargin, defaults);
strip_fields(args);

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

switch signalPart
    case 'abs'
        dataPlot = abs(dataPlot);
    case {'angle', 'phase'}
        dataPlot = angle(dataPlot) + pi;
    case 'real'
        dataPlot = real(dataPlot);
    case 'imag'
        dataPlot = imag(dataPlot);
end

switch plotMode
    case 'linear' %nothing happens'
    case 'log'
        dataPlot = log(abs(dataPlot));
end

displayRange = [min(dataPlot(:)), 0.8*max(dataPlot(:))];

if rotate90
   tempImage = MrImage(dataPlot);
   tempImage.rot90(rotate90);
   dataPlot = tempImage.data;
end
