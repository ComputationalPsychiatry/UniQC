function originIndex = get_origin(this)
% returns (also fractional) index of samplingPoint with value [0 0 ... 0]
%
%   Y = MrDimInfo()
%   originIndex = Y.get_origin(inputs)
%
% This is a method of class MrDimInfo.
%
% IN
%
% OUT
%
% EXAMPLE
%   get_origin
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-12-12
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
[~,originIndex] = cellfun(@(x) min(abs(x)), this.samplingPoints, ...
    'UniformOutput', false);
originIndex = cell2mat(originIndex);

fractionalIndex = this.index2sample(originIndex)./this.resolutions;

originIndex = originIndex - fractionalIndex;