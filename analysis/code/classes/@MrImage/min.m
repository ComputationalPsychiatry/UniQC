function minValue = min(this)
% Returns minimum value of data matrix of MrImage by 3 applications of
% minip
%
%   Y = MrImage()
%   Y.min OR min(Y)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
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

outputImage = minip(minip(minip(this)));
minValue = outputImage.data(1);