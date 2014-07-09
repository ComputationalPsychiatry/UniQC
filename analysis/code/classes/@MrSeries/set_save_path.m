function this = set_save_path(this, pathSave)
% sets save path recursively for all saveable objects within MrSeries
%
%   Y = MrSeries()
%   Y.set_save_path(inputs)
%
% This is a method of class MrSeries.
%
% IN
%   pathSave        new save path (default: parameters.save.path)
%
% OUT
%
% EXAMPLE
%   set_save_path
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-09
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
    pathSave = this.parameters.save.path;
else
    this.parameters.save.path = pathSave;
end

handleImageArray = this.get_all_image_objects();
for iImage = 1:numel(handleImageArray);
    handleImageArray{iImage}.parameters.save.path = ...
        pathSave;
end
