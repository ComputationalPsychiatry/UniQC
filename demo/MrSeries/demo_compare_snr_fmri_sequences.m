% Script demo_compare_snr_fmri_sequences
% Example analysis for comparing snr between sequences
%
% Author:   Andreea Diaconescu & Lars Kasper
% Created:  2015-11-30
% Copyright (C) 2015 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository,
% which is released under the terms of the GNU General Public Licence (GPL),
% version 3. You can redistribute it and/or modify it under the terms of
% the GPL (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% #MOD# The following parameters can be altered to analyze different image
% time series
% default: funct_short (fMRI Philips 3T)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathData            = '/Users/kasperla/Dropbox/Andreiuta/TNU_DMPAD_MS_Pilot1/scandata';

fileFunctionalArray = {
    'tnu_dmpad_ms_pilot1_24112015_1121590_9_1_20asenseV42.nii'
    'tnu_dmpad_ms_pilot1_24112015_1127320_11_1_20psenseV42.nii'
    %'tnu_dmpad_ms_pilot1_24112015_1132500_13_1_20alowsensetiV42.nii'
    };

fileStructural      = fullfile(pathData, 'tnu_dmpad_ms_pilot1_24112015_113850_15_2_vt1w_3dtfe_refsV42.nii');

dirResults          = fullfile(pathData, 'results');

nSeries = numel(fileFunctionalArray);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load data into time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SArray = cell(nSeries,1);
for iSeries = 1:nSeries
    fileSeries = fileFunctionalArray{iSeries};
    
    S = MrSeries(fullfile(pathData, fileSeries));
    S.name = fileSeries;
    S.parameters.save.path = prefix_files(S.parameters.save.path, ...
        dirResults, fileSeries);
    
    S.parameters.save.items = 'processed';
    
     
    % show orientation of transverse slices
    S.data.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2)
    SArray{iSeries} = S.copyobj;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load, anatomy, Compute statistical images (mean, snr, sd, etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for iSeries = 1:nSeries
    S = SArray{iSeries};
    S.anatomy.load(fileStructural, 'updateProperties', 'none');
    
    % change orientation for easier plotting
    % S.data.reslice(S.anatomy);
    % S.data.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2)
 
    
end

%% Compute and Plot statistical images of raw data
for iSeries = 1:nSeries
   S = SArray{iSeries};
   S.compute_stat_images();
   S.plot_stat_images('selectedSlices', 10:5:S.data.geometry.nVoxels(3)-10); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realign data and plot realignment parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iSeries = 1:nSeries
   S = SArray{iSeries};
   S.realign();
   S.glm.plot_regressors('realign'); 
end 

%% Compute and Plot statistical images of realigned data
for iSeries = 1:nSeries
   S = SArray{iSeries};
   S.data = S.data - min(S.data);
   S.data.name = 'data';
   S.compute_stat_images();
   S.plot_stat_images('selectedSlices', 10:5:S.data.geometry.nVoxels(3)-10, ...
       'maxSnr', 150); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Coregister mean functional to anatomy and move data the same way
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iSeries = 1:nSeries
    S = SArray{iSeries};
    S.parameters.coregister.nameStationaryImage = 'anatomy';
    S.parameters.coregister.nameTransformedImage = 'mean';
    S.parameters.coregister.nameEquallyTransformedImages = 'data';
    
    S.coregister();
    S.data.reslice();
    
    % TODO: does not work, 4D images not properly aligned!
    S.data.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2)
 
end

%% Compute and Plot statistical images of coregistered data
for iSeries = 1:nSeries
   S = SArray{iSeries};
   S.data = S.data - min(S.data);
   S.data.name = 'data';
   S.compute_stat_images();
   S.plot_stat_images('selectedSlices', 10:5:S.data.geometry.nVoxels(3)-10, ...
       'maxSnr', 150); 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Coregister mean and snr images to each other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iSeries = 1:nSeries
   S = SArray{iSeries};
   M = S.mean.copyobj.compute_mask('threshold', 100);
   S.snr = S.snr.*M;
   S.mean.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2)
   S.snr.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2, ...
       'displayRange', [0 150]);
end

%% reslice geom of 2 stat images to that of series 1
doResizeManual = false;
if doResizeManual
    saveMean = SArray{2}.copyobj;
    saveSnr = SArray{2}.copyobj;
    saveSd = SArray{2}.copyobj;
    %
    % coregMatrix = SArray{1}.mean.copyobj.coregister_to(SArray{2}.mean);
    SArray{2}.mean.reslice(SArray{1}.mean);
    SArray{2}.snr.reslice(SArray{1}.mean);
    SArray{2}.sd.reslice(SArray{1}.mean);
    
    %% Plot stat images after reslicing
    for iSeries = 1:nSeries
        S = SArray{iSeries};
        S.plot_stat_images('selectedSlices', 10:5:S.data.geometry.nVoxels(3)-10, ...
            'maxSnr', 150);
        S.mean.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2)
        S.snr.plot('sliceDimension', 1, 'selectedSlices', 45:64, 'rotate90', 2, ...
            'displayRange', [0 150]);
    end
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute masks from co-registered tissue probability maps via thresholding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.parameters.compute_masks.nameInputImages = 'mean';
S.parameters.compute_masks.nameTargetGeometry = 'mean';
S.parameters.compute_masks.threshold = 0.5;
S.parameters.compute_masks.keepExistingMasks = false;

S.compute_masks();



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract region of interest data for masks from time series data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.parameters.analyze_rois.nameInputImages = {'mean', 'sd', 'snr', ...
    'coeffVar', 'diffLastFirst'};
S.parameters.analyze_rois.nameInputMasks = '.*mask';
S.parameters.analyze_rois.keepCreatedRois = false;
S.analyze_rois();



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do some fancy preprocessing to the time series to see how SNR increases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.realign();
S.compute_stat_images();
% S.plot_stat_images();

% maybe necessary if geometry changed too much through realignment
% S.coregister();
% S.compute_masks();
S.analyze_rois();



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Do some fancy preprocessing to the time series to see how SNR increases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.smooth();
S.compute_stat_images();
% S.plot_stat_images();
S.analyze_rois();
