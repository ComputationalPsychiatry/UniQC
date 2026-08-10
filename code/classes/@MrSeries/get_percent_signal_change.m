function percentSignalChange = get_percent_signal_change(this, idxRegressor)
% Returns an SPM beta image scaled to percent signal change
%
%   percentSignalChange = get_percent_signal_change(this, idxRegressor)
%
% This is a method of class MrSeries.
%
% IN
%   idxRegressor    positive integer index of the regressor in SPM.Vbeta
%
% OUT
%   percentSignalChange
%                   MrImage containing the beta scaled voxel-wise by the
%                   temporal mean of the input series:
%                       100 * beta / temporal mean
%
% AFNI scales each voxel time series to a temporal mean of 100 before
% regression. Since the SPM GLM is linear, scaling the fitted beta by the
% temporal mean afterwards gives the equivalent percent-signal-change map.
%
% EXAMPLE
%   percentSignalChange = series.get_percent_signal_change(7);
%
%   See also MrSeries MrImage MrGlm

% Author:   Lars Kasper
% Created:  2026-07-27
% Copyright (C) 2026 University of Toronto
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 2 || ~isnumeric(idxRegressor) || ~isscalar(idxRegressor) || ...
        ~isfinite(idxRegressor) || idxRegressor < 1 || ...
        idxRegressor ~= round(idxRegressor)
    error('tapas:uniqc:MrSeries:InvalidRegressorIndex', ...
        'idxRegressor must be a positive integer scalar.');
end

spmDirectory = fullfile(this.glm.parameters.save.path, ...
    this.glm.parameters.save.spmDirectory);
spmModelFile = fullfile(spmDirectory, 'SPM.mat');
if ~isfile(spmModelFile)
    error('tapas:uniqc:MrSeries:MissingSpmModel', ...
        'Could not find the fitted SPM model: %s', spmModelFile);
end

spmContents = load(spmModelFile, 'SPM');
if ~isfield(spmContents, 'SPM') || ...
        ~isfield(spmContents.SPM, 'Vbeta') || ...
        idxRegressor > numel(spmContents.SPM.Vbeta)
    error('tapas:uniqc:MrSeries:MissingRegressorBeta', ...
        'The SPM model does not contain beta image %d.', idxRegressor);
end

% SPM scales each session to a grand mean of 100 before fitting the GLM.
% Apply its single session factor to the raw temporal mean so that it has
% the same units as the beta; reject models that require multiple factors.
SPM = spmContents.SPM;
globalScalingFactors = SPM.xGX.gSF(:);
if ~strcmpi(SPM.xGX.iGXcalc, 'none') || ...
        ~strcmpi(SPM.xGX.sGMsca, 'session specific') || ...
        any(globalScalingFactors ~= globalScalingFactors(1))
    error('tapas:uniqc:MrSeries:UnsupportedSpmGlobalScaling', ...
        ['Percent signal change currently requires global normalization ', ...
        '''none'' and one common session-specific SPM.xGX.gSF factor.']);
end
globalScalingFactor = globalScalingFactors(1);

betaFilename = spmContents.SPM.Vbeta(idxRegressor).fname;
if ~isfile(betaFilename)
    betaFilename = fullfile(spmDirectory, betaFilename);
end
if ~isfile(betaFilename)
    error('tapas:uniqc:MrSeries:MissingBetaFile', ...
        'Could not find beta image %d: %s', idxRegressor, betaFilename);
end

beta = MrImage(betaFilename);
temporalMean = this.data.mean('t').remove_dims('t');
temporalMean = temporalMean * globalScalingFactor;
isValidVoxel = isfinite(temporalMean.data) & temporalMean.data > 0 & ...
    isfinite(beta.data);

explicitMask = this.glm.explicitMasking;
if ~isempty(explicitMask)
    if isa(explicitMask, 'MrImage')
        mask = explicitMask;
    elseif ischar(explicitMask) || ...
            (isstring(explicitMask) && isscalar(explicitMask))
        mask = MrImage(char(explicitMask));
    else
        error('tapas:uniqc:MrSeries:InvalidExplicitMask', ...
            ['glm.explicitMasking must be empty, a mask filename, or an ', ...
            'MrImage.']);
    end
    isValidVoxel = isValidVoxel & isfinite(mask.data) & mask.data ~= 0;
end

percentSignalChange = beta.copyobj();
percentSignalChange.data = zeros(size(beta.data));
percentSignalChange.data(isValidVoxel) = ...
    100 * beta.data(isValidVoxel) ./ temporalMean.data(isValidVoxel);
percentSignalChange.name = sprintf( ...
    'Regressor %d (%% signal change)', idxRegressor);
