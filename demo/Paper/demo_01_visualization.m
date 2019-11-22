% Script demo_01_visualization
% This demo shows typical visualization/data selection tasks in image QC
% 
%  demo_01_visualization
% 
% Targets:
%   - flexible
%   - versatile
%   - accessible
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-01-22
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load required multi-echo file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rootExample = get_path('example');
folderExample = 'nifti/data_multi_echo2';
pathExample = fullfile(rootExample, folderExample);

X = MrImage(pathExample);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Show versatile selection
% 2) Show N-dimensional data handling

%% 0. Clean up
close all; 

%% 1. overview plot (shows first 3D volume)
X.plot

%% 2. Zoom plot: specific slices, with selected time points and echo (5D!)
X.plot('z', 10:18, 't', 1)

%% 3. Change orientation
X.plot('sliceDimension', 'x', 'x', 31:39, 'echo', 1)

%% 4. Higher dim visualization: arbitrary tile (montage) dimension
X.plot('z', 23, 'echo', 3, 'sliceDimension', 't')

%% 5. Interactive Plot: dimension sliders
X.plot('useSlider', true)

%% 6. Interactive Plot: voxel time series
X.select('z',18).plot('linkOptions', 'timeseries_4')
