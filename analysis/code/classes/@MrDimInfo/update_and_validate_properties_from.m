function this = update_and_validate_properties_from(this, dimInfo)
% updates properties from other dimInfo, allowing only valid entries to
% update.
%
%   Y = MrDimInfo()
%   Y.update_and_validate_properties_from(dimInfo)
%
% This is a method of class MrDimInfo.
%
% IN
%
% OUT
%
% EXAMPLE
%   update_and_validate_properties_from
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-24
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
tempDimInfoArgs = [];
nArgs = numel(properties(dimInfo));
dimInfoProperties = properties(dimInfo);
% check whether nDims of given dimInfo matches this
if ~isequal(this.nDims, dimInfo.nDims)
    error('Number of dimensions in input dimInfo does not match current nDims');
end
    
for iArg = 1:nArgs
    currProp = dimInfoProperties{iArg};
    % make sure current property is not nDims (no set)
    isnDims = strcmp(currProp, 'nDims');
    if ~isnDims
        % extract current value
        currVal = dimInfo.(currProp);
        % no empty or nan properties used, no zeros for nSamples used
        isnSamples = strcmp(currProp, 'nSamples');
        if iscell(currVal)
            if strcmp(currProp, 'dimLabels')
                % check whether any difference between current and old
                % values for dimLabels
                oldVal = this.(currProp);
                isValidProperty = any(~(cellfun(@isequal, currVal, oldVal)));
            elseif strcmp(currProp, 'units')
                % check whether any difference between current and old values
                % for units
                oldVal = this.(currProp);
                isValidProperty = any(~(cellfun(@isequal, currVal, oldVal)));
                
            elseif ismember(currProp, {'samplingPoints', 'samplingWidths'})
                % check whether nans or empty values were given
                isNans = cellfun(@(C) any(isnan(C(:))), currVal);
                isEmpty = cellfun(@(C) any(isempty(C(:))), currVal);
                isValidProperty = ~all(isNans) && ~all(isEmpty);
            end
        else
            isValidProperty = ~all(isnan(currVal(:))) && ~all(isempty(currVal(:))) && ...
                ~(isnSamples && all(currVal(:) == 0));
        end
        if isValidProperty
            tempDimInfoArgs = [tempDimInfoArgs {currProp} {currVal}];
        end
    end
end
if ~isempty(tempDimInfoArgs)
    this.set_dims(1:dimInfo.nDims, tempDimInfoArgs{:});
end
