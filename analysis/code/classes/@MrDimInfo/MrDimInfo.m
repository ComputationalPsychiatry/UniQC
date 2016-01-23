classdef MrDimInfo < MrCopyData
    % Holds all dimensionality info (r.g. range/labels/units) of multidimensional data
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
        nDims;     % number of dimensions in dataset, default: 6
        
        nElements; % vector [1,nDims] of number of elements per dimension
        
        % cell(1,nDims) of string labels for each dimension
        % default: {'x', 'y', 'z', 'volume', 'coil, 'echo'}
        labels;
        
        % cell(1,nDims) of strings describing unit; '' for unit-free dims
        % default: {'mm', 'mm', 'mm', 's', '', 'ms'};
        units;
        
        % cell (1,nDims) of resolutions for each dimension, i.e. distance (in
        % specified units) of adjacent elements, NaN for non-equidistant spacing
        % of elements
        resolutions;
        
        % cell(1,nDims) of index vectors for each dimension, [] for natural
        % indexing, i.e. indices{dim}(k) = range{dim}(1) + (k-1)*resolution{dim}
        % TODO: shall we rather call it indexLabels for clarity?
        indices;
        
        % cell(1,nDims) of [firstIndex, lastIndex] for each dimension
        % TODO: shall we first only/firs&last separate, since there is some
        % redundancy between resolutions, first and last index...
        ranges
        
    end % properties
    
    
    methods
        
        % Constructor of class, call via MrDimInfo('propertyName', propertyValue,
        % ...) syntax
        function this = MrDimInfo(varargin)
            defaults.nDims = [];
            defaults.nElements = [128, 128, 33, 600, 32, 3];
            defaults.labels = {'x', 'y', 'z', 'volume', 'coil', 'echo'};
            defaults.units = {'mm', 'mm', 'mm', 's', '1', 'ms'};
            defaults.resolutions = [1, 1, 1, 3, 1, NaN];
            defaults.indices = {[], [], [], [], [], []};
            defaults.ranges = {[0 220], [0 220], [0 220], [0 1000], [1 32], [15, 90]};
            args = propval(varargin, defaults);
            
            % apply changed input properties to object, but only for
            % specified dimension
            this.nDims = args.nDims;
            
            % if no dimensions given, estimated from length of nElements
            % array
            if isempty(this.nDims);
                this.nDims = numel(args.nElements);
            end
            
            properties = setdiff(fieldnames(args), 'nDims');
            for p = 1:numel(properties);
                this.(properties{p}) = args.(properties{p})(1:this.nDims);
            end
            
            
        end
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
        %
        
    end
    
end
