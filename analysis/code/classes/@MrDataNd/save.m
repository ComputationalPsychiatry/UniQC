function this = save(this, varargin)
% Saves data to file(s), depending on which loop-dimensions have been
% selected
%
%   Y = MrDataNd()
%   Y.save(inputs)
%
% This is a method of class MrDataNd.
%
% IN
%
% OUT
%
% EXAMPLE
%   save
%
%   See also MrDataNd
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-05-25
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

defaults.fileName = this.get_filename();
defaults.splitDims = 'unset'; % changed below!

args = propval(varargin, defaults);
strip_fields(args);

% defaults splitDims are adapted depending on file extension to have
% e.g. default 4D nifti files.
[fp, fn, ext] = fileparts(fileName);
if isequal(splitDims, 'unset')
    switch ext
        case {'.nii', '.img'}
            splitDims = [5:this.dimInfo.nDims];
            
            % save dimInfo for later recovery of absolute indices (e.g.
            % which coil or echo time)
            dimInfo = struct(this.dimInfo);
            save(fullfile(fp, [fn '_dimInfo.mat']), 'dimInfo');
            
        otherwise
            splitDims = [];
    end
end


% 1. create all selections, 
% 2. loop over all selections
%       a) to select sub-image
%       b) to adapt name of subimage with selection suffix
%       c) to save (with extension-specific) single-file save

[dimInfoArray, sfxArray, selectionArray] = this.dimInfo.split(splitDims);

nSelections = numel(dimInfoArray);
for iSelection = 1:nSelections;
    tempDataNd = this.select(selectionArray{iSelection});
    tempDataNd.parameters.save.path = fp;
    tempDataNd.parameters.save.fileName = [fn sfxArray{iSelection} ext];
    tempDataNd.write_single_file();
end
            