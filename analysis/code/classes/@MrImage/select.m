function [outputImage, selectedSlices, selectedVolumes] = ...
    select(this, varargin)
% Creates new image from selected data range, allows interactive picking of
% volumes/slices via clicking on montage
%
%   Y = MrImage()
%   Y.select(inputs)
%
% This is a method of class MrImage.
%
% IN
%
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'method'            'manual' or 'indexed' (default)
%                                   if 'manual', montage plot is presented
%                                   to select slices/volumes
%                                   if 'indexed', extraction options (s.b.)
%                                   are used
%
%               parameters for data extraction:
%
%               'signalPart'        for complex data, defines which signal
%                                   part shall be extracted for plotting
%                                       'all'       - do not change data (default)
%                                       'abs'       - absolute value
%                                       'phase'     - phase of signal
%                                       'real'      - real part of signal
%                                       'imag'      - imaginary part of
%                                                     signal
%               'plotMode',         transformation of data before plotting
%                                   'linear' (default), 'log'
%               'selectedX'         [1, nPixelX] vector of selected
%                                   pixel indices in 1st image dimension
%               'selectedY'         [1, nPixelY] vector of selected
%                                   pixel indices in 2nd image dimension
%               'selectedVolumes'   [1,nVols] vector of selected volumes to
%                                             be displayed
%               'selectedSlices'    [1,nSlices] vector of selected slices to
%                                               be displayed
%                                   choose Inf to display all volumes
%               'sliceDimension'    (default: 3) determines which dimension
%                                   shall be plotted as a slice
%               'exclude'           false (default) or true
%                                   if true, selection will be inverted, i.e.
%                                   selectedX/Y/Slices/Volumes will NOT be
%                                   extracted, but all others in dataset
%               'rotate90'          default: 0; 0,1,2,3; rotates image
%                                   by multiple of 90 degrees AFTER
%                                   flipping slice dimensions
% OUT
%
% EXAMPLE
%   select
%
%   See also MrImage MrImage.extract_plot_data
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-12-01
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
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

defaults.method = 'manual'; % what is
defaults.exclude = 'false';

[argsUsed argsExtract] = propval(varargin, defaults);

if strcmpi(method, 'manual')
    % plot and click montage
    
else
    [dataSelected, displayRange] = this.extract_plot_data(argsExtract);
end

outputImage                     = MrImage(dataSelected);
nVoxelsOriginal                 = outputImage.geometry.nVoxels;
outputImage.geometry            = this.geometry.copyobj;
outputImage.geometry.nVoxels    = nVoxelsOriginal;
outputImage.geometry.load([]); % update number of voxel-related geometry changes
