% Script tapas_uniqc_demo_combine_multi_echo
% Minimal working example for MrImage.combine_multi_echo using simulated
% multi-echo fMRI-like data
%
%  tapas_uniqc_demo_combine_multi_echo
%
%
%   See also MrImage.combine_multi_echo

% Author:   Saskia Bollmann & Lars Kasper (supported by OpenAI Codex)
% Created:  2026-03-30
% Copyright (C) 2026 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

clear;
close all;
clc;

rng(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Create simulated 5D multi-echo data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSamples = [48, 48, 10, 90, 3]; % x, y, z, t, echoTime
TR_s = 1.2;
TE_ms = [12, 28, 44];
nEchoes = numel(TE_ms);

[X, Y, Z] = ndgrid(linspace(-1,1,nSamples(1)), ...
    linspace(-1,1,nSamples(2)), ...
    linspace(-1,1,nSamples(3)));

% Create a simple ellipsoidal brain-shaped mask and a smaller spherical
% activation region inside it that will later carry a task-like signal
brainMaskData = ((X/0.85).^2 + (Y/0.75).^2 + (Z/0.7).^2) <= 1;
activationMaskData = ((X + 0.15).^2 + (Y - 0.05).^2 + (Z).^2) <= 0.18^2;

% Simulate a smoothly varying proton-density-like baseline signal S0 and a
% spatially varying T2* map in milliseconds
S0 = 900 + 250*exp(-(X.^2 + Y.^2)/0.6) + 80*(Z + 1);
S0 = S0 .* brainMaskData;

T2star_ms = 28 + 18*exp(-(X.^2 + Y.^2 + Z.^2)/0.5) + 4*X;
T2star_ms(~brainMaskData) = 30;

% Create a simple block-design regressor and a mild linear drift across
% time to mimic a low-frequency scanner trend
t = 0:(nSamples(4)-1);
blockRegressor = zeros(1, nSamples(4));
blockRegressor(11:20) = 1;
blockRegressor(31:40) = 1;
blockRegressor(51:60) = 1;
blockRegressor(71:80) = 1;

activationAmplitude = 0.04;
drift = linspace(-0.015, 0.015, nSamples(4));

% Set echo-specific noise levels so that the different combination
% strategies have a meaningful tradeoff between signal decay and noise
noiseSigma = [35, 30, 42];

% Build the full 5D dataset by combining exponential TE-dependent signal
% decay, task-like modulation in the active region, slow drift, and
% Gaussian noise for each echo and time point
dataMatrix = zeros(nSamples);
for iEcho = 1:nEchoes
    baselineEcho = S0 .* exp(-TE_ms(iEcho)./T2star_ms);
    
    for iTime = 1:nSamples(4)
        fractionalChange = activationAmplitude * blockRegressor(iTime) .* activationMaskData;
        temporalScale = 1 + fractionalChange + drift(iTime);
        noiseVolume = noiseSigma(iEcho) * randn(nSamples(1:3));
        dataMatrix(:,:,:,iTime,iEcho) = baselineEcho .* temporalScale + noiseVolume;
    end
end

dataMatrix = max(dataMatrix, 0);

data = MrImage(dataMatrix, ...
    'dimLabels', {'x', 'y', 'z', 't', 'echoTime'}, ...
    'units', {'mm', 'mm', 'mm', 's', 'ms'}, ...
    'resolutions', [3 3 3 TR_s 1]);
data.name = 'Simulated multi-echo data';
data.dimInfo.set_dims('echoTime', 'units', 'ms', 'samplingPoints', TE_ms);

% Convert the simulated brain ellipsoid into an MrImage binary mask so the
% demo can explicitly pass imageMask without relying on segmentation
imageMask = data.mean('t').mean('echoTime').remove_dims();
imageMask.data = double(brainMaskData);
imageMask.name = 'Simulated brain mask';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Inspect raw multi-echo data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanRaw = data.mean('t');
snrRaw = data.snr('t');
zPlot = round(nSamples(3)/2);

fprintf('Simulated dataset dimensions: [%s]\n', num2str(nSamples));
fprintf('Echo times [ms]: %s\n', num2str(TE_ms));
fprintf('TR [s]: %.2f\n', TR_s);
fprintf('Mean raw signal and tSNR inside simulated brain mask:\n');

for iEcho = 1:nEchoes
    meanRawEcho = meanRaw.select('echoTime', iEcho).remove_dims();
    snrRawEcho = snrRaw.select('echoTime', iEcho).remove_dims();
    
    fprintf(['  Echo %d (TE = %.1f ms): mean signal = %.1f, ', ...
        'mean tSNR = %.1f\n'], ...
        iEcho, TE_ms(iEcho), ...
        mean(meanRawEcho.data(brainMaskData)), ...
        mean(snrRawEcho.data(brainMaskData)));
end

figure('Name', 'Raw multi-echo data');
for iEcho = 1:nEchoes
    subplot(2, nEchoes, iEcho);
    imagesc(squeeze(meanRaw.data(:,:,zPlot,iEcho)));
    axis image off;
    colorbar;
    title(sprintf('Mean, TE %.0f ms', TE_ms(iEcho)));
    
    subplot(2, nEchoes, iEcho + nEchoes);
    imagesc(squeeze(snrRaw.data(:,:,zPlot,iEcho)));
    axis image off;
    colorbar;
    title(sprintf('tSNR, TE %.0f ms', TE_ms(iEcho)));
end
colormap gray;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Combine echoes with different methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methodArray = {'ave', 'bs', 'tsnr', 'cnr', 't2star'};
methodLabelArray = {'AVE', 'BS', 'tSNR', 'CNR', 'T2star'};
nMethods = numel(methodArray);

combinedDataArray = cell(1, nMethods);
weightsArray = cell(1, nMethods);
meanCombinedArray = cell(1, nMethods);
snrCombinedArray = cell(1, nMethods);

fprintf('\nCombined data summary inside simulated brain mask:\n');
for iMethod = 1:nMethods
    [combinedDataArray{iMethod}, weightsArray{iMethod}] = ...
        data.combine_multi_echo('method', methodArray{iMethod}, ...
        'imageMask', imageMask);
    
    meanCombinedArray{iMethod} = combinedDataArray{iMethod}.mean('t');
    snrCombinedArray{iMethod} = combinedDataArray{iMethod}.snr('t');
    
    fprintf('  %s: mean signal = %.1f, mean tSNR = %.1f\n', ...
        methodLabelArray{iMethod}, ...
        mean(meanCombinedArray{iMethod}.data(brainMaskData)), ...
        mean(snrCombinedArray{iMethod}.data(brainMaskData)));
    
    fprintf('      mean weights per echo = [');
    for iEcho = 1:nEchoes
        weightEcho = weightsArray{iMethod}.select('echoTime', iEcho).remove_dims();
        fprintf('%.3f', mean(weightEcho.data(brainMaskData)));
        if iEcho < nEchoes
            fprintf(', ');
        end
    end
    fprintf(']\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Plot combined mean and tSNR maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure('Name', 'Combined multi-echo data');
for iMethod = 1:nMethods
    subplot(2, nMethods, iMethod);
    imagesc(squeeze(meanCombinedArray{iMethod}.data(:,:,zPlot)));
    axis image off;
    colorbar;
    title(sprintf('%s mean', methodLabelArray{iMethod}));
    
    subplot(2, nMethods, iMethod + nMethods);
    imagesc(squeeze(snrCombinedArray{iMethod}.data(:,:,zPlot)));
    axis image off;
    colorbar;
    title(sprintf('%s tSNR', methodLabelArray{iMethod}));
end
colormap gray;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Plot spatially averaged echo weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanWeights = zeros(nMethods, nEchoes);
for iMethod = 1:nMethods
    for iEcho = 1:nEchoes
        weightEcho = weightsArray{iMethod}.select('echoTime', iEcho).remove_dims();
        meanWeights(iMethod, iEcho) = mean(weightEcho.data(brainMaskData));
    end
end

figure('Name', 'Average echo weights');
bar(meanWeights', 'grouped');
xlabel('Echo index');
ylabel('Mean normalized weight inside brain mask');
echoTickLabels = cell(1, nEchoes);
for iEcho = 1:nEchoes
    echoTickLabels{iEcho} = sprintf('TE %.0f ms', TE_ms(iEcho));
end
set(gca, 'XTick', 1:nEchoes, 'XTickLabel', echoTickLabels);
legend(methodLabelArray, 'Location', 'best');
title('Mean echo weights for each combination method');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6. Compare activation time series in the simulated active region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timeSeriesRaw = zeros(1, nSamples(4));
timeSeriesCombined = zeros(nMethods, nSamples(4));

for iEcho = 1:3
    rawEchoForComparison = data.select('echoTime', iEcho).remove_dims();
    for iTime = 1:nSamples(4)
        currentRaw = rawEchoForComparison.select('t', iTime).remove_dims();
        timeSeriesRaw(iTime, iEcho) = mean(currentRaw.data(activationMaskData));

        for iMethod = 1:nMethods
            currentCombined = combinedDataArray{iMethod}.select('t', iTime).remove_dims();
            timeSeriesCombined(iMethod, iTime) = mean(currentCombined.data(activationMaskData));
        end
    end
end

figure('Name', 'Active-region time series');
for iEcho = 1:nEchoes
    plot(t, timeSeriesRaw(:, iEcho), 'Color', 1 - [1 1 1]/iEcho, 'LineWidth', 2);
    hold on;
end

for iMethod = 1:nMethods
    plot(t, timeSeriesCombined(iMethod,:), 'LineWidth', 1.5);
end
plot(t, min(timeSeriesRaw(:,nEchoes)) + 80*blockRegressor, 'k--', 'LineWidth', 1);
xlabel('Time point');
ylabel('Mean signal in active region');
legend([echoTickLabels, methodLabelArray, {'block Regressor'}], 'Location', 'best');
title('Simulated active-region time series before and after combination');
