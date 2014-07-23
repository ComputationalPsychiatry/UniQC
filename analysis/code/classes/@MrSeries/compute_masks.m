function this = compute_masks(this)
% segments defined input image into tissue types & thresholds to get masks
% - input image can be anatomical or mean functional
%
%   Y = MrSeries()
%   Y.compute_masks(inputs)
%
% This is a method of class MrSeries.
%
% IN
%
% OUT
%
% EXAMPLE
%   compute_masks
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-14
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

%% init parameters for masking and file names
nameInputImages = this.parameters.compute_masks.nameInputImages;
threshold = this.parameters.compute_masks.nameInputImages.threshold;
keepExistingMasks = this.parameters.compute_masks.nameInputImages.keepExistingMasks;
nameTargetGeometry = this.parameters.compute_masks.nameTargetGeometry;

handleInputImages = this.find('MrImage', 'name', ...
    [nameInputImages '*']);% find input image...
handleTargetImage = this.find('MrImage', 'name', ...
    [nameTargetGeometry '*']);

nImages = numel(handleInputImages);

inputImages = cell(nImages, 1);
for iImage = 1:nImages
    inputImages{iImage} = ...
        handleInputImages{iImage}.copyobj;
end

targetGeometry = handleTargetImage.geometry.copyobj;

% clear masks, if not wanted to be kept
if ~keepExistingMasks
    this.masks = {}; % TODO: maybe a proper clear?
end

this.init_processing_step('compute_masks', inputImages);

% replicate threshold for all images, if only 1 number given
if numel(threshold) == 1
    threshold = repmat(nImages,1);
end

% compute masks and link them to MrSeries.masks
for iImage = 1:nImages
    inputImages{iImage}.compute_mask('threshold', threshold(iImage), ...
    'targetGeometry', targetGeometry, ...
    'caseEqual', 'include');
    this.masks{end+1,1} = inputImages{iImage};
end

%% finish processing by deleting obsolete files, depending on save-parameters

this.finish_processing_step('compute_masks', inputImages);