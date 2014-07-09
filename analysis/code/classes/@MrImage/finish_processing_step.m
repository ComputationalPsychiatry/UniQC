function this = finish_processing_step(this, module, varargin)
% finishes current processing step by deleting SPM-related temporary data
% on disk and writing back processed data from disk into data matrix
% results of processing step
%
%   Y = MrImage()
%   Y.finish_processing_step(module, varargin)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   Y.finish_processing_step('smooth', fileOutputSpm);
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-03
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

fileUnprocessed = fullfile(this.parameters.save.path, ...
    this.parameters.save.fileUnprocessed);
fileProcessed = fullfile(this.parameters.save.path, ...
    this.parameters.save.fileProcessed);
nameImage = this.name;

hasMatlabbatch = ismember(module, {'realign', 'smooth'});

% nifti leftovers exist and resulting files have to be renamed
if hasMatlabbatch
    fileMatlabbatch = fullfile(this.parameters.save.path, ...
        'matlabbatch.mat');
    filesCreated = {
        fileUnprocessed
        fileProcessed
        fileMatlabbatch
        };
    switch module
        case 'smooth'
            fileOutputSpm = prefix_files(fileUnprocessed, 's');
        case 'realign'
            fileOutputSpm = prefix_files(fileUnprocessed, 'r');
            fileRealignmentParameters = regexprep(...
                prefix_files(fileUnprocessed, 'rp_'), '\.nii', '\.txt');
            fileRealignMean = prefix_files(fileUnprocessed, 'mean');
            filesCreated = [
                filesCreated
                    {fileRealignmentParameters; fileRealignMean}
                ];
    end
    
    move_with_mat(fileOutputSpm, fileProcessed);
    
    % load back data into matrix
    this.load(fileProcessed); % TODO: change filename in parameters.save to new fileProcessed?
end

% delete all unwanted files
if ~this.parameters.save.keepCreatedFiles
    delete_with_mat(filesCreated);
    [stat, mess, id] = rmdir(this.parameters.save.path);
end

% to preserve name after reloading, because not in nifti-file
this.name = nameImage;

end