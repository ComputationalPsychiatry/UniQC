clear; close all; clc

%% load data
% dataFolder = 'C:\Users\uqsboll2\Desktop\data\Multi-echo_EPI_7T\data';
dataFolder = '/space/timtam/2/users/saskia/Multi_echo_data/Multi-echo_EPI_7T/data';
subID = 'S01';

meFileNames = dir(fullfile(dataFolder, subID, 'ME_EPI', '*.nii'));
seFileName = dir(fullfile(dataFolder, subID, 'SE_EPI', '*.nii'));

% load multi-echo EPI
for n = 1:numel(meFileNames)
    
    % get filename
    thisFolder = meFileNames(n).folder;
    thisFileName = meFileNames(n).name;
    [~, rawFileName] = fileparts(thisFileName);
    % load data
    tmp{n} = MrImage(fullfile(thisFolder, thisFileName));
    
    % read json file
    text = fileread(fullfile(thisFolder, [rawFileName, '.json']));
    tmpj = jsondecode(text);
    
    % add TE
    tmp{n}.dimInfo.add_dims(5, 'dimLabels', 'TE', ...
        'samplingPoints', tmpj.EchoTime*1000, 'units', 'ms');
end
ME = tmp{1}.combine(tmp);
ME.name = 'Multi-echo EPI';
ME.plot('rotate90', 1, 'TE', 1:4, 't', 1);

% load single-echo EPI
SE = MrImage(fullfile(seFileName.folder, seFileName.name));
SE.name = 'Single-echo EPI';
SE.plot('rotate90', 1);
%% Figure 1
% draw masks
sliceNumber = [8,13,18,30];
nRoisPerSlice = [1, 1, 1, 1]; % [4, 4, 4, 1]
n = 1;
for thisSlice = 1:numel(sliceNumber)
    for thisRoi = 1:nRoisPerSlice(thisSlice)
        masks{n} = ME.mean.draw_mask('z', sliceNumber(thisSlice));
        % add sampling point to dimInfo
        masks{n}.dimInfo.add_dims(6, 'dimLabels', 'maskID', ...
            'samplingPoints', n);
        n = n + 1;
    end
end

% combineMasks into one object
combMasks = masks{1}.combine(masks, {'maskID'});
% plot
ME.mean('TE').plot('rotate90', 1, 'overlayImages', combMasks.sum('maskID'), ...
    'overlayMode', 'mask', 'z', sliceNumber, 't', 1, 'displayRange', [0 800]);
%% Figure 2
sliceNumber2 = [5, 12, 18, 30];
ME.sum(5).mean('t').plot('rotate90', 1, 'z', sliceNumber2, 'nRows', 1);
SE.mean('t').plot('rotate90', 1, 'z', sliceNumber2, 'nRows', 1);

%% Figure 3
% realign
% single-echo
[rSE, rp_SE] = SE.realign();
% check snr
SE.snr('t').plot('rotate90', 1, 'displayRange', [0 60], 'colorMap', 'hot');
rSE.snr('t').plot('rotate90', 1, 'displayRange', [0 60], 'colorMap', 'hot');
% multi echo
[rME, rp_ME] = ME.realign('representationIndexArray', ME.sum('TE'), ...
    'applicationIndexArray', {'TE', 1:4}, 'interpolation', 2);
% check snr
ME.sum('TE').snr('t').plot('rotate90', 1, 'displayRange', [0 60], 'colorMap', 'hot');
rME.sum('TE').snr('t').plot('rotate90', 1, 'displayRange', [0 60], 'colorMap', 'hot');

% coregister single-echo to multi-echo
meanSE = rSE.mean('t');
meanME = rME.sum('TE').mean('t');
[cmeanSE, affineTrafo, crSE] = meanSE.coregister_to(meanME, ...
    'otherImages', rSE, 'trafoParameters', 'affine');
meanME.plot('rotate90', 1);
crSE = crSE{1};
crSE.mean('t').plot('rotate90', 1);
meanSE.plot('rotate90', 1);

% segment
ME_s = rME.select('TE', 2).mean('t');
[~, greyME] = ME_s.segment('tissueTypes', {'GM'}, ...
    'mapOutputSpace', 'native', 'samplingDistance', 10);
greyME = greyME{1};
maskME = greyME.binarize(0.5);
maskME.data(:,:,1) = 0;
maskME.plot('rotate90', 1);
masks{end+1} = maskME;

SE_s = crSE.mean('t');
[~, greySE] = SE_s.segment('tissueTypes', {'GM'}, 'mapOutputSpace', 'native');
greySE = greySE{1};
maskSE = greySE.binarize(0.5);
maskSE.data(:,:,1) = 0;
maskSE.plot('rotate90', 1);

