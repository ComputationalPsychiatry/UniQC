function [dimInfoCombined, indSamplingPointCombined] = combine(this, ...
    dimInfoArray, combineDims)
% Combines an array of dimInfos along a combination dimension or with
% pre-created selections
%
%   Y = MrDimInfo()
%   [dimInfoCombined, indSamplingPointCombined] = ...
%                     Y.combine(dimInfoArray, combineDims)
%       OR
%   dimInfoCombined = Y.combine(dimInfoArray, selectionIndexArrayCell)
%       OR
%   dimInfoCombined = Y.combine(dimInfoArray, selectionIndexRangeCell)
%       OR
%   dimInfoCombined = Y.combine(dimInfoArray, dimInfoCombineDims)
%
% This is a method of class MrDimInfo.
%
% NOTE: This method will work for two cases:
%           1)  Each dimInfo in the array has singleton-dimensions, which
%               match the labels in combineDims. Then, the dimInfo is
%               combined along these dimensions
%           2)  The combineDims do not exist as labels. In this case, use
%               the dimLabel/Range syntax of selectionIndexRangeCell below
%               The dimInfo is combined along these new dimensions with the
%               same
%
% IN
%   combineDims     cell(1,nDims) of dimLabels for the dimensions along
%                   which the dimInfos shall be combined. Those dimensions
%                   will have to be singleton (one entry only) in each
%                   dimInfo to allow the combination
%
%       OR
%   selectionIndexArrayCell     cell(nValuesDim1,...,nValuesDim1) of
%                               dimLabel / dimValue pairs as used in
%                               MrDimInfo.split (selectionArray)
%                               e.g.,
%                               {'coils', 1, 'echo', 1}, ..., {'coils', 1, 'echo', 3}
%                               ...
%                               {'coils', 8, 'echo', 1}, ..., {'coils', 8, 'echo', 3}
%
%       OR
%   selectionIndexRangeCell     cell(1,2*dimLabels) of dimLabel /
%                               dimValueRange pairs,
%                               e.g., {'coils', 1:8, 'echo', 1:3}
%
% OUT
%   dimInfoCombined
%
% EXAMPLE
%   combine(dimInfoArray, {'coils', 1:8, 'echo', 1:3});
%
%   See also MrDimInfo MrDimInfo.split
%
% Author:   Lars Kasper
% Created:  2018-05-04
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

%% 1) dimInfoCombined = Y.combine(dimInfoArray, combineDims)
useCombineDimLabels = nargin < 3; %TODO: all cell elements are strings... || (iscell(combineDims) && all(cellfun(isstr)... etc.;

if useCombineDimLabels
    indSplitDims = this.get_singleton_dimensions();
    combineDims = this.dimLabels(indSplitDims);
end

%% loop over all split dimInfo and retrieve values from all split dimensions
indSplitDims = this.get_dim_index(combineDims);
nDimsSplit = numel(indSplitDims);
nSplits = numel(dimInfoArray);

splitDimSamplingPoints = cell(nSplits,nDimsSplit);
for iSplit = 1:nSplits
    for iDimSplit = 1:nDimsSplit
        
        %% TODO: check dimLabels, samplingPoints and units whether they match...
        % check sampling widths
        if ~isequal(this.samplingWidths(iDimSplit), dimInfoArray{iSplit}.samplingWidths(iDimSplit))
            error('unequal samplingWidths for combining dimInfo %d in dim %s', ...
                iSplit, combineDims{iDimSplit});
        end
        
        splitDimSamplingPoints{iSplit, iDimSplit} = ...
            dimInfoArray{iSplit}.samplingPoints{indSplitDims(iDimSplit)};
        
   
    end
end


%% Check unique entries for each dimension and sort values
combinedSplitDimSamplingPoints = cell(nDimsSplit,1);
indSamplingPointCombined = NaN(nSplits,nDimsSplit);
for iDimSplit = 1:nDimsSplit
    combinedSplitDimSamplingPoints{iDimSplit} = reshape(sort(unique(...
        cell2mat(splitDimSamplingPoints(:, iDimSplit)))), 1, []);
    for iSplit = 1:nSplits
        [~,indSamplingPointCombined(iSplit,iDimSplit)] = ...
            find(splitDimSamplingPoints{iSplit, iDimSplit} ...
            == combinedSplitDimSamplingPoints{iDimSplit});
    end
end

%% create new
dimInfoCombined = this.copyobj();
dimInfoCombined.samplingPoints(indSplitDims) = combinedSplitDimSamplingPoints;