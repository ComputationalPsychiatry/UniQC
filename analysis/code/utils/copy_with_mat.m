function [fileNameSourceArray, fileNameTargetArray] = copy_with_mat(...
    fileNameSourceArray, fileNameTargetArray)
% Copies given files; for .nii (nifti-) files, also copies .mat-header,
% if existing
%
%   [fileNameSourceArray, fileNameTargetArray] = copy_with_mat(...
%    fileNameSourceArray, fileNameTargetArray)
%
% IN
%   fileNameSourceArray   cell of filenames to be copied (source)
%   fileNameTargetArray   cell of filenames to be copied to (targets)
% OUT
%   fileNameSourceArray   cell of filenames that were tried to be copied
%                   (includes .mat files corresponding to .nii)
%
% EXAMPLE
%   copy_with_mat('from.nii', 'to.nii')
%
%   See also delete_with_mat
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-23
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

if ~iscell(fileNameSourceArray)
    fileNameSourceArray = cellstr(fileNameSourceArray);
    fileNameTargetArray = cellstr(fileNameTargetArray);
end


% append all .mat files to list of deletable files that corresponding to .nii
iNiftiFiles = find(~cellfun(@isempty, regexp(fileNameSourceArray, '\.nii$')));
fileNameSourceMatArray = regexprep(fileNameSourceArray(iNiftiFiles), '\.nii$', '\.mat');
fileNameTargetMatArray = regexprep(fileNameTargetArray(iNiftiFiles), '\.nii$', '\.mat');

nFiles = numel(fileNameSourceMatArray);
for iFile = 1:nFiles
    fileMatSource = fileNameSourceMatArray{iFile};
    fileMatTarget = fileNameTargetMatArray{iFile};
    if exist(fileMatSource, 'file')
        fileNameSourceArray{end+1} = fileMatSource;
        fileNameTargetArray{end+1} = fileMatTarget;
    end
end

% move all files one by one :-(
nFiles = numel(fileNameSourceArray);
for iFile = 1:nFiles
    copyfile(fileNameSourceArray{iFile}, fileNameTargetArray{iFile});
end