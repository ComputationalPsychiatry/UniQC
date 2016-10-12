classdef MrDataNd < MrCopyData
% Class for n-dimensional data representation with dimensional information,
% selection, plotting and general unary and binary arithmetic operations
%
%
% EXAMPLE
%   MrDataNd('test.nii');
%   MrDataNd(dataMatrix, 'dimInfo', myDimInfo);
%
%   See also MrImage MrDimInfo
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2016-04-03
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

properties
   % Parameter Structure about image data storage
        parameters = struct( ...
            'save', struct( ...
            'path', './zFatTmp', ...  % path where disk files can be stored temporarily
            'fileName', 'MrDataNd.mat', ... %  file name for saving
            'keepCreatedFiles', 'none' ... % 'none', 'all', 'processed' keep temporary files on disk after method finished
            ) ...
            );

        % cell(nRows,1) of strings with detailed image information, e.g.
        % previous processing steps to arrive at that image
        % (masking/thresholding...)
        % 'detailed image information'; 'given in cell strings'
        info    = {};
        
        % A short string identifier of the image, used e.g. as plot-title
        name    = 'MrDataNd';
        
        data    = []; % nX*nY*nZ*nVolumes...etc N-Dimensional data matrix
         
       % Dimensionality information about image (names of dimensions,
        % units, array size, sampling-points, also for n-dimensional data,
        % e.g. echo times, coil indices)
        dimInfo  = []; % see also MrDimInfo                
      
    end % properties
 
 
methods

% Constructor of class
%   Y = MrDataNd(fileName, 'propertyName', propertyValue, ...); 
% OR
%   Y = MrDataNd(dataMatrix, 'propertyName', propertyValue, ...);
% OR
%   Y = MrDataNd(fileNameCellArray, 'propertyName', propertyValue, ...);
% OR
%   Y = MrDataNd(fileNameSearchString, 'propertyName', propertyValue, ...);
%
function this = MrDataNd(inputDataOrFile, varargin)
    
    % transfer all properties given as name/value pairs to object
    this@MrCopyData(varargin{:});
    
    % check whether valid dimInfo now
    hasDimInfo = isa(this.dimInfo, 'MrDimInfo');
    
    hasInputDataOrFile = nargin >= 1;
    
    if hasInputDataOrFile
        hasInputData = inumeric(inputDataOrFile) || islogical(inputDataOrFile);
        hasInputFiles = ~hasInputData;
    else
        hasInputData = false;
        hasInputFiles = false;
    end
    
    if hasInputData
        this.data = inputDataOrFile;
    end
    
    % remove singleton 2nd dimension kept by size command
    nSamples = size(this.data);
    if numel(nSamples) == 2
        nSamples(nSamples==1) = [];
        resolutions = ones(1, numel(nSamples));
    end
        
    % set dimInfo or update according to actual number of samples
    if hasDimInfo
        this.dimInfo = MrDimInfo('nSamples', nSamples, ...
            'resolutions', resolutions);
    else
        if any(nSamples) % only update dimInfo, if any samples loaded
            if numel(nSamples) ~= this.dimInfo.nDims
                error('Number of dimensions in dimInfo (%d) does not match dimensions in data (%d)', ...
                    this.dimInfo.nDims, numel(nSamples));
            else
                this.dimInfo.set_dims(1:this.dimInfo.nDims, 'nSamples', nSamples);
            end
        end
    end
    
    % save path
    stringTime = datestr(now, 'yymmdd_HHMMSS');
    pathSave = fullfile(pwd, ['MrDataNd_' stringTime]);
    this.parameters.save.path = pathSave;

    % load data, and update dimInfo
    if nargin >=1
        this.load(inputDataOrFile, varargin{:});
    end
    
end

% NOTE: Most of the methods are saved in separate function.m-files in this folder;
%       except: constructor, delete, set/get methods for properties.

end % methods
 
end
