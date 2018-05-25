function outputImage = apply_spm_method_on_many_4d_splits(this, ...
    methodHandle, representationIndexArray, varargin)
% Applies SPM-related method of MrImageSpm4D to a higher-dimensional MrImage ...
% using representational 4D images as representations for SPM to execute
% the method, runs a related method using the output parameters on the
% specified subsets of the MrImage
%
%   Y = MrImage()
%   outputImage = Y.apply_spm_method_on_many_4d_splits(this, ...
%                   methodHandle, representationIndexArray, ...
%                   'paramName', paramValue, ...)
%
% This is a method of class MrImage.
%
% Use case: Realigning the first echo of a multi-echo dataset, and applying
%           the realignmnent to all echoes
%
% NOTE:     Splitting into 4D MrImage is per default performed on all but
%           {'x','y','z','t'} dimensions
%
% IN
%   methodHandle
%                   function handle to method of MrImageSpm4D to be
%                   executed for parameter estimation
%   representationIndexArray
%                   either cell(nRepresentations,1) of MrImageSpm4D, on
%                   on which methodHandle should be executed individually
%                   OR
%                   cell(nRepresentations,1) of cells with selection
%                   dimLabel/dimValue pairs
%                   e.g., {{'coil', 1, 'echo',1}; ...; {'coil', 1,
%                   'echo',3}}
%                   if each echo shall be realigned separately
%
%   property Name/Value pairs:
%
%   methodParameters
%                   additional input parameters to that method
%   nOutputArguments
%                   default: 1
%                   number of output arguments of methodHandle that shall
%                   be transfered to applicationMethod
%   applicationIndexArray
%                   indices referring to the data chunks in representationIndexArray
%                   that shall be transformed by the same mapping SPM
%                   estimated for the those representatives
%
%   splitDimLabels  default: all but {'x','y','z',t'}
%
% OUT
%
% EXAMPLE
%   apply_spm_method_on_many_4d_splits
%
%   See also MrImage MrImage.realign MrImage.apply_spm_method_per_4d_split
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-22
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
defaults.methodParameters = {};
defaults.splitDimLabels = {};
defaults.nOutputArguments = 1;
defaults.applicationIndexArray = {};
defaults.applicationMethodHandle = {};

args = propval(varargin, defaults);

strip_fields(args);


%% create 4 SPM dimensions via complement of split dimensions
% if not specified, standard dimensions are taken
if isempty(splitDimLabels)
    dimLabelsSpm4D = {'x','y','z','t'};
else
    dimIndexSpm4D = setdiff(1:this.dimInfo.nDims, ...
        this.dimInfo.get_dim_index(splitDimLabels));
    
    % error, if split into 4D would not work...
    if numel(dimIndexSpm4D) ~= 4
        error('Specified split dimensions do not split into 4D images');
    else
        dimLabelsSpm4D = this.dimInfo.dimLabels(dimIndexSpm4D);
    end
end

%% one-on-many (estimation/application)
outputParameters = cell(1,nOutputArguments);

nRepresentations = numel(representationIndexArray);
imageArrayOut = cell(nRepresentations,1);
% empty applicationIndices in .select will select all data,
% and a split into all 4D subsets will be performed before application
if isempty(applicationIndexArray)
    applicationIndexArray = cell(nRepresentations,1);
end

% Loop to run first SPM method (methodHandle) for all specified
% representational 4D images
for iRepresentation = 1:nRepresentations
    representationIndex = representationIndexArray{iRepresentation};
    
    % already images given (e.g. after previous math operations) for estimation,
    % no selection necessary
    if isa(representationIndex, 'MrImage')
        representationImage = representationIndex.recast_as_MrImageSpm4D();
    else
        representationImage = this.select(representationIndex{:}).recast_as_MrImageSpm4D();
    end
    
    % get output parameters for the estimation of this representation (image)...
    
    [outputParameters{:}] = methodHandle(representationImage, methodParameters{:});
    
    % ...and apply these to all listed 4D sub-parts of the image, after
    % splitting into them
    applicationIndex = applicationIndexArray{iRepresentation};
    
    imageArrayApplication = ...
        this.select(applicationIndex{:}).split_into_MrImageSpm4D(dimLabelsSpm4D);
    
    nApplications = numel(imageArrayApplication);
    imageArrayOut{iRepresentation} = cell(nApplications,1);
    for iApplication = 1:nApplications
        imageArrayOut{iRepresentation}{iApplication} = applicationMethodHandle(...
            imageArrayApplication{iApplication}, outputParameters{:});
        
    end
    imageArrayOut{iRepresentation} = imageArrayOut{iRepresentation}{1}.combine(...
        imageArrayOut{iRepresentation});
end
outputImage = imageArrayOut{1}.combine(imageArrayOut);
end