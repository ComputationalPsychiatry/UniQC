function figureHandles = plot(this, varargin)
% Different plot modalities for Roi data, including time series & box plots
%
%   Y = MrRoi()
%   Y.plot('ParameterName', ParameterValue, ...);
%)
%
% This is a method of class MrRoi.
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'plotType'  type of plot that is created
%                           TODO Saskia: what exists?
%                           'timeSeries'
%                           'boxPlot'
%                           'histogram'
%                           
%               'dataGrouping'  'perSlice', 'perVolume', 'both/all' (default)
%               'statType'  cell of strings specifying what statistic to plot
%                            'mean'
%                            'sd'
%                            'snr'
%                            'mean+sd'  mean with shaded +/- standard deviation
%                             area
%                            'data'
%                            'boxplot
%               'nVoxel'      integer for statType 'data': plot how many voxels?
%               'indexVoxels' vector of voxel indices to be plot (mutually
%                             exclusive to 'nVoxel')
%
%               'fixedWithinFigure' determines what dimension is plotted in
%                                  (subplots of) 1 figure
%                             'slice(s)'    all slices in 1 figure; new figure
%                                           for each volume
%                             'volume(s)'   all volumes in 1 figurel new figure
%                                           for each slice

%
%
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
%       '
% OUT
%
% EXAMPLE
%   plot
%
%   See also MrRoi
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-18
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

%% Defines and checks input arguments
defaults.displayRange = 0.8*[this.perVolume.min, this.perVolume.max];
defaults.selectedVolumes = Inf;
defaults.selectedSlices = Inf;
defaults.useSlider = false;
defaults.dataGrouping = 'both';
defaults.statType = 'mean+sd';
defaults.fixedWithinFigure ='slice';

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


%% gather data to be plotted into a 2D cell(nStatTypes, nDataGroupings)
% e.g. for statType = {'mean', 'min', 'max'} and dataGrouping = 'both',
% the cell would be
% dataPlotArray = {
%    perSlice.mean,  perVolume.mean
%    perSlice.min,   perVolume.min
%    perSlice.max,   perVolume.max
%}

switch dataGrouping
    case {'perSlice','perVolume'}
        nameDataGroupingArray = cellstr(plotMode);
    case {'both', 'all'}
        nameDataGroupingArray = {'perSlice';'perVolume'};
end
nDataGroupings = numel(nameDataGroupingArray);

statTypeArray = cellstr(statType);
nStatTypes = numel(statTypes);

dataPlotArray = cell(nStatTypes, nDataGroupings);

for iDataGrouping = 1:nDataGroupings
    currentDataGrouping = nameDataGroupingArray{iDataGrouping};
    for iStatType = 1:nStatTypes
        currentStatType = statTypeArray{iStatType};
        
        switch currentStatType
            case 'mean+sd'
                % order mean and sd together for later plotting
                dataPlotArray{iStatType, iDataGrouping}(:,:,1) = ...
                    this.(currentDataGrouping).mean;
                dataPlotArray{iStatType, iDataGrouping}(:,:,2) = ...
                    this.(currentDataGrouping).sd;
                
            otherwise
                dataPlotArray{iStatType, iDataGrouping} = ...
                    this.(currentDataGrouping).(currentStatType);
        end
    end
end

% all stats in one plot, only switch figures via selected slices or volumes

%% different plot cases
for iStatType = 1:nStatTypes
    currentStatType = statTypeArray{iStatType};
    
    stringTitle = sprintf('Roi plot (%s) for %s', currentStatType, this.name);
    
    figureHandles = figure('Name', stringTitle);
    switch lower(currentStatType)
        case 'mean+sd'
            %         harea = area(t,[y-SD,pe,pe],-10);
            %         set(get(harea(1),'Children'),'EdgeColor','None','FaceColor','none');
            %         set(get(harea(2),'Children'),'FaceColor',rgb{3});
            %         set(get(harea(3),'Children'),'FaceColor',rgb{3});
            %
            %         h(2) = plot(t,y);
            %         set(h(2),'LineWidth', lw, 'Color', rgb{2}, 'LineStyle', '-');
            %
        case 'boxplot'
        otherwise % mean sd etc
    end
    
end

end