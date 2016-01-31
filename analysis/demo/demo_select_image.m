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
nSamples = [64 64 10 4 50 3];
imageMatrix = 0.1*rand(nSamples);
imageMatrix = create_image_with_index_imprint(imageMatrix);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Create Image object from matrix and corresponding dim-Info
%   dimInfo makes it a 6D volumar-, multi-coil-, time-series- multi-echo- dataset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dimInfo = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 'coil', 't', 'echo'}, ...
    'units', {'mm', 'mm', 'mm', '', 's', 'ms'}, ...
    'resolutions', [3 3 3 1 2.5 25], ...
    'firstSamplingPoint', [-110 -110 -60, 1, 0, 15]);

testImage = MrImage(imageMatrix, 'dimInfo', dimInfo);
testImage.name = '6D dataset: volumar-, multi-coil-, time-series- multi-echo';

% should show first time point and z-dim as montage
testImage.plot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Select part of slices with array indices and some time-points,
%     a few coils and one echo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testImageSelection = testImage.selectND('x', [1:20], 'coil', [2 3], 'echo', 2, ...
    't', [30:40]);
testImageSelection.name = 'Image subset: some slices, coils, timepoints';

testImageSelection.plot();



