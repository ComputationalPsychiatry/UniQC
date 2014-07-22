function this = finish_processing_step(this, module)
% finishes current processing step by deleting duplicate data and storing
% results of processing step
%
%   MrSeries = finish_processing_step(MrSeries, module)
%
% This is a method of class MrSeries.
%
% IN
%   module      'realign', 'smooth', ...
%
% OUT
%
% EXAMPLE
%   finish_processing_step
%
%   See also MrSeries MrSeries.init_processing_step
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-01
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

% NOTE: for each new processing step added here, it has to be decided which 
% files are saved additionally or which temporary files can be deleted/renamed
itemsSave = this.parameters.save.items;
doSave = ~strcmpi(itemsSave, 'none');
doSaveNifti = ismember(itemsSave, {'nii', 'all'});
doSaveObject = ismember(itemsSave, {'object', 'all'});

% delete additional, processed files...
fileUnprocessed = fullfile(this.data.parameters.save.path, ...
    this.data.parameters.save.fileUnprocessed);
fileProcessed = fullfile(this.data.parameters.save.path, ...
    this.data.parameters.save.fileProcessed);
filesObsolete = {};

switch module
    case 'compute_stat_images'
        % file names and paths already given in init_processing_step
        if doSaveNifti
            handleImageArray = this.get_all_image_objects('stats');
            for iImage = 1:numel(handleImageArray)
                handleImageArray{iImage}.save;
            end
        end
    case 'compute_tissue_probability_maps'
        
    case 'realign' % load realignment parameters into object
        fileRealignmentParameters = regexprep( ...
            prefix_files(fileUnprocessed, 'rp_'), '\.nii$', '\.txt') ;
        this.glm.regressors.realign = load(fileRealignmentParameters);
        fileRealignMean = prefix_files(fileUnprocessed, 'mean');
        filesObsolete = {
            fileUnprocessed
            fileRealignMean
            };
        
        % establish correct link to saved file for later loading:
        this.data.parameters.save.fileUnprocessed = this.data.parameters.save.fileProcessed;
    case 'smooth'
        % establish correct link to saved file for later loading:
        this.data.parameters.save.fileUnprocessed = this.data.parameters.save.fileProcessed;
        filesObsolete = {fileUnprocessed};
    case 't_filter'
        if doSaveNifti
            this.data.save();
        end
end

if ~doSaveNifti % delete unprocessed files as well
   filesObsolete = [filesObsolete; fileUnprocessed];
end

delete_with_mat(filesObsolete);

% strip object data and save ...
if doSaveObject
    pathProcessing = fullfile(this.parameters.save.path, this.processingLog{end});
    fileObject = fullfile(pathProcessing, 'MrObject.mat');
    MrObject = this.copyobj('exclude', 'data'); % copies object without data
    save(fileObject, 'MrObject');
end