function this = load(this, inputDataOrFile, varargin)
% loads (meta-)data from file(s), order defined by loopDimensions
%
%   Y = MrDataNd()
%   Y.load(varargin)
%
% This is a method of class MrDataNd.
%
% IN
%   inputDataOrFile     can be one of 5 inputs
%                       1)  a Matrix: MrDataNd is created along with a
%                           dimInfo matching the dimensions of the data
%                           matrix
%                       2)  a file-name: MrDataNd is loaded from the
%                           specified file
%                       3)  cell(nFiles,1) of file names to be concatenated
%                       4)  a directory: All image files in the specified
%                           directory
%                       5)  a regular expression for all file names to be
%                           selected
%                           e.g. 'folder/fmri.*\.nii' for all nifti-files
%                           in a folder
%
%   varargin:   propertyName/value pairs, e.g. 'select', {'t', 1:10, 'z', 20}
%               for any property of MrDataNd and
%
%   select      for efficient loading of a data subset, a select of
%               values per dimension can be specified (corresponding to
%               dimInfo)
%
% OUT
%   this        MrDataNd with updated .data and .dimInfo
%   affineGeometry
%               For certain file types, the affineGeometry is saved as a
%               header information. While ignored in MrDataNd, it might be
%               useful to return it for specific processing
%               See also MrImage MrAffineGeometry
%
% EXAMPLE
%   load
%
%   See also MrDataNd demo_save
%
% Author:   Saskia Bollmann & Lars Kasper
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


if nargin < 2
    inputDataOrFile = this.get_filename();
end
defaults.select = [];
defaults.dimInfo = [];

[args, argsUnused] = propval(varargin, defaults);
strip_fields(args);

% create propValDimInfo
[propValDimInfo, loadInputArgs] = this.dimInfo.get_struct(argsUnused);

hasInputDimInfo = ~isempty(dimInfo);
hasPropValDimInfo = ~isempty(propValDimInfo);
%% update/load path for data and dimInfo
% In load.
% --------
% Files are determined and loop over individual files is started.
%   In read_single_file.
% ----------------------
%   1:  Values are derived from the input matrix (nSamples) or file (header
%       info).
%       DimInfo is initiated here.
%   2:  If a _dimInfo.mat file exists, this is automatically loaded as well.
%       DimInfo properties are updated.
% End of read_single_file.
% ------------------------
% Single files are combined.
% 3:  If a dimInfo object is an input argument,
%     dimInfo properties are updated.
% 4:  If prop/val parirs are given,
%     dimInfo properties are updated.

%% 1. Determine files (for wildcards or folders)

isMatrix = isnumeric(inputDataOrFile) || islogical(inputDataOrFile);
if isMatrix
    this.read_matrix_from_workspace(inputDataOrFile);
else % files or file pattern or directory
    isExplicitFileArray = iscell(inputDataOrFile) && ischar(inputDataOrFile{1});
    
    if isExplicitFileArray
        fileArray = inputDataOrFile;
    else
        fileArray = get_filenames(inputDataOrFile);
    end
    % TODO: get extra dimInfos from file names for select
    dimInfoExtra = MrDimInfo();
    dimInfoExtra.set_from_filenames(fileArray);
    
    % remove singleton dimensions
    dimInfoExtra.remove_dims();
    
    % now use select to only load subset of files
    [selectDimInfo, selectIndexArray, unusedVarargin] = ...
        dimInfoExtra.select(select);
    
    nFiles = numel(fileArray);
    
    %% 2. Load individual files into array of MrDataNd (including data of MrDimInfo)
    if nFiles == 1
        % only one file, read_single_files does everything that's necessary
        this = read_single_file(this, fileArray{1}, loadInputArgs{:});
    else
        % loop over nFiles and load each individually
        % initialize dataNdArray
        dataNdArray = cell(nFiles, 1);
        for iFile = 1:nFiles
            % load file
            fprintf('Loading File %d/%d\n', iFile, nFiles);
            fileName = fileArray{iFile};
            dataNdArray{iFile} = MrImage(fileName);
            % TODO: check if dimensions already exist
            % add dimLabel and dim Value
            [dimLabels, dimValues] = get_dim_labels_from_string(fileName);
            % TODO: generate generic dimLabels if they cannot be read from
            % fileName
            dimsToAdd = dataNdArray{iFile}.dimInfo.nDims+1:dataNdArray{iFile}.dimInfo.nDims+numel(dimLabels);
            dataNdArray{iFile}.dimInfo.add_dims(dimsToAdd, ...
                'dimLabels', dimLabels, 'samplingPoints', dimValues);
        end
        %% 3. Use combine to create one object
        imagesCombined = dataNdArray{1}.combine(dataNdArray);
        this.update_properties_from(imagesCombined);
    end
end
% update dimInfo using input dimInfo
if hasInputDimInfo
    this.dimInfo.update_and_validate_properties_from(dimInfo);
end

% update dimInfo using prop/val dimInfo
if hasPropValDimInfo
    this.dimInfo.update_and_validate_properties_from(propValDimInfo);
end

end

