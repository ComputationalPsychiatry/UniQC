function dataNdCombined = combine(this, dataNdArray, combineDims, tolerance)
% combines multiple n-dim. datasets into a single one along specified
% dimensions. Makes sure data is sorted into right place according to
% different dimInfos
% 
% NOTE: inverse operation of MrDataNd.split
%
%   Y = MrDataNd()
%   dataNdCombined = Y.combine(dataNdArray, combineDims)
%
% This is a method of class MrDataNd.
%
% IN
%   dataNdArray     cell of MrDataNd to be combined
%   combineDims     [1, nCombineDims] vector of dim indices to be combined
%                       OR
%                   cell(1, nCombineDims) of dimLabels to be combined
%
%   tolerance                   dimInfos are only combined, if their
%                               information is equal for all but the
%                               combineDims (because only one
%                               representation is retained for those,
%                               usually from the first of the dimInfos). 
%                               However, sometimes numerical precision,
%                               e.g., rounding errors, preclude the
%                               combination. Then you can increase this
%                               tolerance; 
%                               default: single precision (eps('single')
%                               ~1.2e-7)
% OUT
%
% EXAMPLE
%   combine
%
%   See also MrDataNd MrDimInfo.combine MrDataNd.split

% Author:   Lars Kasper
% Created:  2018-05-16
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 4
    tolerance = eps('single');
end

%% 1) dimInfoCombined = Y.combine(dimInfoArray, combineDims)
doCombineSingletonDims = nargin < 3; 
if doCombineSingletonDims
    indSplitDims = this.dimInfo.get_singleton_dimensions();
    combineDims = this.dimInfo.dimLabels(indSplitDims);
else
    % for 1-dim case, make cell
    if ~iscell(combineDims) && isstr(combineDims)
        combineDims = {combineDims};
    end
end

dimInfoArray = cellfun(@(x) x.dimInfo, dataNdArray, 'UniformOutput', false);
[dimInfoCombined, indSamplingPointCombined] = this.dimInfo.combine(...
    dimInfoArray, combineDims, tolerance);

%% Loop over all splits dataNd and put data into right place, as defined by combined DimInfo
% dimInfo sampling points
indSplitDims        = this.dimInfo.get_dim_index(combineDims);
nSplits             = numel(dataNdArray);
dataMatrixCombined  = nan(dimInfoCombined.nSamples);
for iSplit = 1:nSplits
    % write out indices to be filled in final array, e.g. tempData(:,:,sli, dyn)
    % would be {':', ':', sli, dyn}
    index = repmat({':'}, 1, dimInfoCombined.nDims);
    index(indSplitDims) = num2cell(indSamplingPointCombined(iSplit,:));
    dataMatrixCombined(index{:}) = dataNdArray{iSplit}.data;
end


%% assemble the output object
dataNdCombined = this.copyobj();
dataNdCombined.dimInfo = dimInfoCombined;
dataNdCombined.data = dataMatrixCombined;