function [this, affineGeometry] = load(this, inputDataOrFile, varargin)
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
%
% $Id$

if nargin < 2
    inputDataOrFile = this.get_filename();
end
defaults.select = [];

args = propval(varargin, defaults);
strip_fields(args);

isMatrix = isnumeric(inputDataOrFile) || islogical(inputDataOrFile);

if isMatrix
    this.read_matrix_from_workspace(inputDataOrFile, varargin{:})
else
    
    isExplicitFileArray = iscell(inputDataOrFile) && ischar(inputDataOrFile{1});
    
    if isExplicitFileArray
        fileArray = inputDataOrFile;
        % has to be determined otherwise...
        dimInfoExtra = MrDimInfo('dimLabels', {'file'}, 'samplingPoints', ...
            1:numel(fileArray));
    else
        fileArray = get_filenames(inputDataOrFile);
        
        % Determine between-file dimInfo from file name array
        dimInfoExtra = MrDimInfo();
        dimInfoExtra.get_from_filenames(fileArray);
        
        % remove singleton dimensions
        dimInfoExtra.remove_dims();
        
        % now use select to only load subset of files
        [selectDimInfo, selectIndexArray, unusedVarargin] = ...
            dimInfoExtra.select(select);
    end
    
    nFiles = numel(fileArray);
    
    %% Single file can be loaded individually
    if nFiles == 1
        % 2nd output argument is affine geometry, loaded here to not touch
        % the same file multiple times
        affineGeometry = this.read_single_file(fileArray{1});
    else
        %% load and concatenate multiple files
        
        tempDataNd = this.copyobj();
        tempDataNd.read_single_file(fileArray{1});
        tempDataNd.dimInfo.remove_dims();
        tempData = zeros([tempDataNd.dimInfo.nSamples, dimInfoExtra.nSamples]);
        
        %% data first
        for iFile = 1:nFiles
            fprintf('Loading File %d/%d\n', iFile, nFiles);
            fileName = fileArray{iFile};
            affineGeometry{iFile} = tempDataNd.read_single_file(fileName);
            resolutions = tempDataNd.dimInfo.resolutions;
            
            %% todo: generalize!
            [dimLabels, dimValues, pfx, sfx] = get_dim_labels_from_string(fileName);
            sli = dimValues(find_string(dimLabels,'sli'));
            dyn = dimValues(find_string(dimLabels,'dyn'));
            tempData(:,:,sli, dyn) = tempDataNd.data;
        end
        this.data = tempData;
        
        this.name = [pfx sfx];
        tempDataNd.dimInfo.remove_dims();
        
        %% combine dimInfos
        dimLabels = [tempDataNd.dimInfo.dimLabels dimInfoExtra.dimLabels];
        dimLabels = regexprep(dimLabels, 'sli', 'z');
        dimLabels = regexprep(dimLabels, 'm', 'x');
        dimLabels = regexprep(dimLabels, 'p', 's');
        nDims = numel(dimLabels);
        resolutions((end+1):nDims) = 1;
        units = [tempDataNd.dimInfo.units dimInfoExtra.units];
        this.dimInfo = MrDimInfo('dimLabels', dimLabels, 'units', units, 'nSamples', ...
            size(this.data), 'resolutions', resolutions);
        
        
        %% combine data, sort into right dimInfo-place
        %     this.dimInfo =
        %         this.append(tempDataNd);
    end
    
    %% Update affineGeometry
    % belongs into subclass method, but more easily dealt with here
    if isa(this, 'MrImage')
        this.affineGeometry = affineGeometry;
    end
    
end