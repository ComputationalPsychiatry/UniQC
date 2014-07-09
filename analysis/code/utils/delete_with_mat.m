function fileNameArray = delete_with_mat(fileNameArray)
% Deletes given files; for .nii (nifti-) files, also deletes .mat-header,
% if existing
%
%   fileNameArray = delete_with_mat(fileNameArray)
%
% IN
%   fileNameArray   cell of filenames to be deleted
% OUT
%   fileNameArray   cell of filenames that were tried to be deleted
%                   (includes .mat files corresponding to .nii)
%
% EXAMPLE
%   delete_with_mat('temp.nii');
%
%   See also move_with_mat
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-08
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

if ~isempty(fileNameArray) % only do sth, if files are given, no '' or {}
    if ~iscell(fileNameArray)
        fileNameArray = cellstr(fileNameArray);
    end
    
    
    % append all .mat files to list of deletable files that corresponding to .nii
    iNiftiFiles = find(~cellfun(@isempty, regexp(fileNameArray, '\.nii')));
    fileNameMatArray = regexprep(fileNameArray(iNiftiFiles), '\.nii', '\.mat');
    
    nFiles = numel(fileNameMatArray);
    for iFile = 1:nFiles
        fileMat = fileNameMatArray{iFile};
        if exist(fileMat, 'file')
            fileNameArray{end+1} = fileMat;
        end
    end
    
    delete(fileNameArray{:});
end
