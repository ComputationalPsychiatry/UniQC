function [combinedData, weights] = combine_multi_echo(this, varargin)
% Combines multi-echo data across echoes using different weighting methods
%
%   Y = MrImage()
%   [combinedData, weights] = Y.combine_multi_echo('ParameterName', ParameterValue)
%
% This is a method of class MrImage.
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%
%       method      method used for echo combination
%                   'ave', 'average', 'mean', 'sum'
%                       signal average over echoes, with w_i = 1
%                   'BS', 'BoldSensitivity', 'TE', 'EchoTime'
%                       echo-time weighting, with w_i = TE_i
%                   'tSNR', 'temporalSNR'
%                       temporal-SNR weighting, with w_i = tSNR_i
%                   'T2star', 'theoreticalCNR'
%                       theoretical CNR weighting, with
%                       w_i = TE_i*exp(-TE_i/T2star)
%                   'CNR', 'practicalCNR', 'tBS',
%                   'temporalBoldSensitivity', 'ContrastWeighted'
%                       practical CNR weighting, with w_i = tSNR_i*TE_i
%                   default: 'ave'
%
%       imageMask   defines the mask of pixels for which the echo
%                   combination should be performed; if empty, a default
%                   brain mask is computed from the mean image across
%                   echoes and time using segmentation tissue probability
%                   maps (GM + WM + CSF >= 0.5)
%                   default: []
%
% OUT
%   combinedData    combined multi-echo data
%   weights         echo weights used for the combination
%
% EXAMPLE
%   combine_multi_echo
%
%   See also MrImage combine compute_mask

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

defaults.method = 'ave';
defaults.imageMask = [];

args = tapas_uniqc_propval(varargin, defaults);
tapas_uniqc_strip_fields(args);

if isempty(this.dimInfo.get_dim_index('echoTime'))
    error('tapas:uniqc:MrImage:combine_multi_echo:MissingEchoTimeDimension', ...
        'MrImage.combine_multi_echo requires a dimension labeled ''echoTime''.');
end

iDimEcho = this.dimInfo.get_dim_index('echoTime');
iDimTime = this.dimInfo.get_dim_index('t');
hasTimeDimension = ~isempty(iDimTime);
nEchoes = this.dimInfo.nSamples(iDimEcho);

if hasTimeDimension
    meanData = this.mean('t').remove_dims('t');
else
    meanData = this.copyobj;
end

% create an echo-time image that has the same shape as the multi-echo
% meanData and stores the TE value in each voxel of the respective
% echoTime volume; in the simple 4D case with echoTime as trailing
% dimension, this is equivalent to:
%   TEImage = meanData.copyobj();
%   TEImage.data = permute(repmat(TE, [1, TEImage.dimInfo.nSamples(1:3)]), [2 3 4 1]);
% but implemented more robustly for arbitrary dimension order
TE = this.dimInfo.samplingPoints{iDimEcho};
TE = TE(:);
TEImage = meanData.copyobj();
iDimEchoMean = TEImage.dimInfo.get_dim_index('echoTime');
reshapeSize = ones(1, TEImage.dimInfo.nDims);
reshapeSize(iDimEchoMean) = nEchoes;
repSize = TEImage.dimInfo.nSamples;
repSize(iDimEchoMean) = 1;
TEImage.data = repmat(reshape(TE, reshapeSize), repSize);

if isempty(imageMask)
    anatData = meanData.mean('echoTime').remove_dims('echoTime');
    [~, tissueProbMaps] = anatData.segment();
    imageMask = tissueProbMaps{1} + tissueProbMaps{2} + tissueProbMaps{3};
    imageMask = imageMask.binarize(0.5).imfill('holes');
