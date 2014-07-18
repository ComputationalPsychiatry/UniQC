function figureHandles = plot(this, varargin)
% plots 
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
%               'plotMode'  'perSlice', 'perVolume', 'both/all' (default)
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
%               'groupWithinFigure' determines what dimension is plotted in
%                                  (subplots of) 1 figure
%                             'slice'   all slices in 1 figure; new figure
%                                       for each volume
%                             'volume'  all volumes in 1 figurel new figure
%                                       for each slice

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

switch lower(statType)
    case 'mean+sd'
%         harea = area(t,[y-SD,pe,pe],-10);
%         set(get(harea(1),'Children'),'EdgeColor','None','FaceColor','none');
%         set(get(harea(2),'Children'),'FaceColor',rgb{3});
%         set(get(harea(3),'Children'),'FaceColor',rgb{3});
%         
%         h(2) = plot(t,y);
%         set(h(2),'LineWidth', lw, 'Color', rgb{2}, 'LineStyle', '-');
% 
end