function this = set_dims(this, iDim, varargin)
% Sets dimension properties for specific dimension(s)...
%
%   Y = MrDimInfo()
%   Y.set_dims(inputs)
%
% This is a method of class MrDimInfo.
%
% set_dims is versatile in guessing missing values, e.g. by estimating
% actual sampling points from altered nSamples and resolutions, or shifting
% sampling points by given specific sampling point See demo_dim_info for
% details
%
% IN
%   iDim        (vector of) dimension index to be changed (e.g. 3 for 3rd
%               dimension) (nDims means length(iDim) here)
%   varargin    PropertyName/Value-pairs of MrDim-Info properties to be
%               changed, e.g. resolutions, nSamples, units etc.
%
%   Properties:
%
%   'units'           cell(1,nDims) of strings describing unit; '' for unit-free dims
%	'dimLabels'       cell(1,nDims) of string dimLabels for each changed dimension 
%
%
%   (1): 1st variant: explicit setting of sampling points for dimension(s)
%
%   'samplingPoints'  cell(1,nDims) of index vectors for each dimension
%
%
%   (2)-(6): Other variants depend on setting some of the following parameters
%
%   'nSamples'              [1, nDims] number of samples per dimension
%   'ranges'                [2, nDims] first and last sample per dimension
%   'resolutions'           [1, nDims] resolution (in units), i.e. spacing
%                           between sampling points per dimension
%
%   'arrayIndex'            index of samplingPoint to be set
%   'samplingPoint'         value of sampling point at position arrayIndex
%
%   'firstSamplingPoint'    special case of samplingPoint, arrayIndex = 1 set
%   'lastSamplingPoint'     special case of samplingPoint, arrayIndex = end set
%
%   Variants: 
%       (2) nSamples + ranges: sampling points computed automatically via 
%               samplingPoint(k) = ranges(1) + (ranges(2)-ranges(1))/nSamples*(k-1)
%       (3) nSamples + resolutions + samplingPoint + arrayIndex:
%               from samplingPoints(arrayIndex) = samplingPoints, others
%               are constructed via 
%               [...    samplingPoint-resolution
%                       samplingPoint
%                       samplingPoint+resolution ...] 
%               until nSamples are created in total.
%       (4) nSamples + resolutions + firstSamplingPoint: 
%               as (3), assuming arrayIndex = 1
%       (5) nSamples + resolutions + lastSamplingPoint: 
%               as (3), assuming arrayIndex = end
%       (6) nSamples Or resolution Or samplingPoint+arrayIndex
%               missing input value from variant (3)-(5) is taken from
%               existing entries in dimInfo
%               nSamples        -> resolution and first sampling point are used to
%                               create nSamples (equidistant)
%               resolution      -> nSamples and first sampling point are used to
%                               create new sampling-point spacing
%               samplingPoint   -> nSamples and resolution are used to
%                               create equidistant spacing of nSamples around 
%                               sampling point
%   
%
% OUT
%
% EXAMPLE
%   set_dims
%
%   See also MrDimInfo demo_dim_info
%
% Author:   Lars Kasper
% Created:  2016-01-28
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

isStringiDimInput = ischar(iDim) || (iscell(iDim) && ischar(iDim{1}));
if isStringiDimInput
    dimLabel = iDim;
    iDim = this.get_dim_index(dimLabel);
else
    dimLabel = num2str(iDim);
end

nDimsToSet = numel(iDim);
callForMultipleDimensions = nDimsToSet > 1;
if callForMultipleDimensions
    vararginDim = split_propval(varargin, nDimsToSet);
    % call dimension setting for each dimension individually
    % and with respective caller arguments
    for d  = 1:nDimsToSet
        this.set_dims(iDim(d), vararginDim{d}{:});
    end
    
