function [output_slope, output_intercept] = log_linear_fit(this, applicationDimension, varargin)
% Computes a log linear fit along the applicationDimensios for example to
% estimate T2* values for multi-echo data.
%
%   Y = MrDataNd()
%   Y.log_linear_fit('TE')
%   Y.log_linear_fit('TE', 'imageThreshold', 10, 'valueRange', [1 5000])
%
% This is a method of class MrDataNd.
%
% IN
%   applicationDimension    image dimension along which operation is
%                           performed (e.g. 4 = time, 3 = slices)
%                           default: The last dimension with more than one
%                           value is chosen 
%                           (i.e. 3 for 3D image, 4 for 4D image)
%   varargin
%               extra parameters, to restrict the fit to more sensible values
%               ('imageThreshold', 10, 'valueRange', [1 5000])

%                   imageThreshold - minimum intensity in the mean image 
%                                  across the application dimension for
%                                  which the fit will be performed
%                                  default: 10
%                   valueRange     - [min max] values to which the
%                                  estimates will be restricted
%                                  default: [1 5000]
%
% OUT
%
% EXAMPLE
%   log_linear_fit
%
%   See also MrDataNd
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2025-05-26
% Copyright (C) 2025 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 2
    applicationDimension = this.dimInfo.nDims;
else
    applicationDimension = this.dimInfo.convert_application_dimensions(...
        applicationDimension);
end

defaults.imageThreshold = 10;
defaults.valueRange = [1 5000]; % ms

args = tapas_uniqc_propval(varargin, defaults);
tapas_uniqc_strip_fields(args);

% extract sampling points for fit
samplingPoints = this.dimInfo.samplingPoints{applicationDimension};

% Ensure samplingPoints are a column vector
samplingPoints = samplingPoints(:);
nSamplingPoints = length(samplingPoints);

% number of voxels
ISize = this.dimInfo.nSamples;
spatialSize = ISize(1:end-1);
nVoxels = prod(spatialSize);

% Reshape to [samplingPoints x nVoxels]
S_reshaped = reshape(this.data, [nVoxels, nSamplingPoints])';  % [nSamplingPoints x nVoxels]

% Compute masks
isPositive = all(S_reshaped > 0, 1);
meanSignal = mean(S_reshaped, 1);
goodSignal = meanSignal > imageThreshold;
validMask = isPositive & goodSignal;

% Log-transform only valid voxels
logS = zeros(size(S_reshaped));
logS(:, validMask) = log(S_reshaped(:, validMask));

% Design matrix
X = [ones(nSamplingPoints, 1), samplingPoints];
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
slopeMap = NaN(nVoxels, 1);
interceptMap = NaN(nVoxels, 1);

% Compute intercept (S0) and slope (T1, T2 or T2*)
slope_valid = -1 ./ slope_valid(decayMask);
intercept_valid = exp(lnS0_valid(decayMask));

% Clamp T2 to valid physiological range
slope_valid(slope_valid < valueRange(1) | slope_valid > valueRange(2)) = NaN;

% Assign to map
slopeMap(keepIdx) = slope_valid;
interceptMap(keepIdx) = intercept_valid;

% Reshape to original dimensions
slopeMapData = reshape(slopeMap, spatialSize);
InterceptMapData = reshape(interceptMap, spatialSize);

% recast as MrImages
output_slope = this.copyobj();
output_slope = output_slope.remove_dims('echoTime');
output_slope.data = slopeMapData;
output_slope.name = 'Estimated relaxation times';

output_intercept = meanRData.copyobj();
output_intercept = output_intercept.remove_dims('echoTime');
output_intercept.data = InterceptMapData;
output_intercept.name = 'Estimated itensity values at t=0';
