% Script tapas_uniqc_Reddy_ME_example
% ONE_LINE_DESCRIPTION
%
%  tapas_uniqc_Reddy_ME_example
%
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2025-05-02
% Copyright (C) 2025 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Multi-Echo EPI Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
% local parameters to set by user
% asssuming the data is stored in BIDS 
dataFolder = 'C:\Users\uqsboll2\Desktop\Reddy_ME_data';
subID = '01';
run = '2';
debug = 0;

% add results fodler
resultsFolder = strrep(dataFolder, 'data', 'results');
meFilenames = dir(fullfile(dataFolder, ['sub-', subID], 'func', ['*', 'run-', run, '*.nii.gz']));

for f = 1:numel(meFilenames)

    % get nifti filename
    thisFilename = fullfile(meFilenames(f).folder, meFilenames(f).name);
    
    % get json filename (call fileparts twice in case of .nii.gz)
    [~, tmpFilename] = fileparts(thisFilename);
    [~, rawMeFilename] = fileparts(tmpFilename);

    % load data
    % nifti image
    tmp{f} = MrImage(thisFilename);
    % json file
    text = fileread(fullfile(meFilenames(f).folder, [rawMeFilename, '.json']));
    tmpJson = jsondecode(text);
    tmp{f}.dimInfo.add_dims(5, 'dimLabels', 'echoTime', ...
        'samplingPoints', tmpJson.EchoTime*1000, 'units', 'ms');

end

% combine tmp 4D-images in one 5D-image
data = tmp{1}.combine(tmp);
data.name = 'Multi-echo EPI';
clear tmp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Raw Quality Metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot mean across time for each echo
data.mean('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), ...
    'rotate90', 1);
% plot 3rd echo in sagittal and coronal orientation
data.mean('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x');
data.mean('t').plot('echoTime', 3, 'rotate90', 1, 'sliceDimension', 'y');


% plot tSNR across time for each echo
data.snr('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), ...
    'rotate90', 1, 'colorBar', 'on');

% plot 3rd echo in sagittal and coronal orientation
data.snr('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x',  'colorBar', 'on');
data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'sliceDimension', 'y',  'colorBar', 'on');

% figures for paper
fig1 = data.mean('t').plot('echoTime', 3, 'rotate90', 1, 'z', 50, 'plotType', 'montage');
fig2 = data.mean('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage');
fig3 = data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'z', 50, 'plotType', 'montage', 'displayRange', [0 50], 'colorBar', 'on');
fig4 = data.snr('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage', 'displayRange', [0 50], 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realign Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% remove first 10 volumes
data = data.select('t', 11:data.dimInfo.nSamples('t'));

% plot tSNR of middle echo for comparison
data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
    'displayRange', [0 data.snr('t').prctile(99)]);

% estimate realignment parameters based on the first echo and apply to all
% echoes
[rData, realignmentParameters] = data.realign(...
    'representationIndexArray', data.select('echoTime', 1), ...
    'applicationIndexArray', {'echoTime', 1:data.dimInfo.nSamples('echoTime')});

% confirm increase in SNR after realignment
rData.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
    'displayRange', [0 data.snr('t').prctile(99)]);

% this took a long time - let's save the results
rData.parameters.save.path = fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'echoes');
rData.parameters.save.fileName = [strrep(rawMeFilename, 'echo-5_', ''), '.nii'];
disp(['Saving ', rData.get_filename]);
rData.save();
% also save realignment parameters
save(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'rp.mat'), 'realignmentParameters');

