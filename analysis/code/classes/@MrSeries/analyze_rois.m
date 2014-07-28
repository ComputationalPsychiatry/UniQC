function this = analyze_rois(this)
% Extracts specified rois (masks) from specified images, and computes statistics
%
%   Y = MrSeries()
%   Y.analyze_rois(inputs)
%
% This is a method of class MrSeries.
%
% IN
%       .parameters.analyze_rois.
%           nameInputImages         Cell of strings or string with image name
%                                   (or search pattern)
%                                   on which Roi-statistics shall be
%                                   computed
%           nameInputMasks          Cell of strings or string with mask names
%                                   (or search pattern)
%                                   holding all defined rois for analysis
%
% OUT
%
% EXAMPLE
%   analyze_rois
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-28
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

% allow cell of strings entries and pre-/suffix them with placeholders
dummyImageRightPath = MrImage();
this.init_processing_step('analyze_rois', dummyImageRightPath);

keepCreatedRois = this.parameters.analyze_rois.keepCreatedRois;
nameInputImages = cellfun(@(x) ['^' x '*'], ...
    cellstr(this.parameters.analyze_rois.nameInputImages), ...
    'UniformOutput', false);
nameInputMasks = cellfun(@(x) ['^' x '*'], ...
    cellstr(this.parameters.analyze_rois.nameInputMasks), ...
    'UniformOutput', false);

inputImages = this.find('MrImage', 'name', ...
    nameInputImages);% find input images...
inputMasks = this.find('MrImage', 'name', ...
    nameInputMasks);% find input images...

nImages = numel(inputImages);
for iImage = 1:nImages
    inputImages{iImage}.extract_rois(inputMasks, keepCreatedRois);
    inputImages{iImage}.compute_roi_stats();
end

this.finish_processing_step('analyze_rois', dummyImageRightPath);