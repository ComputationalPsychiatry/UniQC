function results = tapas_uniqc_Poser_ME_example_func(subjectNumber, runNumber, verbosity, workspaceRoot, varargin)
% Poser-inspired sequence-development analysis of public Reddy ME data.
%   results = tapas_uniqc_Poser_ME_example_func(3, 1, 1, scratchFolder)
% Same first four inputs as tapas_uniqc_Reddy_ME_example_func.
% verbosity: 0 no plots, 1 comparisons, 2 summary maps, 3 diagnostics.
% Name/value options:
%   dataPath          downloaded ds004662 root (default UniQC data registry)
%   weightVolumes     retained indices for weights (default []: all retained)
%   evaluationVolumes retained indices for metrics (default []: all retained)
%   runGLM            fit identical handgrasp models (default true)
% Ten initial volumes are discarded, as in the Reddy example. Calibration
% is NOT assumed to be rest. See POSER_ME_EXAMPLE.md before interpreting CNR.
% Outputs go to derivatives/openneuro/ds004662/Poser/sub-XX/run-X.
% Returns small summaries and paths; maps and weights are saved on disk.
%
% See also tapas_uniqc_Poser_ME_example tapas_uniqc_Poser_ME_compare
% Copyright (C) 2026 UniQC developers. GNU GPL version 3 or later.

if nargin < 1, subjectNumber = 3; end
if nargin < 2, runNumber = 1; end
if nargin < 3, verbosity = 1; end
if nargin < 4
    workspaceRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
validateattributes(subjectNumber, {'numeric'}, {'scalar','integer','positive'});
validateattributes(runNumber, {'numeric'}, {'scalar','integer','positive'});
validateattributes(verbosity, {'numeric'}, {'scalar','integer','>=',0,'<=',3});
defaults.dataPath = tapas_uniqc_get_path_data('openneuro_ds004662');
defaults.weightVolumes = [];
defaults.evaluationVolumes = [];
defaults.runGLM = true;
options = tapas_uniqc_propval(varargin, defaults);
validateattributes(options.runGLM, {'logical'}, {'scalar'});
subjectId = sprintf('%02d', subjectNumber);
runId = sprintf('%d', runNumber);
stem = sprintf('sub-%s_task-handgrasp_run-%s', subjectId, runId);
files = dir(fullfile(options.dataPath, ['sub-' subjectId], 'func', ...
    [stem '_echo-*_bold.nii.gz']));
if numel(files) < 2
    error('uniqc:Poser:MissingEchoes', ...
        'Need at least two echoes for %s. Run tapas_uniqc_download_example_data(''openneuro_ds004662'').', stem);
end
%% Read and sort actual echo times; never rely on lexical file order.
TE = zeros(1, numel(files));
metadata = cell(size(TE));
for iEcho = 1:numel(files)
    metadata{iEcho} = jsondecode(fileread(fullfile(files(iEcho).folder, ...
        strrep(files(iEcho).name, '.nii.gz', '.json'))));
    TE(iEcho) = 1000 * metadata{iEcho}.EchoTime;
end
[TE, order] = sort(TE);
files = files(order);
metadata = metadata(order);
validateattributes(TE, {'numeric'}, {'finite','positive','increasing'});
workingDir = fullfile(workspaceRoot, 'derivatives', 'openneuro', ...
    'ds004662', 'Poser', ['sub-' subjectId], ['run-' runId]);
if ~exist(workingDir, 'dir'), mkdir(workingDir); end
images = cell(size(TE));
for iEcho = 1:numel(files)
    images{iEcho} = MrImage(fullfile(files(iEcho).folder, files(iEcho).name));
    if iEcho > 1 && (~isequal(size(images{iEcho}.data), size(images{1}.data)) || ...
            metadata{iEcho}.RepetitionTime ~= metadata{1}.RepetitionTime || ...
            ~isequal(images{iEcho}.dimInfo.get_affine_matrix(), images{1}.dimInfo.get_affine_matrix()))
        error('uniqc:Poser:EchoGeometry', 'Echo geometry, volume count and TR must match.');
    end
    images{iEcho}.dimInfo.add_dims(5, 'dimLabels', 'echoTime', ...
        'samplingPoints', TE(iEcho), 'units', 'ms');
