function this = get_from_filenames(this, fileArray)
% creates dimInfo from file naming scheme e.g. image_sli035_echo001_asl000_dyn123_dif000.mat
% <prefix>_<dimLabel1><dimValue1>..._<dimLabelN><dimValueN>.<suffix>
%              
% NOTE: interpretes file counter as relative index in each dimension 
%
%   Y = MrDimInfo()
%   Y.get_from_filenames(inputs)
%
% This is a method of class MrDimInfo.
%
% IN
%   fileArray   cell(nFiles,1) of file names (strings)
% OUT
%
% EXAMPLE
%   get_from_filenames
%
%   See also MrDimInfo
%
% Author:   Lars Kasper
% Created:  2016-11-08
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


% determine common prefix
% pfx = get_common_prefix(fileArray);
% determine dim labels and sizes

nFiles = numel(fileArray);

dimValues= cell(nFiles,1);
for iFile = 1:nFiles  
    [dimLabels, dimValues{iFile}, pfx, sfx] = get_dim_labels_from_string(fileArray{iFile});
end

dimValues = cell2mat(dimValues);
nDims = numel(dimLabels);

this.dimLabels = dimLabels;
for iDim = 1:nDims
   this.set_dims(dimLabels{iDim}, 'samplingPoints', unique(dimValues(:,iDim))); 
end

