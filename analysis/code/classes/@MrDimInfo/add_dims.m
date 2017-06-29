function this = add_dims(this, iDim, varargin)
% Adds additional dimensions to existing dimInfo
%
%   Y = MrDimInfo()
%   Y.add_dims(inputs)
%
% This is a method of class MrDimInfo.
%
% IN
%   iDim        (vector of) dimension indices to be added (e.g. 3 for 3rd
%               dimension) 
%                   or 
%               (cell of) strings of dimension names
%   varargin    PropertyName/Value pairs to set parameters of the new
%               dimension
%   
% OUT
%
% EXAMPLE
%   add_dims
%
%   See also MrDimInfo set_dims
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-06-18
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

isStringiDimInput = ischar(iDim) || (iscell(iDim) && ischar(iDim{1}));
if isStringiDimInput
    additionalDimLabels = cellstr(iDim);
else
    if ~iscell(iDim)
        iDim = num2cell(iDim);
    end
    
    if isempty(iDim{1})
        % empty set of dimLabels to add, therefore return
        return
    else
    additionalDimLabels = cellfun(@int2str, iDim, ...
        'UniformOutput', false);
    end
end

nDimsOld = this.nDims;
nDimsAdditional = numel(additionalDimLabels);
this.dimLabels = [this.dimLabels additionalDimLabels];
this.samplingPoints(nDimsOld+(1:nDimsAdditional)) = {[]};
this.samplingWidths(nDimsOld+(1:nDimsAdditional)) = {[]};
this.units(nDimsOld+(1:nDimsAdditional)) = {''};
this.offcenter(nDimsOld+(1:nDimsAdditional)) = 0;
this.rotation(nDimsOld+(1:nDimsAdditional)) = 0;
this.shear(nDimsOld+(1:nDimsAdditional)) = 0;

if nargin > 2
    this.set_dims(additionalDimLabels, varargin{:});
end