% echo combination
% simple sum
snr_sum = rME.select('t', 3:rME.dimInfo.nSamples('t')).sum('TE').snr('t');

% CNR based
% make TE image
TE = rME.mean('t').copyobj();
echoTimes(1,1,1,1,1:4) = rME.dimInfo.samplingPoints{'TE'};
TE.data = repmat(echoTimes, [TE.dimInfo.nSamples(1:4), 1]);
% get ME SNR
ME_snr = rME.select('t', 3:26).snr('t');
% compute weights
w_CNR = ME_snr.*TE./sum(ME_snr.*TE, 'TE');
% compute snr
snr_CNR = snr(sum(rME.select('t', 3:rME.dimInfo.nSamples('t')).*w_CNR, 'TE'), 't');

% compute CNR
CNR_sum = snr_sum.*mean(rME.dimInfo.samplingPoints{'TE'});
CNR_CNR = snr_CNR.*sum(w_CNR.*rME.dimInfo.samplingPoints{'TE'}, 'TE');
CNR_SE = crSE.select('t', 3:crSE.dimInfo.nSamples('t')).snr.*25;

% compute difference
CNR_diff_sumvsCNR = (CNR_CNR - CNR_sum)./CNR_sum;
CNR_diff_sumvsSE = (CNR_sum - CNR_SE)./CNR_SE;
CNR_diff_CNRvsSE = (CNR_CNR - CNR_SE)./CNR_SE;

CNR_diff_sumvsCNR.extract_rois(masks);
CNR_diff_sumvsCNR.compute_roi_stats();
for n = 1:numel(CNR_diff_sumvsCNR.rois)
    CNR_diff_sumvsCNR.rois{n}.plot('dataGrouping', 'perVolume');
end

CNR_diff_sumvsSE.extract_rois(masks);
CNR_diff_sumvsSE.compute_roi_stats();
for n = 1:numel(CNR_diff_sumvsSE.rois)
    CNR_diff_sumvsSE.rois{n}.plot('dataGrouping', 'perVolume');
end

CNR_diff_CNRvsSE.extract_rois(masks);
CNR_diff_CNRvsSE.compute_roi_stats();
for n = 1:numel(CNR_diff_CNRvsSE.rois)
    CNR_diff_CNRvsSE.rois{n}.plot('dataGrouping', 'perVolume');
end

%% Figure 5
spm fmri;
% read in data
ME_CNR = MrSeries();
CNR_comb_data = sum(rME.select('t', 3:rME.dimInfo.nSamples('t')).*w_CNR, 'TE');
CNR_comb_data.dimInfo.remove_dims();
ME_CNR.data = CNR_comb_data;
% check image quality and snr
ME_CNR.compute_stat_images();
ME_CNR.mean.plot('rotate90', 1);
ME_CNR.snr.plot('rotate90', 1);

% make brain mask
ME_CNR.masks{1} = rME.select('TE', 1).mean('t').binarize(400).remove_clusters([0 100], '2d').imfill('holes');
ME_CNR.masks{1}.plot('rotate90', 1);
ME_CNR.masks{1}.parameters.save.fileName = 'mask.nii';
ME_CNR.masks{1}.dimInfo.remove_dims();
ME_CNR.masks{1}.save();

% timing in seconds
ME_CNR.glm.timingUnits = 'secs';
% repetition time - check!
ME_CNR.glm.repetitionTime = ME_CNR.data.geometry.TR_s;
% model derivatives
ME_CNR.glm.hrfDerivatives = [0 0];
% noise model AR1
ME_CNR.glm.serialCorrelations = 'AR1';

% add rp
ME_CNR.glm.regressors.realign = rp_ME(3:end,:);

% add conditions
dummyTime = 2*ME_CNR.data.geometry.TR_s;
onsets{1} = [30, 210, 310, 530, 670, 770] - dummyTime;
onsets{2} = [70, 170, 390, 490, 590, 810] - dummyTime;
onsets{3} = [110, 250, 350, 450, 630, 730] - dummyTime;
block_length = 30;
% add to glm
ME_CNR.glm.conditions.names = {'neutral', 'congruent', 'incongruent'};
ME_CNR.glm.conditions.onsets = onsets;
% add durations
ME_CNR.glm.conditions.durations = {block_length, block_length, block_length};
% add an explicit mask
ME_CNR.glm.explicitMasking = ME_CNR.masks{1}.get_filename;
% turn of inplicit masking threshold;
ME_CNR.glm.maskingThreshold = -Inf;

% estimate
ME_CNR.specify_and_estimate_1st_level;

% smooth
ME_CNR.parameters.smooth.fwhmMillimeters = 5;
ME_CNR.smooth();
ME_CNR.compute_stat_images();
ME_CNR.specify_and_estimate_1st_level;