function [selectionDimInfo, selectionIndexArray, ...
    unusedVarargin] = select(this, varargin)
% Returns indexArray and corresponding dimInfo of sub-selection from array
% specified by dimInfo
%
%   Y = MrDimInfo()
%   Y.select('type', 'index'/'label', 'invert', true/false, ...
%             'dimLabel1', arrayIndicesDim1/samplingPointsDim1, ...,
%               ...
%              'dimLabelK', arrayIndicesDimK/samplingPointsDimK, ...)
%
% This is a method of class MrDimInfo.
%
%
% IN
%   'type'      'index' or 'label'
%               defines how selection elements should be
%               interpreted as array indices or sampling points
%   'invert'    true or false (default)
%               if true, selection is inverted and given arrayIndices are
%               excluded from returned selection, based on
%               dimInfo-information about whole array
%
% OUT
%   selectionDimInfo        dimInfo of specified selection, derived as
%                           subset from dimInfo
%   selectionIndexArray     indexArray of selected samples in original
%                           dimInfo
%   unusedVarargin          if specified, returns all input arguments that
%                           did not match a dimLabel/Value pair of dimInfo
%                           Note: If this output is omitted, select returns
%                           an error for every unknown dimension requested
%
% EXAMPLE
%   select
%
%   See also MrDimInfo
%
% Author:   Lars Kasper
% Created:  2016-01-29
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
defaults.invert = false;
defaults.type = 'index'; % or sample(s)

[argsSelect, argsDimInfo] = propval(varargin, defaults);

% selectionDimInfo what has to change? samplingPoints, everything else is
% derivative! ... So we have to get the selectionIndexArray and the reduce
% selectionDimInfo to it!
selectionDimInfo = this.copyobj();
unusedVarargin = {};
returnUnusedVarargin = nargout >=3;


parseDimLabels = argsDimInfo(1:2:end);
parseDimValues = argsDimInfo(2:2:end);

selectionIndexArray = cell(this.nDims, 1);

nParseDims = numel(parseDimLabels);
for iDimSelect = 1:nParseDims
    dimLabel = parseDimLabels{iDimSelect};
    currentIndices = parseDimValues{iDimSelect};
    
    iDim = this.get_dim_index(dimLabel);
    isUnknownDimLabel = isempty(iDim);
    if isUnknownDimLabel
        if returnUnusedVarargin
            unusedVarargin(end+1:2) = {dimLabel, currentIndices};
        else
            error('Dimension with label "%s" does not exist in %s', dimLabel, ...
                inputname(1));
        end
    else
        
        switch argsSelect.type
            case {'sample', 'samples'}
                currentIndices = this.sample2index(currentIndices, ...
                    iDim);
        end
        
        if argsSelect.invert
            currentIndices = setdiff(1:this.nSamples(iDim), ...
                currentIndices);
        end
        
        
        selectionDimInfo.samplingPoints{iDim} = ...
            this.samplingPoints{iDim}(currentIndices);
        
        
        selectionIndexArray{iDim} = currentIndices;
    end
end

% fill up dimensions without specific selection with full range
for iDim = 1:this.nDims
    if isempty(selectionIndexArray{iDim})
        selectionIndexArray{iDim} = 1:this.nSamples(iDim);
    end
end
