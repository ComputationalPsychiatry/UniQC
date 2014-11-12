function this = finish_processing_step(this, module, varargin)
% finishes current processing step by deleting duplicate data and storing
% results of processing step
%
%   "raeumt nur ein, nicht auf!" => aufraeumen schon in
%   MrImage.finish_processing_step
%
%   MrSeries = finish_processing_step(MrSeries, module, varargin)
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

% determine where and which files have been changed from input argument
if iscell(varargin{1});
    inputImage = varargin{1}{1};
else
    inputImage = varargin{1};
end

pathSave = inputImage.parameters.save.path;
filesObsolete = {};

% delete additional, processed files...
switch module
    
    case 'compute_masks'        
        maskImages = varargin{1};
        nImages = numel(maskImages);
        
        filesMask = cell(nImages,1);
        for iImage = 1:nImages
            filesMask{iImage} = ...
                maskImages{iImage}.get_filename;
        end
        
        filesRaw = maskImages{iImage}.get_filename('raw');
        
        if ~doSaveNifti
            filesObsolete = [filesMask; filesRaw];
        else
            filesObsolete = [filesRaw];
        end
        
        
    case 'compute_stat_images'
        % file names and paths already given in init_processing_step
        if doSaveNifti
            handleImageArray = this.get_all_image_objects('stats');
            for iImage = 1:numel(handleImageArray)
                handleImageArray{iImage}.save;
            end
        end
        
        
    case 'compute_tissue_probability_maps'
        createdFields = varargin{1};
        inputImage = varargin{2};
        nImages = numel(createdFields);
        
        filesFieldImages = cell(nImages,1);
        for iImage = 1:nImages
            filesFieldImages{iImage} = fullfile(...
                pathSave, ...
                createdFields{iImage}.parameters.save.fileName);
        end
        
        fileRaw = inputImage.get_filename('raw');
        fileProcessed = inputImage.get_filename;
        fileSeg8 = regexprep(fileRaw, '\.nii$', '_seg8\.mat');
        
        % determine files to be deleted
        if doSaveNifti
            filesObsolete = {fileRaw; fileSeg8}; % filesFieldImages];
        else
            filesObsolete = [{fileRaw; fileSeg8; fileProcessed}; ...
                filesFieldImages];
        end
        
    case 'coregister'
        transformedImage = varargin{1};
        equallyTransformedImages = varargin{2};
        
        % set files for delete
        filesRaw = {transformedImage.get_filename('raw')};
        filesProcessed = {transformedImage.get_filename};
        nImages = numel(equallyTransformedImages);
        for iImage = 1:nImages
            filesProcessed{end+1} = equallyTransformedImages{iImage}.get_filename;
        end
        
        if ~doSaveNifti
            filesObsolete = [filesRaw; filesProcessed];
        else
            filesObsolete = filesRaw;
        end
        
    case 'realign' % load realignment parameters into object
        fileRaw = inputImage.get_filename('raw');
        fileProcessed = inputImage.get_filename;
        fileRealignmentParameters = regexprep( ...
            prefix_files(fileRaw, 'rp_'), '\.nii$', '\.txt') ;
        this.glm.regressors.realign = load(fileRealignmentParameters);
        fileRealignMean = prefix_files(fileRaw, 'mean');
        
        % determine files to be deleted
        if doSaveNifti
            filesObsolete = {fileRaw; fileRealignMean};
        else
            filesObsolete = {fileRaw; fileRealignMean; fileProcessed};
        end
        
        
    case 'smooth'
        fileRaw = inputImage.get_filename('raw');
        fileProcessed = inputImage.get_filename;
        
        % determine files to be deleted
        if doSaveNifti
            filesObsolete = {fileRaw};
        else
            filesObsolete = {fileRaw; fileProcessed};
        end
        
        
    case 't_filter'
        if doSaveNifti
            this.data.save();
        end
end


delete_with_hdr(filesObsolete);

% strip object data and save ...
if doSaveObject
    fileObject = fullfile(pathSave, 'MrObject.mat');
    MrObject = this.copyobj('exclude', 'data'); % copies object without data
    save(fileObject, 'MrObject');
end