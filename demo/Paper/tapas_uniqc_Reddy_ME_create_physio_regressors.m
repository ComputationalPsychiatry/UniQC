function [regRight, regLeft, regCO2] = tapas_uniqc_Reddy_ME_create_physio_regressors( ...
    dataPath, subID, run, repetitionTime, nVolumes, showPlots, regressorSource)
% Creates physiological regressors for the Reddy multi-echo example
%
% The physiology traces are read from the Reddy et al. OpenNeuro dataset.
% Grip force is normalized, end-tidal CO2 is interpolated from detected
% peaks, and all traces are convolved with the canonical SPM HRF. The
% regressors are normalized, demeaned, resampled to the MR repetition time,
% and trimmed to match the ten initial volumes discarded by the demo.
%
% IN
%   dataPath        root folder of the OpenNeuro ds004662 dataset
%   subID           BIDS subject identifier without the "sub-" prefix
%   run             BIDS run identifier
%   repetitionTime  MR repetition time in seconds
%   nVolumes        number of retained MR volumes
%   showPlots       whether to display diagnostic physiology plots
%   regressorSource 'recomputed' creates regressors from the raw physiology;
%                   'downloaded' loads the published OpenNeuro derivatives
%
% OUT
%   regRight        right-hand grip regressor
%   regLeft         left-hand grip regressor
%   regCO2          end-tidal CO2 regressor
%
% EXAMPLE
%   [regRight, regLeft, regCO2] = ...
%       tapas_uniqc_Reddy_ME_create_physio_regressors( ...
%       dataPath, '03', '1', 2, 200, false, 'downloaded');
%
%   See also tapas_uniqc_Reddy_ME_example_func spm_hrf

% Author:   Lars Kasper
% Created:  2026-08-10
% Copyright (C) 2026 University of Toronto
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 7
    regressorSource = 'recomputed';
end

switch lower(regressorSource)
    case 'downloaded'
        [regRight, regLeft, regCO2] = load_downloaded_regressors( ...
            dataPath, subID, run, nVolumes);
        if showPlots
            nDiscardedVolumes = 10;
            tMR = (nDiscardedVolumes:nDiscardedVolumes+nVolumes-1) * ...
                repetitionTime;
            figure;
            plot(tMR, regCO2);
            hold on;
            plot(tMR, regRight);
            plot(tMR, regLeft);
            legend({'published CO2', 'published handgrip right', ...
                'published handgrip left'});
        end
        return
    case 'recomputed'
        % Continue below and derive the regressors from the raw physiology.
    otherwise
        error('tapas:uniqc:ReddyME:UnknownRegressorSource', ...
            'Unknown regressor source "%s". Use recomputed or downloaded.', ...
            regressorSource);
end

physFilenameTsv = fullfile(dataPath, ['sub-', subID], 'func', ...
    ['sub-', subID, '_task-handgrasp_run-', run, '_physio.tsv']);
physFilenameGz = [physFilenameTsv, '.gz'];

% Temporarily unzip the physiology file if necessary.
if ~isfile(physFilenameTsv) && isfile(physFilenameGz)
    fprintf('Unzipping physio file: %s\n', physFilenameGz);
    gunzip(physFilenameGz);
    cleanupObj = onCleanup(@() delete(physFilenameTsv));
end

physRaw = readtable(physFilenameTsv, ...
    "FileType", "text", 'Delimiter', '\t');
physRaw = renamevars(physRaw, ...
    ["Var1", "Var2", "Var3", "Var4"], ...
    ["trigger", "CO2", "right", "left"]);

samplingFrequency = 20; % Hz, sampling frequency from JSON sidecar
tPhys = (0:height(physRaw)-1)/samplingFrequency;
if showPlots
    figure;
    plot(tPhys, physRaw.CO2);
    hold on;
    plot(tPhys, physRaw.right);
    plot(tPhys, physRaw.left);
    legend({'CO2', 'handgrip right', 'handgrip left'});
end

% Interpolate end-tidal CO2 from detected expiratory peaks.
minPeakDistanceSamples = round(2*samplingFrequency);
minPeakProminence = 0.05 * range(physRaw.CO2);
[endTidalPeaks, endTidalLocs] = findpeaks(physRaw.CO2, ...
    'MinPeakDistance', minPeakDistanceSamples, ...
    'MinPeakProminence', minPeakProminence);
if numel(endTidalPeaks) < 2
    error('tapas:uniqc:ReddyME:FewerThanTwoEndTidalPeaks', ...
        'Detected fewer than two end-tidal CO2 peaks. Please inspect the CO2 trace.');
end

% A partial breath at the acquisition boundary can be mistaken for the
% first end-tidal peak. Reject it when it differs by more than 20 percent
% from the median of the next five peaks, approximating the manual peak
% inspection described by Reddy et al.
nReferencePeaks = min(5, numel(endTidalPeaks)-1);
initialPeakReference = median(endTidalPeaks(2:nReferencePeaks+1));
relativeInitialPeakDeviation = abs( ...
    endTidalPeaks(1) - initialPeakReference) / initialPeakReference;
if relativeInitialPeakDeviation > 0.2
    fprintf(['Discarding initial CO2 peak at %.2f s (%.2f mmHg) as an ' ...
        'acquisition-boundary outlier.\n'], ...
        tPhys(endTidalLocs(1)), endTidalPeaks(1));
    endTidalPeaks(1) = [];
    endTidalLocs(1) = [];
