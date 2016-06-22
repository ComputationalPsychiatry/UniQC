classdef MrDimInfo < MrCopyData
    % Holds all dimensionality info (r.g. range/dimLabels/units) of multidimensional data
    %
    %
    % EXAMPLE
    %   MrDimInfo
    %
    %   See also MrImage.select
    %
    % Author:   Saskia Bollmann & Lars Kasper
    % Created:  2016-01-23
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
        % cell(1,nDims) of string dimLabels for each dimension
        % default: {'x', 'y', 'z', 't', 'coil, 'echo'}
        dimLabels;
        
        % cell(1,nDims) of strings describing unit; '' for unit-free dims
        % default: {'mm', 'mm', 'mm', 's', '', 'ms'};
        units;
        
        % cell(1,nDims) of sampling position vectors for each dimension
        samplingPoints;
        
        % cell(1,nDims) of sampling width vectors for each dimension
        % Note: Typically, this will correspond to diff(samplingPoints);
        % However, if sampling does not cover the full interval between
        % consecutive points, it should be noted here
        samplingWidths = {};
        
    end
    
    % the following properties can be fully derived from sampling points,
    % but are stored for convenience
    properties (Dependent)
        nDims;      % number of dimensions in dataset, default: 6
        
        nSamples;   % vector [1,nDims] of number of elements per dimension
        
        % cell (1,nDims) of resolutions for each dimension, i.e. distance (in
        % specified units) of adjacent elements, NaN for non-equidistant spacing
        % of elements
        resolutions;
        
        
        % cell(1,nDims) of [firstIndex, lastIndex] for each dimension
        % TODO: shall we first only/firs&last separate, since there is some
        % redundancy between resolutions, first and last index...
        ranges
        
    end % properties
    
    
    methods
        
        % Constructor of class, call via MrDimInfo('propertyName', propertyValue,
        % ...) syntax
        % See also MrDimInfo.set_dims
        %
        % IN
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
        function this = MrDimInfo(varargin)
            
            propertyNames = varargin(1:2:end);
            propertyValues = varargin(2:2:end);
            % Find nSamples property, and corresponding value to determine
            % dimension
            iArgNsamples = find_string(propertyNames, 'nSamples');
            iArgSamplingPoints = find_string(propertyNames, 'samplingPoints');
            
            hasNsamples = ~isempty(iArgNsamples);
            hasExplicitSamplingPoints = ~isempty(iArgSamplingPoints);
            
            
            if hasExplicitSamplingPoints
                nDims = numel(propertyValues{iArgSamplingPoints});
            elseif hasNsamples
                % otherwise, allow empty constructor for copyobj-functionality
                nDims = numel(propertyValues{iArgNsamples});
            else % guessed number of update dimensions
                % find shortest given input to dimInfo and determine
                % dimensionality from that
                nDims =[];
                for p = 1:numel(propertyNames);
                    nDims(p) = numel(propertyValues{p});
                end
                nDims = min(nDims);
            end
            
            % allows empty constructor for copyobj
            if ~isempty(nDims)
                this.set_dims(1:nDims, varargin{:});
            end
        end
        
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
        %
        function nDims = get.nDims(this)
            nDims = numel(this.nSamples);
        end
        
        function this = set.nDims(this, nDimsNew)
            nDimsOld = this.nDims;
            
            if nDimsNew > nDimsOld
                this.add_dims((nDimsOld+1):nDimsNew)
            elseif nDimsNew < nDimsOld
                this.removeDims((nDimsNew+1):nDimsOld);
            end
        end
        
        % Changes nSamples by keeping given resolution and adding samples
        % at end of samplingPoints-vectors
        % TODO: Is this expected behavior?
        function this = set.nSamples(this, nSamplesNew)
            nSamplesOld = this.nSamples;
            if numel(nSamplesNew) ~= numel(nSamplesOld)
                error('nDims cannot change via nSamples, use add_dims instead');
            end
            
            iChangedDims = find(nSamplesOld ~= nSamplesNew);
            
            for iDim = iChangedDims
                nOld = nSamplesOld(iDim);
                nNew = nSamplesNew(iDim);
                if nOld > nNew
                    this.samplingPoints{iDim}((nNew+1):end) = [];
                else
                    if nOld == 0 % no samples before, create all new
                        offset = 0;
                    else % start samples from last existing
                        offset = this.samplingPoints{iDim}(nOld);
                    end
                    
                    % set default resolution to 1 for adding samples
                    res = this.resolutions(iDim);
                    if isnan(res)
                        res = 1;
                    end
                    
                    this.samplingPoints{iDim}((nOld+1):nNew) = ...
                        offset + (1:(nNew-nOld))*res;
                end
            end
            
        end
        
        function nSamples = get.nSamples(this)
            if isempty(this.samplingPoints)
                nSamples = [];
            else
                nSamples = cell2mat(cellfun(@numel, this.samplingPoints, ...
                    'UniformOutput', false));
            end
        end
        
        function resolutions = get.resolutions(this)
            if isempty(this.samplingPoints)
                resolutions = [];
            else
                
                for iDim = 1:this.nDims
                    res = unique(diff(this.samplingPoints{iDim}));
                    switch numel(res)
                        case 0 % one element samplingPoints, take its value (?)
                            if ~isempty(this.samplingWidths) && ...
                                    numel(this.samplingWidths) >= iDim && ...
                                    ~isempty(this.samplingWidths{iDim})
                                resolutions(iDim) = this.samplingWidths{iDim};
                            else
                                resolutions(iDim) = NaN;
                            end
                            % resolutions(iDim) = this.samplingPoints{iDim};
                        case  1 % single resolution, return it
                            resolutions(iDim) = res;
                        otherwise % if no unique resolution,
                            % first check if within single floating precision,
                            % accept that as same!
                            if max(abs(diff(res))) < eps(single(1))
                                resolutions(iDim) = mean(res);
                            else
                                %  otherwise, really non-equidistant spacing, return NaN for this
                                %  dim
                                resolutions(iDim) = NaN;
                            end
                    end
                end
            end
        end
        
        function ranges = get.ranges(this)
            ranges = [first(this); last(this)];
        end
        
        function firstSamples = first(this, iDim)
            if nargin < 2
                iDim = 1:this.nDims;
            end
            
            firstSamples = [];
            for d = iDim
                if isempty(this.samplingPoints{d})
                    firstSamples(end+1) = NaN;
                else
                    firstSamples(end+1) = this.samplingPoints{d}(1);
                end
            end
            
        end
        
        % return last sampling point for all or given dimensions
        function lastSamples = last(this, iDim)
            if nargin < 2
                iDim = 1:this.nDims;
            end
            
            lastSamples = [];
            for d = iDim
                if isempty(this.samplingPoints{d})
                    lastSamples(end+1) = NaN;
                else
                    lastSamples(end+1) = this.samplingPoints{d}(end);
                end
            end
        end
        
        % return index of dimension(s) given by a
        % IN
        %   dimLabel  dimension label string (or array of strings).
        %             or dimension number or cell of dim numbers (for
        %             compatibility)
        %
        % OUT
        %   iDim            index of dimension with corresponding label
        %   isValidLabel    [nLabels,1] returns for each given label 1/0
        %                   i.e. whether it is indeed a label of dimInfo
        function [iDim, isValidLabel] = get_dim_index(this, dimLabel)
            
            if isnumeric(dimLabel) % (vector of) numbers
                iDim = dimLabel;
                % cell of numbers:
            elseif iscell(dimLabel) && isnumeric(dimLabel{1})
                iDim = cell2num(dimLabel);
            else % string or cell of strings
                isExact = 1;
                iDim = find_string(this.dimLabels, dimLabel, isExact);
                if iscell(iDim)
                    isValidLabel = ~cellfun(@isempty, iDim);
                    iDim = iDim(isValidLabel); % remove unfound dimensions;
                    iDim = cell2mat(iDim)';
                else
                    isValidLabel = ~isempty(iDim);
                end
            end
        end
        
    end
    
end