% copute FD using physIO
[quality_measures, dR] = tapas_physio_get_movement_quality_measures(realignmentParameters, 50);
figure; plot(quality_measures.FD);
% for loading, use rData = MrImage(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'echoes')
% and load(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'rp.mat'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% estimate T2*-based weights based on Poser et al., MRM, 2006 using a
%% general linear model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract TEs
TE = rData.dimInfo.samplingPoints{'echoTime'};

% Ensure TE is a column vector
TE = TE(:);
nTE = length(TE);

% compute mean across time
meanRData = rData.mean('t');
meanRData.plot('rotate90', 1, 'echoTime', 1:meanRData.dimInfo.nSamples('echoTime'));
% remove unnecessary dimensions
meanRData = meanRData.remove_dims('t');

snrThresh = 10;
T2range = [1, 5000]; % ms

S_size = size(meanRData.data);
spatialSize = S_size(1:end-1);
nVoxels = prod(spatialSize);

% Reshape to [nTE x nVoxels]
S_reshaped = reshape(meanRData.data, [nVoxels, nTE])';  % [nTE x nVoxels]

% Compute masks
isPositive = all(S_reshaped > 0, 1);
meanSignal = mean(S_reshaped, 1);
goodSNR = meanSignal > snrThresh;
validMask = isPositive & goodSNR;

% Log-transform only valid voxels
logS = zeros(size(S_reshaped));
logS(:, validMask) = log(S_reshaped(:, validMask));

% Design matrix
X = [ones(nTE, 1), TE];
X_pinv = pinv(X);

% Solve
beta = X_pinv * logS(:, validMask);
lnS0_valid = beta(1, :);
slope_valid = beta(2, :);

% Filter out non-decaying voxels (slope ≥ 0)
decayMask = slope_valid < 0;
validMaskIdx = find(validMask);
keepIdx = validMaskIdx(decayMask);

% Prepare output
T2map = NaN(nVoxels, 1);
S0map = NaN(nVoxels, 1);

% Compute S0 and T2
T2_valid = -1 ./ slope_valid(decayMask);
S0_valid = exp(lnS0_valid(decayMask));

% Clamp T2 to valid physiological range
T2_valid(T2_valid < T2range(1) | T2_valid > T2range(2)) = NaN;

% Assign to map
T2map(keepIdx) = T2_valid;
S0map(keepIdx) = S0_valid;

% Reshape to original dimensions
T2mapData = reshape(T2map, spatialSize);
S0mapData = reshape(S0map, spatialSize);

% recast as MrImages
T2map = meanRData.copyobj();
T2map = T2map.remove_dims('echoTime');
T2map.data = T2mapData;
T2map.name = 'Estimated T2* values';

S0map = meanRData.copyobj();
S0map = S0map.remove_dims('echoTime');
S0map.data = S0mapData;
S0map.name = 'Estimated S0 values';

% plot resulting maps
T2map.plot('rotate90', 1, 'displayRange', [0 100]);
S0map.plot('rotate90', 1);

% create brain mask
% compute mean across echo time as anatomical reference
anatData = meanRData.mean('echoTime').remove_dims('echoTime');
% segment anatomical reference
[biasFieldCorrected, tissueProbMaps] = anatData.segment();
tissueProbMaps{1}.plot('rotate90', 1);
tissueProbMaps{2}.plot('rotate90', 1);
tissueProbMaps{3}.plot('rotate90', 1);

% create brain mask using tissue probability maps (GM + WM)
mask = tissueProbMaps{1} + tissueProbMaps{2} + tissueProbMaps{3};
% binarize and close
mask = mask.binarize(0.5).imfill('holes');
mask.plot('rotate90', 1);

% apply to T2* image
T2map = T2map .* mask;
T2map.plot('rotate90', 1, 'displayRange', [0 100]);

% compute T2* weights
% weights = TE_n * exp(-TE_n/T2*)/sum_n(TE_n*exp(-TE/T2*)) 
% create TE images
TEImage = meanRData.copyobj();
TEImage.data = permute(repmat(TE, [1, TEImage.dimInfo.nSamples(1:3)]), [2 3 4 1]);

% compute weights
W_denominator = 0;
for nE = 1:meanRData.dimInfo.nSamples('echoTime')
    weightsT2{nE} = TEImage.select('echoTime', nE) .* exp(TEImage.select('echoTime', nE).*(-1)./T2map);
    W_denominator = weightsT2{nE} + W_denominator;
end

% combine into 4D image
weightsT2 = weightsT2{1}.combine(weightsT2);
% divide by denominator
weightsT2 = weightsT2./W_denominator;
% plot resulting weights
weightsT2.name = 'weights_T2*';
weightsT2.plot('rotate90', 1, 'echoTime', 1:nTE, 'displayRange', [0 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Optimally combine image time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% permute rData to make time trailing dimension
rData = rData.permute([1 2 3 5 4]);

% multiply by weights 
cData = rData.*weightsT2;

% sum across echoes
cData = cData.sum('echoTime').remove_dims();

% check results
cData.mean.plot('rotate90', 1, 'colorBar', 'on');
cData.snr.plot('rotate90', 1, 'colorBar', 'on');

% report SNR in grey and white matter
gmMask = tissueProbMaps{1}.binarize(0.5);
wmMask = tissueProbMaps{2}.binarize(0.5);
snrCData = cData.snr();
snrCData.analyze_rois({gmMask, wmMask});
fprintf('Mean SNR in grey and white matter is %.1f and %.1f.\n', ...
    snrCData.rois{1}.perVolume.mean, snrCData.rois{2}.perVolume.mean);

% let's save the results again
cData.parameters.save.path = fullfile(resultsFolder, ['sub-', subID], ['run-', run]);
cData.parameters.save.fileName = [strrep(rawMeFilename, 'echo-5_', ''), '.nii'];
disp(['Saving ', cData.get_filename]);
cData.save();
% for loading, use cData = MrImage(fullfile(resultsFolder, ['sub-', subID], ['run-', run], ['sub-', subID, '_task-handgrasp_run-1_bold.nii']))

% figures for paper
fig5 = cData.mean('t').plot('rotate90', 1, 'z', 50, 'plotType', 'montage');
fig6 = cData.mean('t').plot('rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage');
fig7 = cData.snr('t').plot('rotate90', 1, 'z', 50, 'plotType', 'montage', 'displayRange', [0 100], 'colorBar', 'on');
fig8 = cData.snr('t').plot('rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage', 'displayRange', [0 100], 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create regressors 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract physiological regressors
physRaw = readtable("C:\Users\uqsboll2\Desktop\Reddy_ME_data\sub-03\func\sub-03_task-handgrasp_run-1_physio.tsv", ...
    "FileType","text",'Delimiter', '\t');
physRaw = renamevars(physRaw, ["Var1", "Var2", "Var3", "Var4"], ["trigger", "CO2", "right", "left"]);
fs = 20; % Hz, sampling frequency from json file
tPhys = 0:1/fs:1/fs*(height(physRaw)-1);
figure; plot(tPhys, physRaw.CO2); hold all; plot(tPhys, physRaw.right); ...
    plot(tPhys, physRaw.left);

% normalise force traces to maximum grip force
normRight = (physRaw.right - min(physRaw.right))/(max(physRaw.right) - min(physRaw.right));
normLeft = (physRaw.left - min(physRaw.left))/(max(physRaw.left) - min(physRaw.left));
fprintf('Max/Min right: %.1f / %.1f.\nMax/Min left: %.1f / %.1f.\n ', ...
    max(normRight), min(normRight), max(normLeft), min(normLeft));

% convolved with hrf
[hrf,p] = spm_hrf(1/fs);
tHrf = 0:1/fs:1/fs*(length(hrf)-1);
figure; plot(tHrf, hrf);
CNormRight = conv(normRight, hrf);
CNormLeft = conv(normLeft, hrf);
CNormRight(length(tPhys)+1:end) = [];
CNormLeft(length(tPhys)+1:end) = [];
figure; plot(tPhys, CNormRight); hold all; plot(tPhys, CNormLeft);

% rescale to normalised grip force and de-mean
NCNRight = (CNormRight - min(CNormRight))/(max(CNormRight) - min(CNormRight));
DNCNRight = NCNRight - mean(NCNRight);
NCNLeft = (CNormLeft - min(CNormLeft))/(max(CNormLeft) - min(CNormLeft));
DNCNLeft = NCNLeft - mean(NCNLeft);

figure; plot(tPhys, DNCNRight); hold all; plot(tPhys, DNCNLeft);

% downsample to MR TR
tMR = cData.geometry.TR_s*10:cData.geometry.TR_s:cData.geometry.TR_s*(cData.geometry.nVoxels(4)+9);
regRight = interp1(tPhys, DNCNRight, tMR);
regLeft = interp1(tPhys, DNCNLeft, tMR);
figure; plot(tMR, regRight); hold all; plot(tMR, regLeft);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimate GLM 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% recast as MrSeries object
S = MrSeries();
S.data = cData;
S.parameters.save.path = fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'GLM');
S.glm.regressors.realign = realignmentParameters;
S.glm.regressors.other = [regRight; regLeft]';

% compute statistics images
S.compute_stat_images();

% estimate GLM
% timing
S.glm.timingUnits = 'secs';
S.glm.repetitionTime = S.data.geometry.TR_s;
% don't estimate derivatives
S.glm.hrfDerivatives = [0 0];
% add an explicit mask
S.glm.explicitMasking = mask;
% turn of inplicit masking threshold;
S.glm.maskingThreshold = -Inf;
% specify model and estimate
S.specify_and_estimate_1st_level();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display beta maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot design matrix
S.glm.plot_design_matrix();
% load and mask design matrices
betaRight = MrImage(fullfile(S.glm.parameters.save.path, 'beta_0007.nii'));
betaLeft = MrImage(fullfile(S.glm.parameters.save.path, 'beta_0008.nii'));
mBetaRight = betaRight.*mask;
mBetaRight.data(isnan(mBetaRight.data)) = 0;
mBetaLeft = betaLeft.*mask;
mBetaLeft.data(isnan(mBetaLeft.data)) = 0;
% plot beta maps
mBetaRight.plot('colorMap', 'parula', 'displayRange', [-5 5], 'rotate90', 1);
mBetaLeft.plot('colorMap', 'parula', 'displayRange', [-5 5], 'rotate90', 1);
mBetaRight.plot('colorMap', 'parula', 'displayRange', [-5 5], 'sliceDimension', 'x', 'rotate90', 2, 'x', 16:70);
mBetaLeft.plot('colorMap', 'parula', 'displayRange', [-5 5], 'sliceDimension', 'x', 'rotate90', 2, 'x', 16:70);

% figures for paper
fig9 = mBetaRight.plot('colorMap', 'parula','rotate90', 1, 'z', 50, 'plotType', 'montage', 'displayRange', [-5 5], 'colorBar', 'on');
fig10 = mBetaRight.plot('colorMap', 'parula', 'rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage', 'displayRange', [-5 5], 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save figures
mkdir(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures'));
saveas(fig1, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'raw_mean_axial.png'));
saveas(fig2, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'raw_mean_sagittal.png'));
saveas(fig3, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'raw_tsnr_axial.png'));
saveas(fig4, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'raw_tsnr_sagittal.png'));
saveas(fig5, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'combreal_mean_axial.png'));
saveas(fig6, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'combreal_mean_sagittal.png'));
saveas(fig7, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'combreal_tsnr_axial.png'));
saveas(fig8, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'combreal_tsnr_sagittal.png'));
saveas(fig9, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'pcscRight_axial.png'));
saveas(fig10, fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'figures', 'pcscRight_sagittal.png'));
toc