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
        % default: {'x', 'y', 'z', 'volume', 'coil, 'echo'}
        dimLabels;
        
        % cell(1,nDims) of strings describing unit; '' for unit-free dims
        % default: {'mm', 'mm', 'mm', 's', '', 'ms'};
        units;
        
        % cell(1,nDims) of index vectors for each dimension, [] for natural
        % indexing, i.e. samplingPoints{dim}(k) = range{dim}(1) + (k-1)*resolution{dim}
        % TODO: shall we rather call it indexLabels for clarity?
        samplingPoints;
        
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
        function this = MrDimInfo(varargin)
            
            % 1st constructor: dimLabels, units and samplingPoints
            % directly
            defaults.dimLabels = {'x', 'y', 'z', 't', 'coil', 'echo'};
            defaults.units = {'mm', 'mm', 'mm', 's', '1', 'ms'};
            defaults.samplingPoints = [];
            
            % split dim info into direct setting of parameters above, and
            % the arguments used by SetDims-Method
            [argsDimInfo, argsSetDims] = propval(varargin, defaults);
            
            % Find nSamples property, and corresponding value to determine
            % dimension
            iArgNsamples = find_string(argsSetDims(1:2:end), 'nSamples') + 1;
            
            hasNsamples = ~isempty(iArgNsamples);
            hasExplicitSamplingPoints = ~isempty(argsDimInfo.samplingPoints);
            
            properties = fieldnames(argsDimInfo);
            
            if ~hasExplicitSamplingPoints
                % will be determined separately e.g. by nSamples
                properties = setdiff(properties, 'samplingPoints');
                
                if hasNsamples
                    % otherwise, allow empty constructor for copyobj-functionality
                    nDims = numel(argsSetDims{iArgNsamples});
                    
                else
                    % find shortest given input to dimInfo and determine
                    % dimensionality from that
                    for p = 1:numel(properties);
                        nDims(p) = numel(argsDimInfo.(properties{p}));
                    end
                    nDims = min(nDims);
                end
                
                this.set_dims(1:nDims, argsSetDims{:});
                
                % ... do not overwrite just computed sampling-points later!
            end
            
            % set - for once - dimLabel/units in here, not within set_dims,
            % since handling is easier
            % also: explicit samplingPoints, if given
            for p = 1:numel(properties);
                this.(properties{p}) = argsDimInfo.(properties{p})(1:nDims);
            end
        end
        
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
        %
        function nDims = get.nDims(this)
            nDims = numel(this.nSamples);
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
                            %resolutions(iDim) = NaN;
                            resolutions(iDim) = this.samplingPoints{iDim};
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
            if isempty(this.samplingPoints)
                firstSamples = [];
            else
                
                firstSamples = cell2mat(cellfun(@(x) x(1), this.samplingPoints, ...
                    'UniformOutput', false));
                
                if nargin > 1
                    firstSamples = firstSamples(iDim);
                end
            end
        end
        
        % return last sampling point for all or given dimensions
        function lastSamples = last(this, iDim)
            if isempty(this.samplingPoints)
                lastSamples = [];
            else
                lastSamples = cell2mat(cellfun(@(x) x(end), this.samplingPoints, ...
                    'UniformOutput', false));
                
                if nargin > 1
                    lastSamples = lastSamples(iDim);
                end
            end
        end
        
        % return index of dimension(s) given by a dimension label string (or array of strings).
        function iDim = get_dim_index(this, dimLabel)
            iDim = find_string(this.dimLabels, dimLabel);
            if iscell(iDim)
                iDim = cell2mat(iDim)';
            end
            
        end
        
    end
    
end
