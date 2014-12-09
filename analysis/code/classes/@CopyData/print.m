function s = print(obj, pfx, verbose)
% Prints all non-empty values of a object along with their property names
%
%   Y = CopyData()
%   s = Y.print(pfx, verbose)
%
%
% This is a method of class CopyData.
%
% IN
% verbose   {true} or false; if false, only the string is created, but
%           no output to the command window
%
% OUT
% s         cell of strings of reported non-empty values of CopyData-object
%
% EXAMPLE
%   Y.print
%
%   See also CopyData
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-12-09
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
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

if nargin < 2
    pfx = '';
end
if nargin < 3
    verbose = true;
end
s = cell(0,2);
mobj = metaclass(obj);
sel = find(cellfun(@(cProp)(~cProp.Constant && ...
    ~cProp.Abstract && ...
    (~cProp.Dependent || ...
    (cProp.Dependent && ...
    ~isempty(cProp.SetMethod)))),mobj.Properties));
for k = sel(:)'
    tmps = [];
    pname = mobj.Properties{k}.Name;
    currProp = obj.(pname);
    if isa(currProp, 'CopyData') %recursive comparison
        tmps = currProp.print([pfx '.' pname], verbose);
    else
        % cell of CopyData also treated
        if iscell(currProp) ...
                && length(currProp) ...
                && isa(currProp{1}, 'CopyData')
            for c = 1:length(currProp)
                tmps2 = currProp{c}.print([pfx '.' pname], verbose);
                if ~isempty(tmps2), tmps = [tmps; tmps2]; end
            end
        else % no cell of CopyData, no CopyData...any other property
            if ~isempty(currProp)
                tmps{1,1} = [pfx '.' pname];
                if ischar(currProp)
                    tmps{1,2} = currProp;
                elseif iscell(currProp)
                    if ischar(currProp{1})
                        tmps{1,2} = sprintf('cell array %s ', currProp{1});
                    else
                        tmps{1,2} = sprintf('cell array %f ', currProp{1});
                    end
                else
                    pp = currProp(1,1:min(size(currProp,2), 16));
                    if (floor(double(pp(1)))==ceil(double(pp(1)))) %print integers differently
                        tmps{1,2} = sprintf('%d ', pp);
                    else
                        tmps{1,2} = sprintf('%4.2e ', pp);
                    end
                    if numel(currProp)>numel(pp), tmps{1,2} = [tmps{1,2}, '...']; end
                end
                if verbose
                    fprintf('%70s = %s\n', tmps{1,1}, tmps{1,2});
                end
            end
        end
    end
    if ~isempty(tmps), s = [s; tmps]; end
end

end