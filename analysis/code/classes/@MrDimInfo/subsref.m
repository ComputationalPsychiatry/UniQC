function varargout = subsref(this, S)
% Allows subscript referencing with dot notation of dimLabels
%
%   Y = MrDimInfo()
%   Y.subsref(S)
%
% This is a method of class MrDimInfo.
% It checks whether the provides S.subs is a valid dimLabel and returns the
% reduced MrDimInfo for this dimension (via get_dims(dimLabel)). For
% anything but the first-level dot notation, it uses the builtin subsref.
%
% IN
%   S   structure with two fields:
%           type is a char vector containing '()', '{}', or '.', indicating the type of indexing used.
%           NOTE: we only overload the dot notation here to index dimLabels
%           subs is a cell array or character array containing the actual subscripts.% OUT
%
% EXAMPLE
%   This enables the usage of dimLabels in the dot notation, e.g.
%
%   dimInfo = MrDimInfo('dimLabels', {'x', 'y', 'z'},
%                       'samplingPoints', {1:10, -10:-1, 5:14});
%   dimInfo.z.samplingPoints
%       => ans =
%      5     6     7     8     9    10    11    12    13    14
%
%   See also MrDimInfo builtin.subsref
%
% Author:   Lars Kasper & Saskia Bollmann
% Created:  2017-06-28
% Copyright (C) 2017 Institute for Biomedical Engineering
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

switch S(1).type
    case '.'
        % do custom dot-referencing  for valid dimLabels
        if ismember(S(1).subs, this.dimLabels)
            
            if numel(S) == 1 % return reduced dimInfo object
                varargout = {this.get_dims(S(1).subs)};
            else
                % retrieve reduced dimInfo and continue with classical subsref
                % from there
                varargout = {builtin('subsref',this.get_dims(S(1).subs),S(2:end))};
            end
        else
            if ismember(S(1).subs, properties(this)) && numel(S) > 1
                % do custom dot-referencing allowing for property(dimLabel), e.g. resolutions('x')
                % by converting char/cell indices to numerical ones and run normal
                % subsref
                S(2).subs = {this.get_dim_index(S(2).subs{:})};
            end
            varargout = {builtin('subsref',this,S)};
        end
    otherwise
        % use builting indexing for Y(i,j) or Y{i,j}
        varargout = {builtin('subsref',this,S)};
        
end