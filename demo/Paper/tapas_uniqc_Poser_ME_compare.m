function comparison = tapas_uniqc_Poser_ME_compare(data, mask, weightVolumes, evaluationVolumes)
% Compare individual echoes, equal, T2* and practical CNR weights.
% data is a realigned MrImage with x,y,z,t,echoTime dimensions (TE in ms).
% mask is a binary spatial MrImage. Volume indices refer to retained data.
% Estimate weights on weightVolumes and evaluate on evaluationVolumes.
% Returns maps and a common-valid-voxel summary; does not plot or write.
% The legacy sensitivity proxy is tSNR * sum(w .* TE), not task CNR.
% See POSER_ME_EXAMPLE.md for assumptions and limitations.
%
% Copyright (C) 2026 UniQC developers. GNU GPL version 3 or later.

if ~isequal(data.dimInfo.dimLabels, {'x','y','z','t','echoTime'})
    error('uniqc:Poser:DimensionOrder', 'Expected dimensions x,y,z,t,echoTime.');
end
nVolumes = data.dimInfo.nSamples('t');
validateattributes(weightVolumes, {'numeric'}, ...
    {'vector', 'integer', 'positive', '<=', nVolumes, 'numel', numel(unique(weightVolumes))});
validateattributes(evaluationVolumes, {'numeric'}, ...
    {'vector', 'integer', 'positive', '<=', nVolumes, 'numel', numel(unique(evaluationVolumes))});
if numel(weightVolumes) < 3 || numel(evaluationVolumes) < 3
    error('uniqc:Poser:TooFewVolumes', 'Use at least three volumes per window.');
end
if ~isempty(intersect(weightVolumes, evaluationVolumes))
    error('uniqc:Poser:OverlappingWindows', 'Weight and evaluation windows must be disjoint.');
end
TE = data.dimInfo.samplingPoints{'echoTime'};
nEchoes = numel(TE);
if nEchoes < 2
    error('uniqc:Poser:MissingEchoes', 'At least two echoes are required.');
end
validateattributes(TE, {'numeric'}, {'vector', 'finite', 'positive', 'increasing'});
training = data.select('t', weightVolumes);
evaluation = data.select('t', evaluationVolumes);
comparison.names = [arrayfun(@(e) sprintf('Echo %d (%.1f ms)', e, TE(e)), ...
    1:nEchoes, 'UniformOutput', false), {'Equal', 'T2star', 'CNR'}];
comparison.methods = [repmat({'select'}, 1, nEchoes), {'ave', 'T2star', 'CNR'}];
comparison.weights = cell(1, nEchoes + 3);
comparison.tsnr = cell(1, nEchoes + 3);
comparison.sensitivity = cell(1, nEchoes + 3);
comparison.mean = cell(1, nEchoes + 3);
teImage = training.mean('t').remove_dims('t');
teShape = ones(1, teImage.dimInfo.nDims);
teShape(teImage.dimInfo.get_dim_index('echoTime')) = nEchoes;
teImage.data = ones(size(teImage.data)) .* reshape(TE, teShape);
% Explicit dimension ordering matches combine_multi_echo's broadcasting.
ordered = evaluation.permute([1 2 3 5 4]);
valid = logical(mask.data);
for iMethod = 1:numel(comparison.names)
    args = {'method', comparison.methods{iMethod}, 'imageMask', mask};
    if iMethod <= nEchoes, args = [args, {'echoTime', iMethod}]; end %#ok<AGROW>
    [~, weights] = training.combine_multi_echo(args{:});
    combined = ordered .* weights;
    combined = combined.sum('echoTime').remove_dims();
    comparison.weights{iMethod} = weights;
    comparison.mean{iMethod} = combined.mean('t').remove_dims('t');
    comparison.tsnr{iMethod} = combined.snr('t').remove_dims('t');
    effectiveTE = weights .* teImage;
    effectiveTE = effectiveTE.sum('echoTime').remove_dims();
    comparison.sensitivity{iMethod} = comparison.tsnr{iMethod} .* effectiveTE;
    valid = valid & isfinite(comparison.tsnr{iMethod}.data) & ...
        isfinite(comparison.sensitivity{iMethod}.data) & ...
        comparison.sensitivity{iMethod}.data > 0;
end
if ~any(valid(:))
    error('uniqc:Poser:EmptyMask', 'No valid comparison voxels in the supplied mask.');
end
comparison.validMask = mask.copyobj();
comparison.validMask.data = double(valid);
comparison.echoTimesMs = TE;
comparison.weightVolumes = weightVolumes;
comparison.evaluationVolumes = evaluationVolumes;
comparison.referenceEcho = 2;
reference = comparison.sensitivity{2}.data;
nMethods = numel(comparison.names);
meanTSNR = zeros(nMethods, 1);
meanSensitivity = zeros(nMethods, 1);
meanGainPercent = zeros(nMethods, 1);
comparison.gain = cell(1, nMethods);
for iMethod = 1:nMethods
    snrData = comparison.tsnr{iMethod}.data;
    sensitivityData = comparison.sensitivity{iMethod}.data;
    meanTSNR(iMethod) = mean(snrData(valid));
    meanSensitivity(iMethod) = mean(sensitivityData(valid));
    gain = comparison.sensitivity{iMethod}.copyobj();
    gain.data = nan(size(reference));
    gain.data(valid) = 100 * (sensitivityData(valid) ./ reference(valid) - 1);
    comparison.gain{iMethod} = gain;
    meanGainPercent(iMethod) = mean(gain.data(valid));
end
comparison.summary = table(comparison.names(:), meanTSNR, meanSensitivity, ...
    meanGainPercent, repmat(nnz(valid), nMethods, 1), 'VariableNames', ...
    {'Method', 'MeanTSNR', 'MeanSensitivityProxyMs', 'MeanGainPercentVsEcho2', 'VoxelCount'});
end
