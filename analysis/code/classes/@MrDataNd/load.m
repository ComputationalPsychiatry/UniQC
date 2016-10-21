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
%   select      for efficient loading of a data subset, a selection of
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
defaults.selection = [];

args = propval(varargin, defaults);
strip_fields(args);

isMatrix = isnumeric(inputDataOrFile) || islogical(inputDataOrFile);

if isMatrix
   this.load_matrix(inputDataOrFile, varargin{:}) 
else
    fileArray = get_filenames(inputDataOrFile);
    
    dimInfo = get_dim_info_from_filenames(fileArray);
    
    % now use selection to only load subset of files
   [selectionDimInfo, selectionIndexArray, unusedVarargin] = ...
       dimInfo.select(selection);
    
    nFiles = numel(fileArray);%???
    for iFile = 1:nFiles
        fileName = fileArray(nFiles);
        tempDataNd = this.copyobj(); % really?
        tempDataNd.read_single_file(fileName);
        
        this.append(tempDataNd);
    end
    
end