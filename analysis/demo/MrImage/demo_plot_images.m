% Script demo_plot_images
% Exemplifies plot capabilities for the Toolbox (montage/slider/overlay/3D/
% spmi)
%
%  demo_plot_images
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-02-12
% Copyright (C) 2015 Institute for Biomedical Engineering
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
%% 0. Load example data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples    = get_path('examples');
fileTest        = fullfile(pathExamples, 'nifti', 'rest', 'meanfmri.nii');
X               = MrImage(fileTest);

niftiFile4D     = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');
D               = MrImage(niftiFile4D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Plot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D data set
X.plot();
X.plot('rotate90', -1);
X.plot('rotate90', -1, 'colorBar', 'on');
X.plot('rotate90', -1, 'colorBar', 'on', 'displayRange', [0 1200]);
X.plot('rotate90', -1, 'colorBar', 'on', 'displayRange', [0 1200], ...
    'colorMap', 'hot');
X.plot('rotate90', -1, 'colorBar', 'on', 'displayRange', [0 11], ...
    'colorMap', 'hot', 'plotMode', 'log');
% select
X.plot('z', 15, 'x', 63, 'y', 23)

% 4D data set
disp(D.geometry);
% plot automatically chooses to only plot the first volume if no other
% parameters are given, to prevent accidentially opening a large number of
% images
D.plot();
% now plot only the 13th slice with all 15 time points in one montage
D.plot('z', 13, 'sliceDimension', 't')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Plot Overlay of Image and Edges (opaque)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edgeX           = edge(X);
edgeX.plot();

X.plot('overlayImages', edgeX);
% compute edges on the fly
X.plot('overlayImages', X, 'overlayMode', 'edge', 'edgeThreshold', 100);
% compute mask and overlay
maskX = X.compute_mask('threshold', 900);
maskX.plot();
X.plot('overlayImages', maskX, 'overlayMode', 'mask', 'overlayAlpha', 0.5)

% try 4D image
% D.plot('overlayImages', edgeX, 't', 1:15);

% try 2D image
D.plot('overlayImages', edgeX, 't', 1, 'z', 10);

% try other imgage
% array = rand([10, 10, 5]);
% P = MrImage(array);
% X.plot('overlayImages', P);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Plot 3D using view3d capabilities and extract_plot_data options to
%     rotate image dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot first volume in 3d mode
X.plot('plotType', '3d');

% plot slice 15 over time
D.plot('z', 15, 'plotType', '3d')

% plot only one slice
% D.plot('z', 15, 't', 1, 'plotType', '3d')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Plot 3D spmi using view3d capabilities
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use spm_display to show single volume
X.plot('plotType', 'spmi');
% plot all 15 volumes
D.plot('plotType', 'spmi', 't', 1:15);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Use Slider
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D.plot('useSlider', true);
D.plot('useSlider', true, 't', 1:15);
% D.plot('useSlider', true, 't', 1, 'x', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6. Save Data as AVI movie file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.cine();
