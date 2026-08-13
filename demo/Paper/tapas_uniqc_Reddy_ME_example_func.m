function tapas_uniqc_Reddy_ME_example_func(subjectNumber, runNumber, verbosity, workspaceRoot)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UniQC Multi-Echo Example Pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example analysis pipeline for multi-echo EPI data, adapted from Reddy et al., 2025.
% All computations are performed; plotting is controlled by verbosity.
% Inputs:
%   subjectNumber   - subject number (numeric)
%   runNumber       - run number (numeric)
%   verbosity       - 0: no plots, 1: summary figure, 2: all plots
%   workspaceRoot   - scratch folder to write derivatives (created files)
%                     change to a fast write-access folder (not in OneDrive
%                     etc.)
%                     default: uniqc-code root folder

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plotting Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
showPlots = verbosity == 2;
showSummary = verbosity == 1;
dispVoxelCoords = [60,33,55];
percentSignalChangeRange = [-5 5];
tSnrRange = [5 50];

if nargin < 4
    workspaceRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Format subject and run IDs for BIDS compatibility
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Starting UniQC ME Example for sub-%02d, run-%01d\n', ...
    subjectNumber, runNumber);
subjectId = sprintf('%02d', subjectNumber);
runId = sprintf('%01d', runNumber);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Locate Data Path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Locating data path...\n');
dataPath = tapas_uniqc_get_path_data('openneuro_ds004662', [], true); % mustExist=true
fprintf('Data path: %s\n', dataPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check Subject Folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subjectFolder = fullfile(dataPath, ['sub-', subjectId]);
fprintf('Checking for subject folder: %s\n', subjectFolder);
if ~exist(subjectFolder, 'dir')
    error('Data for subject %s not found at %s. Please download first.', ...
        subjectId, subjectFolder);
else
    fprintf('Subject folder found.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create Working Directory for Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set derivativesDir at workspace root, not under dataPath
derivativesDir = fullfile(workspaceRoot, 'derivatives', 'openneuro', 'ds004662');
workingDir = fullfile(derivativesDir, ['sub-', subjectId], ['run-', runId]);
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
meFilenames = dir(fullfile(dataPath, ['sub-', subjectId], 'func', ...
    ['sub-', subjectId, '_task-handgrasp_run-', runId, '_echo-*_bold.nii.gz']));
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
fig1 = data.mean('t').plot('echoTime', 3, 'rotate90', 1, 'z', dispVoxelCoords(3), 'plotType', 'montage');
fig2 = data.mean('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', dispVoxelCoords(1), 'plotType', 'montage');
fig3 = data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'z', dispVoxelCoords(3), 'plotType', 'montage', 'displayRange', tSnrRange, 'colorBar', 'on');
fig4 = data.snr('t').plot('echoTime', 3, 'rotate90', 2, 'sliceDimension', 'x', 'x', dispVoxelCoords(1), 'plotType', 'montage', 'displayRange', tSnrRange, 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realign Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot tSNR of middle echo for comparison
data.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
    'displayRange', [0 data.snr('t').prctile(99)]);


% Check if realigned data and parameters already exist (echoes folder and rp.mat)
echoesFolder = fullfile(resultsFolder, 'echoes');
rpFile = fullfile(resultsFolder, 'rp.mat');
if exist(echoesFolder, 'dir') && exist(rpFile, 'file')
    disp('Realigned data and parameters found. Loading from disk...');
    rData = MrImage(echoesFolder);
    load(rpFile, 'realignmentParameters');
else
    % estimate realignment parameters based on the first echo and apply to all echoes
    [rData, realignmentParameters] = data.realign(...
        'interpolation', 4, ...
        'representationIndexArray', data.select('echoTime', 1), ...
        'applicationIndexArray', {'echoTime', 1:data.dimInfo.nSamples('echoTime')});

    % confirm increase in SNR after realignment
    rData.snr('t').plot('echoTime', 3, 'rotate90', 1, 'colorBar', 'on', ...
        'displayRange', [0 data.snr('t').prctile(99)]);

    % this took a long time - let's save the results
    rData.parameters.save.path = echoesFolder;
    rData.parameters.save.fileName = 'realigned_data.nii';
    disp(['Saving ', rData.get_filename]);
    rData.save();
    % also save realignment parameters
    save(rpFile, 'realignmentParameters');
end

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
figure; plot(quality_measures.FD); title('Framewise Displacement'); ylabel('mm');
% for loading, use rData = MrImage(fullfile(resultsFolder, ...
%     ['sub-', subjectId], ['run-', runId], 'echoes'))
% and load(fullfile(resultsFolder, ...
%     ['sub-', subjectId], ['run-', runId], 'rp.mat'))
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
anatData.parameters.save.path = fullfile(resultsFolder, 'segmentation');
% segment anatomical reference
[biasFieldCorrected, tissueProbMaps] = anatData.segment();
tissueProbMaps{1}.plot('rotate90', 1);
tissueProbMaps{2}.plot('rotate90', 1);
tissueProbMaps{3}.plot('rotate90', 1);

% create brain mask using tissue probability maps (GM + WM)
mask = tissueProbMaps{1} + tissueProbMaps{2} + tissueProbMaps{3};
% binarize and close
mask = mask.binarize(0.5).imfill('holes').imdilate(strel('sphere', 1));
mask.plot('rotate90', 1);
mask.parameters.save.path = resultsFolder;
mask.parameters.save.fileName = 'brainMask.nii';
mask.save();
maskFilename = mask.get_filename;

% apply to T2* image
T2Starmap = T2Starmap .* mask;
T2Starmap.plot('rotate90', 1, 'displayRange', [0 100]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Optimally combine image time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[cData, weightsT2] = rData.combine_multi_echo( ...
    'method', 'T2star', ...
    'imageMask', mask);

% Use the second echo as the conventional single-echo (SE) comparison,
% following Reddy et al. The same mask is applied to SE and ME-OC data.
seData = rData.combine_multi_echo( ...
    'method', 'select', ...
    'echoTime', 2, ...
    'imageMask', mask);
seData.name = 'Single echo (echo 2)';
cData.name = 'Multi-echo optimally combined';

% plot resulting weights
weightsT2.name = 'weights_T2*';
weightsT2.plot('rotate90', 1, 'echoTime', ...
    1:meanRData.dimInfo.nSamples('echoTime'), 'displayRange', [0 1]);

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

% Save the SE and ME-OC time series with distinct names.
outputFilenameStem = strrep(rawMeFilename, 'echo-5_', '');
outputFilenameStem = regexprep(outputFilenameStem, '_bold$', '');

seData.parameters.save.path = resultsFolder;
seData.parameters.save.fileName = [outputFilenameStem, '_desc-SE_bold.nii'];
disp(['Saving ', seData.get_filename]);
seData.save();

cData.parameters.save.path = resultsFolder;
cData.parameters.save.fileName = [outputFilenameStem, '_desc-MEOC_bold.nii'];
disp(['Saving ', cData.get_filename]);
cData.save();

% figures for paper
fig5 = cData.mean('t').plot('rotate90', 1, 'z', dispVoxelCoords(3), 'plotType', 'montage');
fig6 = cData.mean('t').plot('rotate90', 2, 'sliceDimension', 'x', 'x', dispVoxelCoords(1), 'plotType', 'montage');
fig7 = cData.snr('t').plot('rotate90', 1, 'z', dispVoxelCoords(3), 'plotType', 'montage', 'displayRange', [0 100], 'colorBar', 'on');
fig8 = cData.snr('t').plot('rotate90', 2, 'sliceDimension', 'x', 'x', dispVoxelCoords(1), 'plotType', 'montage', 'displayRange', [0 100], 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create regressors 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[regRight, regLeft, regCO2] = ...
    tapas_uniqc_Reddy_ME_create_physio_regressors(dataPath, subjectId, runId, ...
    cData.geometry.TR_s, cData.geometry.nVoxels(4), showPlots, 'downloaded');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Estimate GLM 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fit identical first-level models to SE and ME-OC. Keeping separate
% processing roots prevents the SPM output files from overwriting each
% other and makes the two Fig. 5 rows directly comparable.
modelNames = {'SE', 'ME-OC'};
modelFolderNames = {'SE', 'ME_OC'};
modelData = {seData, cData};
series = cell(size(modelData));
percentSignalChangeRight = cell(size(modelData));

nRealignmentRegressors = size(realignmentParameters, 2);
iBetaRight = nRealignmentRegressors + 1;

for iModel = 1:numel(modelData)
    series{iModel} = MrSeries();
    series{iModel}.data = modelData{iModel}.copyobj();
    series{iModel}.parameters.save.path = fullfile( ...
        resultsFolder, 'GLM', modelFolderNames{iModel});
    series{iModel}.glm.regressors.realign = realignmentParameters;
    series{iModel}.glm.regressors.other = [regRight; regLeft; regCO2]';

    % Estimate the same SPM model for both input time series.
    series{iModel}.glm.timingUnits = 'secs';
    series{iModel}.glm.repetitionTime = ...
        series{iModel}.data.geometry.TR_s;
    series{iModel}.glm.hrfDerivatives = [0 0];
    series{iModel}.glm.explicitMasking = maskFilename;
    series{iModel}.glm.maskingThreshold = -Inf;
    series{iModel}.specify_and_estimate_1st_level();

    % The right-grip regressor has unit peak-to-peak range, so its
    % mean-scaled beta directly represents percent BOLD signal change.
    percentSignalChangeRight{iModel} = ...
        series{iModel}.get_percent_signal_change(iBetaRight);
    percentSignalChangeRight{iModel}.name = sprintf( ...
        '%s right grip (%% signal change)', modelNames{iModel});
    percentSignalChangeRight{iModel}.parameters.save.path = resultsFolder;
    percentSignalChangeRight{iModel}.parameters.save.fileName = sprintf( ...
        '%s_desc-%s_rightGripPercentSignalChange.nii', ...
        outputFilenameStem, modelFolderNames{iModel});
    percentSignalChangeRight{iModel}.save();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display right-grip percent-signal-change maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if showPlots
    for iModel = 1:numel(series)
        series{iModel}.glm.plot_design_matrix();
    end
end

% Reddy et al. use Viridis and a common [-5, 5]% range for SE and ME-OC.
% The UniQC implementation returns an RGB matrix because Viridis is not a
% named MATLAB colormap and therefore does not appear in colormaplist.
viridisMap = tapas_uniqc_viridis(256);

meanFramewiseDisplacement = mean(quality_measures.FD, 'omitnan');
motionX = realignmentParameters(:, 1);
isValidCorrelationSample = isfinite(regRight(:)) & isfinite(motionX);
correlationMatrix = corrcoef(regRight(isValidCorrelationSample), ...
    motionX(isValidCorrelationSample));
taskMotionCorrelation = abs(correlationMatrix(1, 2));
fprintf('Mean FD = %.2f mm; |corr(right grip, X motion)| = %.2f.\n', ...
    meanFramewiseDisplacement, taskMotionCorrelation);

for iModel = 1:numel(percentSignalChangeRight)
    percentSignalChangeRight{iModel}.name = sprintf( ...
        '%s: FD = %.2f mm, |r| = %.2f', modelNames{iModel}, ...
        meanFramewiseDisplacement, taskMotionCorrelation);
end

fig9 = percentSignalChangeRight{1}.plot( ...
    'colorMap', viridisMap, 'rotate90', 1, 'z', dispVoxelCoords(3), ...
    'plotType', 'montage', 'displayRange', percentSignalChangeRange, ...
    'colorBar', 'on');
fig10 = percentSignalChangeRight{1}.fliplr.plot( ...
    'colorMap', viridisMap, 'rotate90', 2, 'sliceDimension', 'x', ...
    'x', dispVoxelCoords(1), 'plotType', 'montage', ...
    'displayRange', percentSignalChangeRange, 'colorBar', 'on');
fig11 = percentSignalChangeRight{2}.plot( ...
    'colorMap', viridisMap, 'rotate90', 1, 'z', dispVoxelCoords(3), ...
    'plotType', 'montage', 'displayRange', percentSignalChangeRange, ...
    'colorBar', 'on');
fig12 = percentSignalChangeRight{2}.fliplr.plot( ...
    'colorMap', viridisMap, 'rotate90', 2, 'sliceDimension', 'x', ...
    'x', dispVoxelCoords(1), 'plotType', 'montage', ...
    'displayRange', percentSignalChangeRange, 'colorBar', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save figures
mkdir(fullfile(resultsFolder, 'figures'));
saveas(fig1, fullfile(resultsFolder, 'figures', 'raw_mean_axial.png'));
saveas(fig2, fullfile(resultsFolder, 'figures', 'raw_mean_sagittal.png'));
saveas(fig3, fullfile(resultsFolder, 'figures', 'raw_tsnr_axial.png'));
saveas(fig4, fullfile(resultsFolder, 'figures', 'raw_tsnr_sagittal.png'));
saveas(fig5, fullfile(resultsFolder, 'figures', 'combreal_mean_axial.png'));
saveas(fig6, fullfile(resultsFolder, 'figures', 'combreal_mean_sagittal.png'));
saveas(fig7, fullfile(resultsFolder, 'figures', 'combreal_tsnr_axial.png'));
saveas(fig8, fullfile(resultsFolder, 'figures', 'combreal_tsnr_sagittal.png'));
saveas(fig9, fullfile(resultsFolder, 'figures', 'SE_pcscRight_axial.png'));
saveas(fig10, fullfile(resultsFolder, 'figures', 'SE_pcscRight_sagittal.png'));
saveas(fig11, fullfile(resultsFolder, 'figures', 'MEOC_pcscRight_axial.png'));
saveas(fig12, fullfile(resultsFolder, 'figures', 'MEOC_pcscRight_sagittal.png'));

end