end
data = images{1}.combine(images);
clear images;
if data.dimInfo.nSamples('t') < 13
    error('uniqc:Poser:ShortRun', 'Need at least three volumes after discarding the first ten.');
end
data = data.select('t', 11:data.dimInfo.nSamples('t'));
data.parameters.save.path = workingDir;
% Use the entire retained task run for both T2* and tSNR/CNR estimation
% (200 volumes for Reddy). Averaging improves precision, but balanced task
% blocks do not guarantee cancellation of voxelwise BOLD changes: fitted
% T2* is a task-state average, not necessarily the resting baseline T2*.
% Task responses also increase temporal variance, so tSNR-based CNR weights
% may downweight echoes with stronger task responses. These are descriptive
% task-run estimates, not Poser's resting-state or held-out estimates.
if isempty(options.weightVolumes)
    options.weightVolumes = 1:data.dimInfo.nSamples('t');
end
if isempty(options.evaluationVolumes)
    options.evaluationVolumes = 1:data.dimInfo.nSamples('t');
end
validateattributes(options.weightVolumes, {'numeric'}, ...
    {'vector','integer','positive','<=',data.dimInfo.nSamples('t')});
validateattributes(options.evaluationVolumes, {'numeric'}, ...
    {'vector','integer','positive','<=',data.dimInfo.nSamples('t')});
if numel(unique(options.weightVolumes)) ~= numel(options.weightVolumes) || ...
        numel(unique(options.evaluationVolumes)) ~= numel(options.evaluationVolumes) || ...
        numel(options.weightVolumes) < 3 || numel(options.evaluationVolumes) < 3
    error('uniqc:Poser:InvalidWindows', ...
        'Use windows with at least three distinct retained-volume indices each; overlap is allowed.');
end
%% One motion estimate from echo 1, applied to every echo, as in Reddy.
fprintf('Poser comparison: %s, %g T, %d echoes.\n', stem, ...
    metadata{1}.MagneticFieldStrength, numel(TE));
[rData, realignmentParameters] = data.realign('interpolation', 4, ...
    'representationIndexArray', data.select('echoTime', 1), ...
    'applicationIndexArray', {'echoTime', 1:numel(TE)});
clear data;
save(fullfile(workingDir, 'rp.mat'), 'realignmentParameters');
%% Deterministic tissue ROIs replace manually drawn Poser regions.
anat = rData.mean('t').mean('echoTime').remove_dims();
anat.parameters.save.path = fullfile(workingDir, 'segmentation');
[~, tissues] = anat.segment();
mask = tissues{1} + tissues{2} + tissues{3};
mask = mask.binarize(0.5).imfill('holes');
roiMasks = {mask, tissues{1}.binarize(0.5), tissues{2}.binarize(0.5)};
roiNames = {'Brain', 'GM', 'WM'};
write_map(mask, workingDir, 'brainMask');
%% Estimate weights and quality metrics on the retained task run by default.
comparison = tapas_uniqc_Poser_ME_compare(rData, mask, ...
    options.weightVolumes, options.evaluationVolumes);
results.summary = comparison.summary;
results.outputDirectory = workingDir;
results.echoTimesMs = TE;
results.options = options;
results.magneticFieldStrength = metadata{1}.MagneticFieldStrength;
results.subjectNumber = subjectNumber;
results.runNumber = runNumber;
results.discardedVolumes = 10;
results.sourceFiles = arrayfun(@(f) fullfile(f.folder, f.name), files, 'UniformOutput', false);
results.reference = '10.1016/j.neuroimage.2009.01.007';
results.roiGainPercent = nan(numel(comparison.names), numel(roiMasks));
results.roiVoxelCount = zeros(1, numel(roiMasks));
for iRoi = 1:numel(roiMasks)
    valid = logical(roiMasks{iRoi}.data) & logical(comparison.validMask.data);
    results.roiVoxelCount(iRoi) = nnz(valid);
    for iMethod = 1:numel(comparison.names)
        values = comparison.gain{iMethod}.data;
        results.roiGainPercent(iMethod, iRoi) = mean(values(valid));
    end
