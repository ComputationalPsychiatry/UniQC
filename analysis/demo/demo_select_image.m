% Script demo_select_image
% Example usage of how to use MrImage.select() for high-dim image arrays
%
%  demo_select_image
%
%
%   See also MrImage.select MrDimInfo
%
% Author:   Lars Kasper
% Created:  2016-01-28
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
%
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Provide high-dimensional test image with corresponding dim-Info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Imprint 3rd to nth dimension index as pixels on image
nSamples = [64 64 10 50 4 3];
imageMatrix = 0.1*rand(nSamples);
imageMatrix = create_image_with_index_imprint(imageMatrix);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Create Image object from matrix and corresponding dim-Info
%   dimInfo makes it a 6D volumar-, multi-coil-, time-series- multi-echo- dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dimInfo = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil', 'echo'}, ...
    'units', {'mm', 'mm', 'mm', 's', '', 'ms'}, ...
    'resolutions', [3 3 3 2.5 1 25], ...
    'firstSamplingPoint', [-110 -110 -60, 0, 1, 15]);

testImage = MrImage(imageMatrix, 'dimInfo', dimInfo);
testImage.name = '6D dataset: volumar-, time-series-,  multi-coil- multi-echo';

% should show first coil (=time point) and z-dim (=slices here) as montage
testImage.plot('selectedVolumes', 1:2);

% showing 4th dim ('volumes'), but is actually  coil-dimension here
% TODO: problem if t-dimension exists, but not as 4th for conversion to
% geometry...
% TODO: update plot labels accordingly!
testImage.plot('fixedWithinFigure', 'slices', 'selectedVolumes', Inf, ...
    'selectedSlices', 1:2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Select part of slices with array indices and some time-points,
%     a few coils and one echo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testImageSelection = testImage.selectND('x', [1:20], 'coil', [2:3], 'echo', 2, ...
    't', [30:40], 'z', [5:8]);
testImageSelection.name = 'Image subset: some x, slices, coils, timepoints';

% same plots as before, but should look different no
testImageSelection.plot('selectedVolumes', 1:2);

testImageSelection.plot('fixedWithinFigure', 'slices', 'selectedVolumes', Inf, ...
    'selectedSlices', 1:2);

% as before, but allow dummy dimensions to be entered and returned as 3rd
% output argument
[testImageSelection, selectionIndexArray, unusedVarargin] = ...
   testImage.selectND('x', [1:20], 'coil', [2:3], 'echo', 2, ...
    't', [30:40], 'z', [5:8], ...
    'fixedWithinFigure', 'slice');

% display what was not used...
unusedVarargin