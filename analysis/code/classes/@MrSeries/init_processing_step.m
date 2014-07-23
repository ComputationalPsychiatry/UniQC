function this = init_processing_step(this, module, varargin)
% initializes next processing step by creating folders for version tracking,
% shuffling data, and updating processing parameters
%
%   MrSeries = init_processing_step(MrSeries, module)
%
% This is a method of class MrSeries.
%
% IN
%   module      'realign', 'smooth', ...
%
% OUT
%
%   side effects:
%   new folder (with current data):
%       dirObject/<nProcessingSteps+1>_moduleName
%   parameters.processingLog
%   nProcessingSteps
%
% EXAMPLE
%   init_processing_step
%
%   See also MrSeries
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
% (input, raw, unprocessed) files are saved additionally
itemsSave = this.parameters.save.items;
doSave = ~strcmpi(itemsSave, 'none');
doSaveNifti = ismember(itemsSave, {'nii', 'all'});
doSaveObject = ismember(itemsSave, {'object', 'all'});

% set file-saving behavior of MrImage to keep disk files
this.data.parameters.save.keepCreatedFiles = ...
    1 ; % keeps files here, cleanup will happen in finish_processing_step

pathSaveRoot = this.parameters.save.path;

% save initial, unprocessed data
isFirstProcessingStep = ~this.nProcessingSteps;
if isFirstProcessingStep && doSave
    dirProcessing = sprintf('%03d_%s', this.nProcessingSteps, 'unprocessed');
    pathProcessing = fullfile(pathSaveRoot, dirProcessing);
    mkdir(pathProcessing);
    this.data.parameters.save.path = pathProcessing;
    this.data.parameters.save.fileUnprocessed = 'raw.nii';
    
    % save data (MrImage file)
    if doSaveNifti
        this.data.save();
    end
    
    % strip and save object as well
    if doSaveObject
        fileObject = fullfile(pathProcessing, 'MrObject.mat');
        MrObject = this.copyobj('exclude', 'data'); % copies object without data
        save(fileObject, 'MrObject');
    end
end

% specify new directory to save data here
this.nProcessingSteps = this.nProcessingSteps + 1;
dirProcessing = sprintf('%03d_%s', this.nProcessingSteps, module);
pathProcessing = fullfile(pathSaveRoot, dirProcessing);

this.processingLog{end+1,1} = dirProcessing;


% module-specific adaptations, e.g. data copying

hasMatlabbatch = ismember(module, {'realign', 'smooth,', ...
    'compute_tissue_probability_maps'});

if doSave || hasMatlabbatch
    mkdir(pathProcessing);
end

if hasMatlabbatch % data has to be written to disk before running spm_jobman, prepare file-names!
    this.data.parameters.save.path = pathProcessing;
    this.data.parameters.save.fileUnprocessed = 'raw.nii';
    this.data.parameters.save.fileProcessed = 'processed.nii';
end

switch module
    
    case 'compute_masks'
        inputImages = varargin{1};
        nImages = numel(inputImages);
        
        % set paths and prepend file names with mask... for all input files
        isSuffix = false;
        isMixedCase = true;
        for iImage = 1:nImages
            inputImages{iImage}.parameters.save.path = pathProcessing;
            
            fileUnprocessed = inputImages{iImage}.parameters.save.fileUnprocessed;
            inputImages{iImage}.parameters.save.fileUnprocessed = ...
                prefix_files(fileUnprocessed, 'mask', isSuffix, isMixedCase);
            inputImages{iImage}.parameters.save.keepCreatedFiles = 1;
        end
        
    case 'compute_stat_images'
        [handleImageArray, nameImageArray] = this.get_all_image_objects('stats');
        for iImage = 1:numel(handleImageArray)
            handleImageArray{iImage}.parameters.save.path = pathProcessing;
            handleImageArray{iImage}.parameters.save.fileUnprocessed = ...
                [nameImageArray{iImage} '.nii'];
        end
        
    case 'compute_tissue_probability_maps'
        
        % adjust input image to make it save-able
        inputImage = varargin{1};
        inputImage.parameters.save.path = pathProcessing;
        inputImage.parameters.save.fileUnprocessed = 'raw.nii';
        inputImage.parameters.save.keepCreatedFiles = 1;
    case 'realign'
        
    case 'smooth'
        
        % set file names and save path for statistical images
    case 't_filter'
        this.data.parameters.save.path = pathProcessing;
        % raw file doesn't have to be saved, therefore prepare for final
        % save of results here already
        this.data.parameters.save.fileProcessed = 'processed.nii';
        this.data.parameters.save.fileUnprocessed = ...
            this.data.parameters.save.fileProcessed;
end

end