end
results.roiNames = roiNames;
writetable(results.summary, fullfile(workingDir, 'echo_comparison.csv'));
roiTable = array2table(results.roiGainPercent, 'VariableNames', roiNames, ...
    'RowNames', comparison.names);
writetable(roiTable, fullfile(workingDir, 'roi_gain_percent.csv'), 'WriteRowNames', true);
write_map(comparison.validMask, workingDir, 'comparisonMask');

%% Optional activation comparison using identical Reddy models.
if options.runGLM
    [right, left, co2] = tapas_uniqc_Reddy_ME_create_physio_regressors( ...
        options.dataPath, subjectId, runId, metadata{1}.RepetitionTime, ...
        rData.dimInfo.nSamples('t'), verbosity >= 3, 'recomputed');
    pscMaps = cell(size(comparison.names));
    tMaps = cell(size(comparison.names));
end
figuresDir = fullfile(workingDir, 'figures');
if verbosity > 0 && ~exist(figuresDir, 'dir'), mkdir(figuresDir); end
slice = round(rData.dimInfo.nSamples('z') / 2);
ordered = rData.permute([1 2 3 5 4]);
clear rData;
for iMethod = 1:numel(comparison.names)
    methodId = sprintf('method-%02d', iMethod);
    write_map(comparison.weights{iMethod}, workingDir, [methodId '_weights']);
    write_map(comparison.mean{iMethod}, workingDir, [methodId '_mean']);
    write_map(comparison.tsnr{iMethod}, workingDir, [methodId '_tsnr']);
    write_map(comparison.sensitivity{iMethod}, workingDir, [methodId '_sensitivityProxy']);
    write_map(comparison.gain{iMethod}, workingDir, [methodId '_gainPercent']);
    if verbosity >= 2
        map = comparison.tsnr{iMethod};
        map.name = comparison.names{iMethod};
        fig = map.plot('z', slice, 'rotate90', 1, 'plotType', 'montage', ...
            'displayRange', [0 100], 'colorBar', 'on');
        saveas(fig, fullfile(figuresDir, [methodId '_tsnr.png']));
    end
    if verbosity >= 3
        comparison.weights{iMethod}.plot('echoTime', 1:numel(TE), ...
            'z', slice, 'rotate90', 1, 'displayRange', [0 1]);
    end
    if options.runGLM
        combined = ordered .* comparison.weights{iMethod};
        combined = combined.sum('echoTime').remove_dims();
        series = MrSeries();
        series.data = combined;
        series.parameters.save.path = fullfile(workingDir, 'GLM', methodId);
        series.glm.regressors.realign = realignmentParameters;
        series.glm.regressors.other = [right; left; co2]';
        series.glm.timingUnits = 'secs';
        series.glm.repetitionTime = metadata{1}.RepetitionTime;
        series.glm.hrfDerivatives = [0 0];
        series.glm.explicitMasking = fullfile(workingDir, 'brainMask.nii');
        series.glm.maskingThreshold = -Inf;
        series.specify_and_estimate_1st_level();
        psc = series.get_percent_signal_change(size(realignmentParameters, 2) + 1);
        psc.name = [comparison.names{iMethod} ' right grip (% signal change)'];
        write_map(psc, workingDir, [methodId '_rightGripPSC']);
        tMap = right_grip_contrast(series, size(realignmentParameters, 2) + 1);
        write_map(tMap, workingDir, [methodId '_rightGripT']);
        pscMaps{iMethod} = psc;
        tMaps{iMethod} = tMap;
        if verbosity >= 1
            fig = psc.plot('z', slice, 'rotate90', 1, 'plotType', 'montage', ...
                'displayRange', [-5 5], 'colorMap', tapas_uniqc_viridis(256), 'colorBar', 'on');
            saveas(fig, fullfile(figuresDir, [methodId '_rightGripPSC.png']));
        end
    end
