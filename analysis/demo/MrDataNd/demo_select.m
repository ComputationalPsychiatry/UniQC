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
testImage.plot4D('selectedVolumes', 1:2);

% showing 4th dim ('volumes'), but is actually coil-dimension here
% TODO: problem if t-dimension exists, but not as 4th for conversion to
% geometry...
% TODO: update plot labels accordingly!
testImage.plot4D('fixedWithinFigure', 'slices', 'selectedVolumes', Inf, ...
    'selectedSlices', 1:2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Select part of slices with array indices and some time-points,
%     a few coils and one echo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testImageSelection = testImage.select('x', [1:20], 'coil', [2:3], 'echo', 2, ...
    't', [30:40], 'z', [5:8]);
testImageSelection.name = 'Image subset: some x, slices, coils, timepoints';

% same plots as before, but should look different no
testImageSelection.plot4D('selectedVolumes', 1:2);

testImageSelection.plot4D('fixedWithinFigure', 'slices', 'selectedVolumes', Inf, ...
    'selectedSlices', 1:2);

% as before, but allow dummy dimensions to be entered and returned as 3rd
% output argument
[testImageSelection, selectionIndexArray, unusedVarargin] = ...
   testImage.select('x', [1:20], 'coil', [2:3], 'echo', 2, ...
    't', [30:40], 'z', [5:8], ...
    'fixedWithinFigure', 'slice');

% display what was not used...
unusedVarargin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Load 5D deformation field with empty 4th dimension (as in SPM's y_ files)
%   Note: This is functionality superceding SPMs inbuilt 4D handling of
%   files, even though it uses SPM functions under the hood
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples    = get_path('examples');
pathSelectImage       = fullfile(pathExamples, ...
    'nifti', '5D');

fileDeformationField = fullfile(pathSelectImage, ...
    'y_5d_deformation_field.nii');
   
Y = MrImage(fileDeformationField);

% This should have a still wrong dimInfo...4/5th dimensions t and coil !
Y.dimInfo

%% Now load with right dimInfo instead
Y2 = MrImage(fileDeformationField);

% TODO: if directly in constructor, does not work...since does not know
% what to update first...geometry or dimLabels...
Y2.update_geometry_dim_info('dimLabels', {'x','y','z', 't', 'dr'}, ...
    'units', {'mm','mm','mm','t','mm'}, 'dependent', 'geometry');

Y2.dimInfo

%% Now load directly from constructor...

dimInfo = MrDimInfo('dimLabels', {'x','y','z', 't', 'dr'}, ...
    'units', {'mm','mm','mm','t','mm'});

%% a) take dimLabels/units from input, resolution/FOV/nVoxels from loaded
% nii-geometry
% Y3 = MrImage(fileDeformationField, 'dimLabels', {'x','y','z', 't', 'dr'}, ...
%     'units', {'mm','mm','mm','t','mm'});
% 
% Y3.dimInfo


%% b) take dimLabels/units from input dimInfo, 
%   resolution/FOV/nVoxels from loaded nii-geometry

Y4 = MrImage(fileDeformationField, 'dimInfo', dimInfo);
Y4.dimInfo


%% c) overwrite resolution from dimInfo, since explicitly given!
Y5 = MrImage(fileDeformationField, 'dimLabels', {'x','y','z', 't', 'dr'}, ...
    'units', {'mm','mm','mm','t','mm'}, 'resolutions', [4 4 4 1 4]);

