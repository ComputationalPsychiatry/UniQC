function minValue = min(this, varargin)
% Returns minimum value of data matrix of MrImage by 3 applications of
% minip
%
%   Y = MrImage()
%   minValue = ...
%       Y.min('ParameterName1', 'ParameterValue1', ...)
%
% This is a method of class MrImage.
%
% IN
%   varargin    parameterName/Value pairs for selection of volumes/slices
%
% OUT
%
% EXAMPLE
%   Y.min(50, 'selectedSlices', 1, 'selectedVolumes', 3:100, ...,
%           'selectedX', 55:75)
%
% EXAMPLE
%   min(Y)
%
%   See also MrImage MrImage.minip
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-25
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

if nargin < 2
    imgSelect = this;
else
    imgSelect = this.select(varargin{:});
end

outputImage = minip(minip(minip(minip(imgSelect))));
minValue = outputImage.data(1);