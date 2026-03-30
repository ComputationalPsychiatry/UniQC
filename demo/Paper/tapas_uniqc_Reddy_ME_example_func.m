function tapas_uniqc_Reddy_ME_example_func(subID, run, verbosity)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UniQC Multi-Echo Example Pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example analysis pipeline for multi-echo EPI data, adapted from Reddy et al., 2025.
% All computations are performed; plotting is controlled by verbosity.
% Inputs:
%   subID     - subject ID (numeric)
%   run       - run number (numeric)
%   verbosity - 0: no plots, 1: summary figure, 2: all plots

tic

% Plotting control
showPlots = verbosity == 2;
showSummary = verbosity == 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Format subject and run IDs for BIDS compatibility
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Starting UniQC ME Example for sub-%02d, run-%01d\n', subID, run);
subID = sprintf('%02d', subID);
run = sprintf('%01d', run);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Locate Data Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Locating data path...\n');
dataPath = tapas_uniqc_get_path_data('openneuro_ds004662', [], true); % mustExist=true
fprintf('Data path: %s\n', dataPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check Subject Folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectFolder = fullfile(dataPath, ['sub-', char(subID)]);
fprintf('Checking for subject folder: %s\n', subjectFolder);
if ~exist(subjectFolder, 'dir')
    error('Data for subject %s not found at %s. Please download first.', subID, subjectFolder);
else
    fprintf('Subject folder found.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Working Directory for Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
derivativesDir = fullfile(fileparts(dataPath), 'derivatives', 'openneuro', 'ds004662');
workingDir = fullfile(derivativesDir, ['sub-', subID], ['run-', run]);
if ~exist(workingDir, 'dir')
    mkdir(workingDir);
    fprintf('Created working directory: %s\n', workingDir);
else
    fprintf('Using existing working directory: %s\n', workingDir);
end
resultsFolder = workingDir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Multi-Echo EPI Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Searching for multi-echo files...\n');
meFilenames = dir(fullfile(dataPath, ['sub-', subID], 'func', ...
    ['sub-', subID, '_task-handgrasp_run-', run, '_echo-*_bold.nii.gz']));
fprintf('Found %d echo files.\n', numel(meFilenames));
tmp = cell(1, numel(meFilenames));
for f = 1:numel(meFilenames)
    thisFilename = fullfile(meFilenames(f).folder, meFilenames(f).name);
    fprintf('Loading echo file: %s\n', thisFilename);
    % Load NIfTI and JSON metadata for each echo
    [~, tmpFilename] = fileparts(thisFilename);
    [~, rawMeFilename] = fileparts(tmpFilename);
    tmp{f} = MrImage(thisFilename);
    text = fileread(fullfile(meFilenames(f).folder, [rawMeFilename, '.json']));
    tmpJson = jsondecode(text);
    tmp{f}.dimInfo.add_dims(5, 'dimLabels', 'echoTime', ...
        'samplingPoints', tmpJson.EchoTime*1000, 'units', 'ms');
end
% Combine all echoes into a single 5D MrImage object
data = tmp{1}.combine(tmp);
data.name = 'Multi-echo EPI';
fprintf('Multi-echo data loaded and combined.\n');
clear tmp;

% Remove first 10 volumes
fprintf('Removing first 10 volumes from data.\n');
data = data.select('t', 11:data.dimInfo.nSamples('t'));
data.parameters.save.path = resultsFolder;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Raw Quality Metrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if showPlots
    data.mean('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), 'rotate90', 1);
    data.mean('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x');
    data.mean('t').plot('echoTime', 3, 'rotate90', 1, 'sliceDimension', 'y');
    data.snr('t').plot('echoTime', 1:data.dimInfo.nSamples('echoTime'), 'rotate90', 1, 'colorBar', 'on');
    data.snr('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x',  'colorBar', 'on');
    data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'sliceDimension', 'y',  'colorBar', 'on');
end

% Figures for paper (used for summary)
fig1 = data.mean('t').plot('echoTime', 3, 'rotate90', 1, 'z', 50, 'plotType', 'montage');
fig2 = data.mean('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage');
fig3 = data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'z', 50, 'plotType', 'montage', 'displayRange', [0 50], 'colorBar', 'on');
fig4 = data.snr('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', 30, 'plotType', 'montage', 'displayRange', [0 50], 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realign Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Check for tapas_physio_get_movement_quality_measures, download PhysIO if missing
if exist('tapas_physio_get_movement_quality_measures', 'file') ~= 2
    disp('PhysIO function not found. Downloading PhysIO toolbox from GitHub...');
    physioZip = fullfile(tempdir, 'PhysIO-master.zip');
    physioDir = fullfile(tempdir, 'PhysIO-master');
    url = 'https://github.com/ComputationalPsychiatry/PhysIO/archive/refs/heads/master.zip';
    websave(physioZip, url);
    unzip(physioZip, tempdir);
    addpath(genpath(physioDir));
    disp(['PhysIO toolbox downloaded and added to path from ', physioDir]);
    % Optionally, you can delete the zip after extraction
    delete(physioZip);
end
% compute FD using physIO
[quality_measures, dR] = tapas_physio_get_movement_quality_measures(realignmentParameters);
figure; plot(quality_measures.FD);
% for loading, use rData = MrImage(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'echoes'))
% and load(fullfile(resultsFolder, ['sub-', subID], ['run-', run], 'rp.mat'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% estimate T2*-based weights based on Poser et al., MRM, 2006 using a
%% general linear model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute mean across time
meanRData = rData.mean('t');
% remove unnecessary dimensions
meanRData = meanRData.remove_dims('t');
% log linear fit to compute T2Star and S0
[T2Starmap, S0map] = meanRData.log_linear_fit('echoTime');

% plot resulting maps
T2Starmap.plot('rotate90', 1, 'displayRange', [0 100]);
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
T2Starmap = T2Starmap .* mask;
T2Starmap.plot('rotate90', 1, 'displayRange', [0 100]);

% compute T2* weights
% weights = TE_n * exp(-TE_n/T2*)/sum_n(TE_n*exp(-TE/T2*)) 
% create TE images
TE = rData.dimInfo.samplingPoints{'echoTime'};
TE = TE(:);

TEImage = meanRData.copyobj();
TEImage.data = permute(repmat(TE, [1, TEImage.dimInfo.nSamples(1:3)]), [2 3 4 1]);

% compute weights
W_denominator = 0;
for nE = 1:meanRData.dimInfo.nSamples('echoTime')
    weightsT2{nE} = TEImage.select('echoTime', nE) .* exp(TEImage.select('echoTime', nE).*(-1)./T2Starmap);
    W_denominator = weightsT2{nE} + W_denominator;
end

% combine into 4D image
weightsT2 = weightsT2{1}.combine(weightsT2);
% divide by denominator
weightsT2 = weightsT2./W_denominator;
% plot resulting weights
weightsT2.name = 'weights_T2*';
weightsT2.plot('rotate90', 1, 'echoTime', 1:meanRData.dimInfo.nSamples('echoTime'), 'displayRange', [0 1]);

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
physFilename = fullfile(dataFolder,  ['sub-', subID], 'func', ...
    ['sub-', subID, '_task-handgrasp_run-', run, '_physio.tsv']);
physRaw = readtable(physFilename, ...
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

end
