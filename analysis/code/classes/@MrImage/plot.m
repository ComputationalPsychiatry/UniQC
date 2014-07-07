function fh = plot(this, varargin)
%plots an MR image per slice
%
%   Y  = MrImage
%   fh = Y.plot('ParameterName', ParameterValue)
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'displayRange' [1,2] vector for pixel value = black and
%                                               pixel value = white
%               'selectedVolumes' [1,nVols] vector of selected volumes to
%                                           be displayed
%                                 choose Inf to display all volumes
%               'useSlider'        true or false
%                               provides interactive slider for
%                               slices/volumes
%                               TODO: implement via gui4Dslider
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
defaults.useSlider = false;
args = propval(varargin, defaults);
strip_fields(args);

if isinf(selectedVolumes)
    selectedVolumes = 1:this.parameters.geometry.nVoxel(4);
end

% slider view
if useSlider
    slider4d(this.data(:,:,:,selectedVolumes), @plot_image_diagnostics, ...
        this.parameters.geometry.nVoxel(3));
else
    
    for iVol = selectedVolumes
        stringTitle = sprintf('%s - volume %d', this.name, iVol);
        fh = figure('Name', stringTitle, 'WindowStyle', 'docked');
        montage(permute(this.data(:,:,:,iVol), [1, 2, 4, 3]), ...
            'DisplayRange', displayRange);
        title(str2label(stringTitle));
    end
    
end