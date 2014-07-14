function this = compute_masks(this)
% segments defined input image into tissue types & thresholds to get masks
% - input image can be anatomical or mean functional
%
%   Y = MrSeries()
%   Y.compute_masks(inputs)
%
% This is a method of class MrSeries.
%
% IN
%
% OUT
%
% EXAMPLE
%   compute_masks
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-14
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