else
    if ~isa(imageMask, 'MrImage')
        error('tapas:uniqc:MrImage:combine_multi_echo:InvalidImageMask', ...
            'imageMask must be an MrImage object.');
    end
    
    uniqueMaskValues = unique(imageMask.data(:));
    uniqueMaskValues = uniqueMaskValues(isfinite(uniqueMaskValues));
    isBinaryMask = all(ismember(uniqueMaskValues, [0 1]));
    
    if ~isBinaryMask
        error('tapas:uniqc:MrImage:combine_multi_echo:ImageMaskNotBinary', ...
            ['imageMask must already be a binary 0/1 mask. Automatic ', ...
            'conversion of non-binary masks is not implemented yet.']);
    end
end

switch lower(method)
    case {'ave', 'average', 'mean', 'sum'}
        weights = TEImage.copyobj();
        weights.data = ones(size(weights.data));
        
    case {'bs', 'boldsensitivity', 'te', 'echotime'}
        weights = TEImage.copyobj();
        
    case {'tsnr', 'temporalsnr'}
        if ~hasTimeDimension
            error('tapas:uniqc:MrImage:combine_multi_echo:MissingTimeDimension', ...
                ['Method ''%s'' requires a dimension labeled ''t'' for ', ...
                'temporal SNR estimation.'], method);
        end
        weights = this.snr('t').remove_dims('t');
        
    case {'cnr', 'practicalcnr', 'tbs', 'temporalboldsensitivity', 'contrastweighted'}
        if ~hasTimeDimension
            error('tapas:uniqc:MrImage:combine_multi_echo:MissingTimeDimension', ...
                ['Method ''%s'' requires a dimension labeled ''t'' for ', ...
                'temporal SNR estimation.'], method);
        end
        weights = this.snr('t').remove_dims('t') .* TEImage;
        
    case {'t2star', 'theoreticalcnr'}
        if ~hasTimeDimension
            error('tapas:uniqc:MrImage:combine_multi_echo:MissingTimeDimension', ...
                ['Method ''%s'' requires a dimension labeled ''t'' for ', ...
                'T2* estimation from the mean multi-echo time series.'], method);
        end
        
        [T2Starmap, ~] = meanData.log_linear_fit('echoTime');
        T2Starmap = T2Starmap .* imageMask;
        T2Starmap.data(~isfinite(T2Starmap.data)) = 0;
        
        weightsCell = cell(nEchoes, 1);
        for iEcho = 1:nEchoes
            currentTEImage = TEImage.select('echoTime', iEcho);
            weightsCell{iEcho} = currentTEImage .* ...
                exp(currentTEImage .* (-1) ./ T2Starmap);
            if iEcho == 1
                denominator = weightsCell{iEcho}.copyobj();
            else
                denominator = denominator + weightsCell{iEcho};
            end
        end
        weights = weightsCell{1}.combine(weightsCell);
        denominator.data(~isfinite(denominator.data) | denominator.data == 0) = Inf;
        weights = weights ./ denominator;
        
    otherwise
        error('tapas:uniqc:MrImage:combine_multi_echo:UnknownMethod', ...
            'Unknown multi-echo combination method ''%s''.', method);
end

weights = weights .* imageMask;
weights.data(~isfinite(weights.data)) = 0;

if ~strcmpi(method, 't2star') && ~strcmpi(method, 'theoreticalcnr')
    denominator = weights.sum('echoTime');
    denominator.data(~isfinite(denominator.data) | denominator.data == 0) = Inf;
    weights = weights ./ denominator;
end

% for time series data, move echoTime next to the trailing time dimension
% so the echo-wise weights can be implicitly expanded across time during
% multiplication; for data without a time dimension, direct multiplication
% with the echo-wise weights is sufficient
if hasTimeDimension
    dimOrder = 1:this.dimInfo.nDims;
    dimOrder(dimOrder == iDimEcho) = [];
    dimOrder(dimOrder == iDimTime) = [];
    dimOrder = [dimOrder iDimEcho iDimTime];
    weightedData = this.permute(dimOrder) .* weights;
else
    weightedData = this .* weights;
end

combinedData = weightedData.sum('echoTime').remove_dims();
combinedData.name = sprintf('%s (%s combined)', this.name, method);
weights.name = sprintf('weights_%s', method);
