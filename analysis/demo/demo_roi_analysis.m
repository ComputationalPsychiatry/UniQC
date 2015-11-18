% Script demo_roi_analysis
% Shows simple roi creation and analysis via MrImage-methods
%
%  demo_roi_analysis
%
%
%   See also demo_fmri_qa and demo_snr_analysis_mr_series 
%   for more detailed examples using SPM/time series functionality of
%   toolbox
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-11-18
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
 
doPlot = true;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
pathExamples        = get_path('examples');
pathData            = fullfile(pathExamples, 'resting_state_ingenia_3T');

fileImage           = fullfile(pathData, 'funct_short.nii');

X = MrImage(fileImage);


% Visualize data
if doPlot
    X.plot();
    X.plot3d();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create print, and plot some statistics of image
%  default: application along last non-zero image dim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meanX = mean(X);
stdX = std(X);
snrX = snr(X);

if doPlot
    meanX.plot();
    stdX.plot();
    snrX.plot();
end

fprintf('Min Val of Time series \t\t\t %f \n', min(X));
fprintf('Max Val of Time series \t\t\t %f \n', max(X));
fprintf('Max Val of Time series (slice 5-10) \t %f \n', ...
    max(X.select('selectedSlices', 5:10)));
fprintf('Percentile (75) of Time series \t \t %f \n', ...
    prctile(X,75));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create mask from image via threshold from statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maskX = X.copyobj.compute_mask('threshold', prctile(X,90));

if doPlot
    maskX.plot();
    X.plot_overlays(maskX);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract ROI and compute stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4D example
X.extract_rois(maskX); % fills X.data{iSlice}
% TODO plotting does not work w/o statistics
X.compute_roi_stats(); % mean/sd/snr of all slices and whole volume

% 3D example
meanX.extract_rois(maskX);
meanX.compute_roi_stats();

fprintf('\nROI stats per Volume \n');

nVolumes = X.geometry.nVoxels(4);
fprintf('volume \t mean \t min \t max\n')

for iVol = 1:nVolumes
    fprintf('%02d %6.1f \t %6.1f \t %6.1f \n', iVol, ...
        X.rois{1}.perVolume.mean(iVol), ...
        X.rois{1}.perVolume.min(iVol), X.rois{1}.perVolume.max(iVol))
end


if doPlot
   % See also MrRoi.plot for all options
   X.rois{1}.plot('plotType', 'timeSeries');  % default for 4D
   meanX.rois{1}.plot('plotType', 'histogram', 'selectedSlices', 5:10); % default for 3D
end