elseif nDimsToSet==1 % no execution for empty dimensions
    
    % overwritten, only, if set
    defaults.units = [];
    defaults.dimLabels = [];
    defaults.samplingPoints = []; % direct input of sampling points for dimensions
    
    defaults.ranges = [];
    defaults.nSamples = [];
    
    defaults.resolutions = [];
    defaults.arrayIndex = [];
    defaults.samplingPoint = [];
    
    defaults.firstSamplingPoint = [];
    defaults.lastSamplingPoint = [];
   
    args = propval(varargin, defaults);
    strip_fields(args);
    
    if ~isempty(units)
        this.units{iDim} = units;
    else
        % if nothing set in object before, have a default...
        if isempty(this.units) || numel(this.units) < iDim
            defaultUnits6D = {'mm', 'mm', 'mm', 's', '', 'ms'};
            % to allow '' unit...which is a string, but empty :-)
            if numel(this.units) < iDim || ~ischar(this.units{iDim})
                this.units{iDim} = defaultUnits6D{iDim};
            end
        end
    end
    
    if ~isempty(dimLabels)
        this.dimLabels{iDim} = dimLabels;
    else
        % if nothing set in object before, have a default...
        if isempty(this.dimLabels) || numel(this.dimLabels) < iDim
            defaultDimLabels6D = {'x', 'y', 'z', 't', 'coil', 'echo'};
            this.dimLabels{iDim} = defaultDimLabels6D{iDim};
        end
    end
    
    % differentiate cases of varargin for different setting methods
    setDimByNsamplesAndRange = ~isempty(nSamples) && ~isempty(ranges);
    changeResolution = ~isempty(resolutions);
    changeNsamples = ~isempty(nSamples);
    hasExplicitSamplingPoints = ~isempty(samplingPoints);
    
    
    if ~hasExplicitSamplingPoints % otherwise, we are done already, and can set
        %% set_dims(iDim, ...
        % 'nSamples', nSamples, 'ranges', [firstSample, lastSample])
        if setDimByNsamplesAndRange
            samplingPoints = ...
                linspace(ranges(1), ranges(2), nSamples);
        else % all other cases depend (partly) on resolutions,
            % nSamples or specific reference sampling points
            
            % e.g. for changing one sampling point only, i.e.
            %shifting all sampling points
            % set_dims(iDim, 'arrayIndex', 3, 'samplingPoint', 24,
            % 'units', 'mm');
            if ~changeResolution
                % default resolution: 1...only occurs, if no samplingsPoints
                % given in object yet
                if isempty(this.resolutions) || numel(this.resolutions) < iDim
                    resolutions = 1;
                else
                    resolutions = this.resolutions(iDim);
                end
                
            end
            
            %% set_dims(iDim, ...
            % 'resolutions', 3) OR
            % set_dims(iDim, 'resolutions', 3, 'nSamples', 100)
            % => will keep first Sample of iDim and extend by new
            % resolution (and nSamples, if changed)
            if ~changeNsamples
                % two samples per dimension are needed to establish
                % resolution!
                if isempty(this.nSamples) || numel(this.nSamples) < iDim
                    nSamples = 2;
                else
                    nSamples = this.nSamples(iDim);
                end
            end
            
            % if no sampling point given, assume 1st ones to
            % be kept
            if isempty(samplingPoint)
                hasValidFirstSample = numel(this.samplingPoints) >= iDim && ...
                    ~isempty(this.samplingPoints{iDim}) && ...
                    isfinite(this.samplingPoints{iDim}(1)); % no nans/infs
                
                if hasValidFirstSample
                    samplingPoint = this.samplingPoints{iDim}(1);
                else
                    samplingPoint = 1;
                end
                arrayIndex = 1;
            end
            
            %% fix one sampling point, derive others via equidistant
            % spacing of resolution
            
            %% set_dims (iDim, ...
            % 'firstSamplingPoint', 4, 'resolutions', 3);
            
            % settings for special (first/last) sampling points
            if ~isempty(firstSamplingPoint)
                samplingPoint = firstSamplingPoint;
                arrayIndex = 1;
            end
            
            %% set_dims (iDim, ...
            % 'lastSamplingPoint', 4, 'resolutions', 3);
            if ~isempty(lastSamplingPoint)
                samplingPoint = lastSamplingPoint;
                arrayIndex = nSamples;
            end
            
            
            %[...   samplingPoint-resolution
            %       samplingPoint
            %       samplingPoint+resolution ...]
            samplingPoints(arrayIndex) = samplingPoint;
            samplingPoints(1:arrayIndex-1) = samplingPoint - ...
                resolutions*((arrayIndex-1):-1:1);
            samplingPoints((arrayIndex+1):nSamples) = samplingPoint + ...
                resolutions*(1:(nSamples-arrayIndex));
        end
    end
    
    this.samplingPoints{iDim} = samplingPoints;

else
    error('Dimension with label "%s" does not exist in %s', dimLabel, ...
        inputname(1));
end

end