end
fprintf('Detected %d end-tidal CO2 peaks.\n', numel(endTidalPeaks));
tEndTidal = tPhys(endTidalLocs);
if showPlots
    figure;
    plot(tPhys, physRaw.CO2);
    hold on;
    plot(tEndTidal, endTidalPeaks, 'rv', 'MarkerFaceColor', 'r');
    legend({'CO2', 'detected end-tidal peaks'});
end
interpPeakTimes = [tPhys(1); tEndTidal(:); tPhys(end)];
interpPeakValues = [endTidalPeaks(1); endTidalPeaks(:); endTidalPeaks(end)];
endTidalCO2 = interp1(interpPeakTimes, interpPeakValues, tPhys, 'pchip');
if showPlots
    figure;
    plot(tPhys, physRaw.CO2);
    hold on;
    plot(tPhys, endTidalCO2);
    legend({'raw CO2', 'interpolated end-tidal CO2'});
end

% Normalize grip force and convolve all physiology traces with the SPM HRF.
normRight = normalize_to_unit_range(physRaw.right);
normLeft = normalize_to_unit_range(physRaw.left);
hrf = spm_hrf(1/samplingFrequency);

% Prevent the nonzero CO2 baseline from being convolved with an implicit
% zero before acquisition. The resulting HRF startup transient would extend
% beyond the ten discarded volumes and distort subsequent range scaling.
nPaddingSamples = numel(hrf)-1;
paddedCO2 = [repmat(endTidalCO2(1), 1, nPaddingSamples), endTidalCO2];
convolvedCO2 = conv(paddedCO2, hrf);
convolvedCO2 = convolvedCO2(numel(hrf):numel(hrf)+numel(tPhys)-1);
convolvedRight = trim_convolution(conv(normRight, hrf), numel(tPhys));
convolvedLeft = trim_convolution(conv(normLeft, hrf), numel(tPhys));
if showPlots
    tHrf = (0:numel(hrf)-1)/samplingFrequency;
    figure;
    plot(tHrf, hrf);
    legend('HRF');
end

scaledCO2 = normalize_to_unit_range(convolvedCO2) * range(endTidalCO2) + ...
    min(endTidalCO2);
demeanedCO2 = scaledCO2 - mean(scaledCO2);
demeanedRight = normalize_to_unit_range(convolvedRight);
demeanedRight = demeanedRight - mean(demeanedRight);
demeanedLeft = normalize_to_unit_range(convolvedLeft);
demeanedLeft = demeanedLeft - mean(demeanedLeft);
if showPlots
    figure;
    plot(tPhys, endTidalCO2);
    hold on;
    plot(tPhys, scaledCO2);
    legend({'interpolated end-tidal CO2', ...
        'HRF-convolved and rescaled CO2'});
    figure;
    plot(tPhys, demeanedRight);
    hold on;
    plot(tPhys, demeanedLeft);
    legend({'demeaned handgrip right', 'demeaned handgrip left'});
end

% Resample to the MR acquisition times and discard the first ten volumes.
nDiscardedVolumes = 10;
tMR = (0:nVolumes+nDiscardedVolumes-1) * repetitionTime;
regCO2 = interp1(tPhys, demeanedCO2, tMR);
regRight = interp1(tPhys, demeanedRight, tMR);
regLeft = interp1(tPhys, demeanedLeft, tMR);
regCO2 = regCO2(nDiscardedVolumes+1:end);
regRight = regRight(nDiscardedVolumes+1:end);
regLeft = regLeft(nDiscardedVolumes+1:end);
if showPlots
    tMR = tMR(nDiscardedVolumes+1:end);
    figure;
    plot(tMR, regCO2);
    hold on;
    plot(tMR, regRight);
    plot(tMR, regLeft);
    legend({'resampled CO2', 'resampled handgrip right', ...
        'resampled handgrip left'});
end
end

function normalizedTrace = normalize_to_unit_range(trace)
normalizedTrace = (trace - min(trace)) / range(trace);
end

function trimmedTrace = trim_convolution(convolvedTrace, nSamples)
trimmedTrace = convolvedTrace(1:nSamples);
end

function [regRight, regLeft, regCO2] = load_downloaded_regressors( ...
    dataPath, subID, run, nVolumes)
subject = ['sub-', subID];
filenameStem = [subject, '_task-handgrasp_run-', run, '_desc-'];
regressorRoot = fullfile(dataPath, 'derivatives');
filenames = {
    fullfile(regressorRoot, 'handgrasp_regressors', subject, ...
    [filenameStem, 'righthandgrasp_regressor.txt'])
    fullfile(regressorRoot, 'handgrasp_regressors', subject, ...
    [filenameStem, 'lefthandgrasp_regressor.txt'])
    fullfile(regressorRoot, 'CO2_regressors', subject, ...
    [filenameStem, 'CO2_regressor.txt'])
    };

regRight = readmatrix(filenames{1});
regLeft = readmatrix(filenames{2});
regCO2 = readmatrix(filenames{3});
regRight = regRight(:).';
regLeft = regLeft(:).';
regCO2 = regCO2(:).';

if any([numel(regRight), numel(regLeft), numel(regCO2)] ~= nVolumes)
    error('tapas:uniqc:ReddyME:RegressorLengthMismatch', ...
        ['Published regressors must each contain %d values to match the ' ...
        'retained fMRI volumes.'], nVolumes);
end
end
