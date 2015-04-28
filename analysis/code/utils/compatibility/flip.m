function X = flip(X, dim)
% For older Matlab versions (<2013b), this redirects flip to flipdim
%
%   X = flip(X, dim)
%
% IN
%   X       N-d matrix
%   dim     dimension which shall be flipped (i.e. element indices changed
%           from 1->N to N->1)
%
% OUT
%   X       N-d matrix, flipped along dim-th dimension
%
% EXAMPLE
%   flip
%
%   See also flipdim
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-03-09
% Copyright (C) 2015 Institute for Biomedical Engineering
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

warning off MATLAB:dispatcher:nameConflict;

if ~exist('flip', 'builtin')
    X = flipdim(X, dim);
else
    X = builtin('flip', X, dim);
end