end
if verbosity >= 1
    if options.runGLM
        plot_map_grid(pscMaps, comparison.names, slice, [-5 5], ...
            'Right grip (% signal change)', fullfile(figuresDir, 'psc_comparison.png'));
        plot_map_grid(tMaps, comparison.names, slice, [-10 10], ...
            'Right grip t-score (unthresholded)', fullfile(figuresDir, 't_comparison.png'));
    end
    plot_map_grid(comparison.mean, comparison.names, slice, [], ...
        'Mean signal (evaluation window)', fullfile(figuresDir, 'mean_comparison.png'));
    plot_map_grid(comparison.tsnr, comparison.names, slice, [0 100], ...
        'Temporal SNR (evaluation window)', fullfile(figuresDir, 'tsnr_comparison.png'));
    plot_map_grid(comparison.gain, comparison.names, slice, [-100 100], ...
        'Sensitivity proxy gain vs echo 2 (%)', fullfile(figuresDir, 'gain_comparison.png'));
    fig = figure('Name', [stem ': Poser-inspired echo comparison']);
    subplot(2, 1, 1);
    bar(results.summary.MeanTSNR);
    set(gca, 'XTick', 1:numel(comparison.names), 'XTickLabel', comparison.names);
    ylabel('Mean evaluation tSNR');
    title(sprintf('%s (%g T): task-run echo comparison', stem, results.magneticFieldStrength));
    subplot(2, 1, 2);
    bar(results.roiGainPercent);
    set(gca, 'XTick', 1:numel(comparison.names), 'XTickLabel', comparison.names);
    ylabel('Sensitivity proxy gain vs echo 2 (%)');
    legend(roiNames, 'Location', 'best');
    saveas(fig, fullfile(figuresDir, 'echo_comparison.png'));
end
save(fullfile(workingDir, 'comparison_summary.mat'), 'results');
disp(results.summary);
end

function tMap = right_grip_contrast(series, betaIndex)
% Use SPM's contrast machinery, including its fitted noise model.
modelFolder = fullfile(series.glm.parameters.save.path, series.glm.parameters.save.spmDirectory);
model = load(fullfile(modelFolder, 'SPM.mat'), 'SPM');
contrast = zeros(size(model.SPM.xX.X, 2), 1);
contrast(betaIndex) = 1;
model.SPM.xCon = spm_FcUtil('Set', 'Right grip', 'T', 'c', contrast, model.SPM.xX.xKXs);
previousFolder = pwd;
restoreFolder = onCleanup(@() cd(previousFolder));
SPM = spm_contrasts(model.SPM, 1);
tMap = MrImage(SPM.xCon(1).Vspm.fname);
end

function write_map(map, folder, name)
map.parameters.save.path = folder;
map.parameters.save.fileName = [name '.nii'];
map.save();
end

function plot_map_grid(maps, names, slice, limits, label, filename)
fig = figure('Name', label, 'Position', [100 100 1200 600]);
if isempty(limits)
    % A common range preserves comparability of normalized combinations.
    maxima = cellfun(@(map) max(map.data(:)), maps);
    limits = [0 max(maxima)];
    if limits(2) <= 0, limits(2) = 1; end
end
for iMap = 1:numel(maps)
    subplot(2, ceil(numel(maps)/2), iMap);
    values = rot90(maps{iMap}.data(:,:,slice));
    imageHandle = imagesc(values, limits);
    imageHandle.AlphaData = isfinite(values);
    set(gca, 'Color', [0.15 0.15 0.15]);
    axis image off;
    title(names{iMap}, 'Interpreter', 'none');
    colorbar;
end
sgtitle(label);
saveas(fig, filename);
end
