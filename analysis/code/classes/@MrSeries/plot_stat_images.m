function this = plot_stat_images(this, varargin)
% plots statistical images (mean/snr/sd/diffLastFirst) in comprehensive
% plot for several slices
%
%   Y = MrSeries()
%   Y.plot_stat_images('ParameterName', ParameterValue)
%
% This is a method of class MrSeries.
%
% IN
%   'ParameterName'
%   'selectedSlices     [1, nSlices]  vector of slice indices to be
%                                     plotted. typically 3 (low, middle,
%                                     high)
% OUT
%
% EXAMPLE
%   plot_stat_images
%
%   See also MrSeries
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
defaults.selectedSlices = round(...
    linspace(3,this.data.parameters.geometry.nVoxel(3) - 2 , 3));
defaults.statImageArray = {'mean', 'sd', 'snr', 'diffLastFirst'};
args = propval(varargin, defaults);
strip_fields(args);

nImages = numel(statImageArray);
nSlices = numel(selectedSlices);

stringTitle = sprintf('%s - stat_images', this.name);
fh = figure('Name', stringTitle);
set(fh, 'WindowStyle', 'docked');

maxSnr = max(this.snr.data(:));
maxS = max(this.mean.data(:));

% colorbar axes with reasonable scaling
cax = ...
    [
    0 maxS
    0 round(maxS/maxSnr)*3
    0 maxSnr
    round(.02*maxS*[-1 1])
    ];

for row = 1:nSlices
    slice = selectedSlices(row);
    for col = 1:nImages
        img = statImageArray{col};
        hs(row, col) = subplot(nSlices, nImages, nImages*(row-1) + col);
        imagesc(this.(img).data(:,:,slice));
        axis square; axis off;
        caxis(cax(col,:));
        title(sprintf('%s - slice %d', img, slice));
        colorbar
    end
end
suptitle(str2label(stringTitle));
