function fileArray = get_filenames(cellOrString, isExact)
% Returns a cell of filenames given a regular expression, folder name, or
% file prefix.
%
%   fileArray = get_filenames(cellOrString)
%
%
% NOTE: if a cell of file names is given, a cell of the existing ones is
% returned; if a single file name is given, and it exists, it is returned
% within a cell. If it doesn't exist, an empty
%
% IN
%
% OUT
%   fileArray   string of files 
%
% EXAMPLE
%   get_filenames('funct_short.nii')
%       -> {'funct_short.nii'} is returned
%   get_filenames('resting_state_ingenia_3T/')
%       -> {'funct_short.nii'; 'struct.nii'; 'meanfunct.nii'} is returned
%   isExact = 1;
%   get_filenames('resting_state_ingenia_3T/f', isExact)
%       -> {} is returned
%   isExact = 0;
%   get_filenames('resting_state_ingenia_3T/f', isExact)
%   get_filenames('resting_state_ingenia_3T/f*')
%   get_filenames('resting_state_ingenia_3T/f.*')
%       -> in all 3 cases, {'funct_short.nii'} is returned
%
%   See also MrDataNd.load
%
% Author:   Lars Kasper
% Created:  2016-10-21
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

if ischar(cellOrString)
    if exist(cellOrString, 'file') % single file, check, if exists
        fileArray = {cellOrString};
    elseif exist(cellOrString, 'dir') % directory, select all files in directory
        
    else % fileprefix or regular expression
        
    end
elseif iscell(cellOrString)
    fileArray = cellOrString;
    iExistingFiles = find(cell2mat(cellfun(@(x) exist(x, 'file'), fileArray, ...
        'UniformOutput', false)));
    fileArray = filArray(iExistingFiles);
else
    error('Input must be cell of strings or string');
end