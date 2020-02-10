% Script example2_FBIRN_QC_FriedmanGlover
% This script reproduces the quality control figures from 
% Friedman and Glover 2006, JMRI 23:827-839
% for a time series dataset employing the FBIRN Agar gel phantom described
% in the paper, on a 3T Philips Achieva system with 32-channel receive coil
%
% USAGE
%  example2_FBIRN_QC_FriedmanGlover
%
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2020-02-04
% Copyright (C) 2020 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Summary
% We go through the original Friedman and Glover 2006 paper section by
% section and try to adhere to their nomenclature when creating the summary
% measures and statistical images. 
% Their approaches, relies on acquiring an fMRI time series from a specific
% phantom (agar-gel filled sphere, FBIRN phantom) to answer the following
% QC questions
% 1. Are image quality levels established in the pilot stage maintained 
%    throughout the whole study?
% 2. Is the fMRI Acquisition temporally stable?
% 3. Is scanner performance stable over time intervals of days to years? 
% 4. Are image processing steps on scanner (e.g. smoothing) comparable between sites?
%
% The answer to these questions are
% A) Summary images, e.g., mean, SFNR, subject to visual inspection
% B) Single number statistics, based on ROI analyses, that form the basis
%    of comparisons over time (subjects) and sites
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectId = 'COMPI_9999';
bidsId = 'sub-01';
fs = filesep; 

paths.project =  'C:\Users\kasperla\Documents\Temp\TNU_COMPI';

paths.data.root = fullfile(paths.project, 'data');
paths.data.subject = fullfile(paths.data.root, subjectId);
paths.data.raw = fullfile(paths.data.subject, 'scandata'); % Philips PAR/REC
paths.data.runs = {
    'tn_17062019_1226495_3_1_fmri2x2_tsnrV4' % MB 1, TR 2.5 s
    'tn_17062019_1237076_4_1_wip_fmri2x2_tsnrV4' % MB 2, TR 1.5 s
    'tn_17062019_1256466_6_1_wip_fmri2x2_tsnr_mb3V4' % MB 3, TR 0.975 s
    }
paths.data.runs = strcat(paths.data.raw, fs, paths.data.runs, '.rec');

paths.bids.root = fullfile(paths.project, 'bids');
paths.bids.subject = fullfile(paths.bids.root, bidsId);
paths.bids.func = fullfile(paths.bids.subject, 'func'); % nifti

for iRun = 1:3
    paths.bids.runs{iRun} = fullfile(paths.bids.func, ...
        sprintf('%s_task-rest_run-%02d_bold.nii', bidsId, iRun));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Philips Data and Convert to BIDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load BIDS Data for selected run
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iRun = 1; % also equivalent to multiband (MB) factor
Y = MrImage(paths.data.runs{iRun});
[~, Y.name] = fileparts(paths.bids.runs{iRun});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create ROI mask for single-value Comparisons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nVoxelsRoi = 21; % as in paper, width of square, radius of sphere
% roiShape: 'square', 'disk', 'sphere'; 'cube' any structure element (See also strel is possible)
roiShape = 'cube';
dimInfoMask = Y.dimInfo.select('t',1);

% create a simple binary mask with single non-zero voxel in volume center
maskSeedData = zeros(dimInfoMask.nSamples);
%maskSeedData(56,56,16) = 1;

% set intensity of center voxel 
% TODO: Can we make this more elegant?
idxCenter = dimInfoMask.sample2index(dimInfoMask.center); 
% BUG: what's wrong with dims of Y.dimInfo.get_origin???
%  15.500000000000004  55.500000000000000  55.500000000000000  0
maskSeedData(idxCenter(1), idxCenter(2), idxCenter(3)) = 1; % does this need sub2ind?

M = MrImage(maskSeedData, 'dimInfo', dimInfoMask, ...
    'affineTransformation', Y.affineTransformation);


% dilate to shape; '2D' for one slice only; '3D' to extend to neighbouring
% slices
M = M.imdilate(strel(roiShape, nVoxelsRoi), '3D');

% check mask visually
M.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute Signal Image (mean), temporal fluctuation noise image (std) and 
%  signal-to-fluctuation-noise ratio (SFNR)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% example for shared plot parameters;
% here, first and last slice are excluded from plotting
sharedPlotParameters = {'z' [1, Y.dimInfo.z.nSamples], 'invert', true};

 % ('t') is for clarity, Y.mean would default to last non-singleton dimension
meanY = Y.mean('t');
meanY.name = 'Signal Image';

% TODO: Y.detrend('order',2);
sdY = Y.std('t');
sdY.name = 'Temporal Fluctuation Noise';

sfnrY = Y.snr('t');
sfnrY.name = 'SFNR';

statImages = {meanY, sdY, sfnrY};

for iImage = 1:numel(statImages)
    statImages{iImage}.plot(sharedPlotParameters{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Evaluate ROI for SFNR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sfnrY = sfnrY.extract_rois(M)

% plot ROI overlay
sfnrY.plot_overlays(M, 'overlayMode', 'edge')


% QC measures on phantom, sequence 200 volumes, FBIRN phantom, TR/TE 2000/30 ms
% QC measures for Q1:
% Mean, SD (2nd order detrended), SFNR image
% Static Spatial Noise Image: DIFF=sumOdd-sumEven
% FT of (see Q2) of detrended mean_roi time series; threshold for each freq: p-value on significant spikes
% For Q2:
% Summary SFNR: average in center roi (21x21 box)
% Summary SNR: mean_ROI(meanImage)/(std_ROI(DIFF)/nScans)
% Percent Fluctuation and Drift: timeseries of mean_roi, 2nd order detrend, then fluct% = sd/mean_trend*100, drift%=(max_trend-min_trend)*mean_trend*100
% RF Gain (Tx/Rx), f0
% For Q3:
% Spatial Smoothness (Weisskoff): ROI analysis of time series of mean_nVoxels y_nVoxels(t); for uncorrelated voxels, coefficient of variation (CV(nVoxels)=sd_t(y_nVoxels)/mean_t) scales inversely with ROI length (sqrt(nVoxels)), and radius of decorrelation (RDC) = CV(1)/CV(nMax); in log-log plot, RDC = intercept of CV(nMax) with theoretical linear relationship
