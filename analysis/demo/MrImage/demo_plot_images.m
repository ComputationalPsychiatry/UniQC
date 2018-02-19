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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Create Example overlay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edgeX           = edge(X);
edgeX.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Plot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.plot();
X.plot('useSlider', true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Plot Overlay of Image and Edges (opaque)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.plot('overlayImages', edgeX);
% compute edges on the fly 
X.plot('overlayImages', X, 'overlayMode', 'edge', 'edgeThreshold', 100);
% compute mask and overlay
maskX = X.compute_mask('threshold', 900);
maskX.plot();
X.plot('overlayImages', maskX, 'overlayMode', 'mask', 'overlayAlpha', 0.5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Save Data as AVI movie file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.cine();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Plot 3D using view3d capabilities and extract_plot_data options to
%     rotate image dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.plot('plotType', '3d');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6. Plot 3D spmi using view3d capabilities and extract_plot_data options to
%     rotate image dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

X.plot('plotType', 'spmi')

%%
% to only include 51 slices in the plot,
% to swap the slice (3rd) dimension with the first and
% rotate the slices (dim1/2) by 180 deg, and the plot in one go.
X.plot('plotType', '3d', 'selectedSlices', 15:100, 'rotate90', 2, 'sliceDimension', 2)