classdef MrCompare < CopyData
    % This class loads and compares different objects, e.g. images/rois
    %
    % In general, MrCompare relies on an existing compare-method for the
    % objects of its class
    %
    % EXAMPLE
    %   MrCompare
    %
    %   See also
    %
    % Author:   Saskia Klein & Lars Kasper
    % Created:  2014-12-11
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
    % $Id: new_class2.m 354 2013-12-02 22:21:41Z kasperla $
    
    properties
        % cell(nItems,1) holding handles to all data objects for comparison
        data = {};
        
        % [nComparisons,2] of dataset index pairs (referring to order in data)
        %                  that shall be compared
        % OR
        % cell(nComparisons,1) of index vectors for multidimensional comparisons
        compareSets = {};
        
        % function handle with which data is compared
        compareFunction = @compare;
        
        parameters.import.fileNameArray    = {};
        parameters.import.processIds       = []; % hmm...only needed for
    end % properties
    
    
    methods
        
        % Constructor of class
        function this = MrCompare()
        end
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
        
        function import(varargin)
            % Import data
            fileNameArray;
            processIdArray;  % (for MrSeries)
            
        end
        
        function run_comparisons()
        end
        
    end % methods
    
end