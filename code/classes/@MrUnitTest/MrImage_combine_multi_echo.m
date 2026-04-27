function this = MrImage_combine_multi_echo(this, testCondition)
% Unit test for MrImage combine_multi_echo method
%
%   Y = MrUnitTest()
%   run(Y, 'MrImage_combine_multi_echo')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrImage_combine_multi_echo
%
%   See also MrUnitTest MrImage.combine_multi_echo

% Author:   Saskia Bollmann & Lars Kasper (supported by OpenAI Codex)
% Created:  2026-04-15
% Copyright (C) 2026 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

rng('default');

nSamples = [4, 3, 2, 6, 3]; % x, y, z, t, echoTime
TE_ms = [10, 30, 50];
nEchoes = numel(TE_ms);

dataMatrix = zeros(nSamples);
temporalFluctuation = reshape([0, 1, -1, 0.5, -0.5, 0], [1 1 1 nSamples(4)]);
noiseScale = [1, 2, 4];
for iEcho = 1:nEchoes
    echoBaseline = 100 * exp(-TE_ms(iEcho)/40);
    dataMatrix(:,:,:,:,iEcho) = echoBaseline + ...
        noiseScale(iEcho) * repmat(temporalFluctuation, nSamples(1:3));
end

multiEchoImage = MrImage(dataMatrix, ...
    'dimLabels', {'x', 'y', 'z', 't', 'echoTime'}, ...
    'units', {'mm', 'mm', 'mm', 's', 'ms'}, ...
    'resolutions', [2 2 2 1 1]);
multiEchoImage.dimInfo.set_dims('echoTime', 'units', 'ms', ...
    'samplingPoints', TE_ms);

imageMask = multiEchoImage.mean('t').mean('echoTime').remove_dims();
imageMask.data = ones(size(imageMask.data));

switch testCondition
    case 'average'
        % Average weighting should produce equal weights and the arithmetic mean
        [combinedData, weights] = multiEchoImage.combine_multi_echo( ...
            'method', 'average', 'imageMask', imageMask);
        
        expWeights = ones(size(weights.data))/nEchoes;
        expData = mean(dataMatrix, 5);
        
        this.verifyEqual(weights.data, expWeights, 'absTol', 10e-7);
        this.verifyEqual(combinedData.data, expData, 'absTol', 10e-7);
        
    case 'te'
        % TE weighting should match normalized TE values and increase with TE
        [~, weights] = multiEchoImage.combine_multi_echo( ...
            'method', 'TE', 'imageMask', imageMask);
        
        expWeights = reshape(TE_ms/sum(TE_ms), [1 1 1 nEchoes]);
        expWeights = repmat(expWeights, nSamples([1 2 3 5])./[1 1 1 nEchoes]);
        
        this.verifyEqual(weights.data, expWeights, 'absTol', 10e-7);
        this.verifyGreaterThan(mean(weights.select('echoTime', 2).data(:)), ...
            mean(weights.select('echoTime', 1).data(:)));
        this.verifyGreaterThan(mean(weights.select('echoTime', 3).data(:)), ...
            mean(weights.select('echoTime', 2).data(:)));
        
    case 'tsnr'
        % tSNR weighting should favor echoes with lower temporal variance
        [~, weights] = multiEchoImage.combine_multi_echo( ...
            'method', 'tSNR', 'imageMask', imageMask);
        
        this.verifyGreaterThan(mean(weights.select('echoTime', 1).data(:)), ...
            mean(weights.select('echoTime', 2).data(:)));
        this.verifyGreaterThan(mean(weights.select('echoTime', 2).data(:)), ...
            mean(weights.select('echoTime', 3).data(:)));
        this.verifyEqual(squeeze(weights.sum('echoTime').data), ...
            ones(nSamples(1:3)), 'absTol', 10e-7);
        
    case 't2star'
        % T2*-based weights should be finite and normalized across echoes
        [~, weights] = multiEchoImage.combine_multi_echo( ...
            'method', 'T2star', 'imageMask', imageMask);
        
        this.verifyFalse(any(isnan(weights.data(:))));
        this.verifyFalse(any(isinf(weights.data(:))));
        this.verifyEqual(squeeze(weights.sum('echoTime').data), ...
            ones(nSamples(1:3)), 'absTol', 10e-7);
        
    case 'singleEcho'
        % A single echo should have weight one and return the original time series
        singleEchoDataMatrix = permute(dataMatrix(:,:,:,:,2), [1 2 3 5 4]);
        singleEchoImage = MrImage(singleEchoDataMatrix, ...
            'dimLabels', {'x', 'y', 'z', 'echoTime', 't'}, ...
            'units', {'mm', 'mm', 'mm', 'ms', 's'}, ...
            'resolutions', [2 2 2 1 1]);
        singleEchoImage.dimInfo.set_dims('echoTime', 'units', 'ms', ...
            'samplingPoints', TE_ms(2));
        
        singleEchoMask = singleEchoImage.mean('t').mean('echoTime').remove_dims();
        singleEchoMask.data = ones(size(singleEchoMask.data));
        
        [combinedData, weights] = singleEchoImage.combine_multi_echo( ...
            'method', 'tSNR', 'imageMask', singleEchoMask);
        
        expWeights = ones(size(weights.data));
        expData = dataMatrix(:,:,:,:,2);
        
        this.verifyEqual(weights.data, expWeights, 'absTol', 10e-7);
        this.verifyEqual(combinedData.data, expData, 'absTol', 10e-7);
        
    case 'constantTimeSeries'
        % Constant time series have zero variance; tSNR fallback should
        % reduce to equal weights and hence to the arithmetic mean
        constantDataMatrix = repmat(reshape([100, 80, 60], [1 1 1 1 nEchoes]), ...
            nSamples([1 2 3 4 5])./[1 1 1 1 nEchoes]);
        constantImage = MrImage(constantDataMatrix, ...
            'dimLabels', {'x', 'y', 'z', 't', 'echoTime'}, ...
            'units', {'mm', 'mm', 'mm', 's', 'ms'}, ...
            'resolutions', [2 2 2 1 1]);
        constantImage.dimInfo.set_dims('echoTime', 'units', 'ms', ...
            'samplingPoints', TE_ms);
        
        constantMask = constantImage.mean('t').mean('echoTime').remove_dims();
        constantMask.data = ones(size(constantMask.data));
        
        [combinedData, weights] = constantImage.combine_multi_echo( ...
            'method', 'tSNR', 'imageMask', constantMask);
        
        expWeights = ones(size(weights.data))/nEchoes;
        expData = mean(constantDataMatrix, 5);
        
        this.verifyEqual(weights.data, expWeights, 'absTol', 10e-7);
        this.verifyEqual(combinedData.data, expData, 'absTol', 10e-7);
        
    case 'invalidMask'
        % Non-binary masks should fail with a clear identifier
        imageMask.data(1) = 0.5;
        this.verifyError(@() multiEchoImage.combine_multi_echo( ...
            'method', 'average', 'imageMask', imageMask), ...
            'tapas:uniqc:MrImage:combine_multi_echo:ImageMaskNotBinary');
        
    case 'missingEchoTime'
        % Missing echoTime dimension should fail with a clear identifier
        imageWithoutEchoTime = MrImage(rand(nSamples(1:4)), ...
            'dimLabels', {'x', 'y', 'z', 't'});
        this.verifyError(@() imageWithoutEchoTime.combine_multi_echo( ...
            'imageMask', imageWithoutEchoTime.mean('t').remove_dims()), ...
            'tapas:uniqc:MrImage:combine_multi_echo:MissingEchoTimeDimension');
end

end
