classdef CopyData < handle
    % Provides a common clone-method for all object classes, plus
    % generalized find, compare and print-capabilities
    %
    % based on a posting by Volkmar Glauche
    % http://www.mathworks.com/matlabcentral/fileexchange/22965-clone-handle-object-using-matlab-oop
    %
    % heavily modified and extended by Lars Kasper and Saskia Klein
    % 
    % Author:   Saskia Klein & Lars Kasper
    % Created:  2010-04-15
    % Copyright (C) 2014 Institute for Biomedical Engineering
    %                    University of Zurich and ETH Zurich
    %
    % This file is part of the Zurich fMRI Analysis Toolbox, which is released
    % under the terms of the GNU General Public Licence (GPL), version 3.
    % You can redistribute it and/or modify it under the terms of the GPL
    % (either version 3 or, at your option, any later version).
    % For further details, see the file COPYING or
    %  <http://www.gnu.org/licenses/>.
    %
    % $Id$
    properties
    end
    methods
        function this = CopyData()
        end
        
        function new = copyobj(obj, varargin)
            % This method acts as a copy constructor for all derived classes.
            %
            % new = obj.copyobj('exclude', {'prop1', 'prop2'});
            %
            % IN
            %   'exclude'           followed by cell(nProps,1) of property
            %                       names that should not be copied
            %                       NOTE: Properties of Class CopyObj are
            %                       always copied, even if they have a
            %                       name listed in this array
            defaults.exclude = {''};
            args = propval(varargin, defaults);
            strip_fields(args);
            exclude = cellstr(exclude);
            
            new = feval(class(obj)); % create new object of correct subclass.
            mobj = metaclass(obj);
            % Only copy properties which are
            % * not dependent or dependent and have a SetMethod
            % * not constant
            % * not abstract
            % * defined in this class or have public SetAccess - not
            % sure whether this restriction is necessary
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive deep copy
                    new.(pname) = ...
                        obj.(pname).copyobj('exclude', exclude);
                else
                    isPropCell = iscell(obj.(pname));
                    if isPropCell ...
                            && ~isempty(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:length(obj.(pname))
                            new.(pname){c} = ...
                                obj.(pname){c}.copyobj('exclude', exclude);
                        end
                    else
                        % if matrix named data, don't copy
                        isExcludedProp = ismember(pname, exclude);
                        if isExcludedProp
                            if isPropCell
                                new.(pname) = {};
                            else
                                new.(pname) = [];
                            end
                        else
                            new.(pname) = obj.(pname);
                        end
                        
                    end
                end
            end
        end
        
        function foundHandles = find(obj, nameClass, varargin)
            % Finds all (handle) object properties whose class and property
            % values match given values
            %   foundHandles = obj.find(nameClass, 'PropertyName',
            %                           'PropertyValue', ...)
            %
            %
            % IN
            %   nameClass       string with class name (default: CopyData)
            %   PropertyName/   pairs of string containing name of property
            %   PropertyValue   and value (or pattern) that has to be matched
            %
            % OUT
            %   foundHandles    cell(nHandles,1) of all object handles for
            %                   objects that match the properties
            %
            %                   NOTE: function also returns handle to
            %                   calling object, if its class and properties
            %                   fulfill the given criteria
            % 
            % EXAMPLE:
            %   Y = CopyData();
            %   Y.find('CopyData', 'name', 'coolCopy');
            %
            foundHandles = {};
            if nargin
                searchPropertyNames = varargin(1:2:end);
                searchPropertyValues = varargin(2:2:end);
                nSearchProperties = numel(searchPropertyNames);
                
            else
                nSearchProperties = 0;
            end
            
            % check whether object itself fulfills criteria
            if isa(obj, nameClass)
                
                doesMatchProperties = true;
                iSearchProperty = 1;
                
                % Check search properties as long as matching to values
                while doesMatchProperties && ...
                        iSearchProperty <= nSearchProperties
                    
                    searchProperty = searchPropertyNames{iSearchProperty};
                    searchValue = searchPropertyValues{iSearchProperty};
                    if isa(obj.(searchProperty), 'CopyData')
                        % recursive comparison for CopyData-properties
                        doesMatchProperties = obj.(searchProperty).comp(...
                            searchValue);
                    else
                        
                        doesMatchProperties = isequal(obj.(searchProperty), ...
                            searchValue);
                        
                        % allow pattern matching for strings
                        if ischar(obj.(searchProperty))
                            
                            % check whether pattern expression given, i.e.
                            % * in search value
                            isSearchPattern = ~isempty(strfind(searchValue, ...
                                '*'));
                            if isSearchPattern
                                doesMatchProperties = ~isempty(regexp( ...
                                    obj.(searchProperty), searchValue, 'once'));
                            end
                        end
                        
                    end
                    
                    iSearchProperty = iSearchProperty + 1;
                end
                
                if doesMatchProperties
                    foundHandles = [foundHandles; {obj}];
                end
            end
            
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                
                % Continue to check properties recursively for CopyData-properties
                if isa(obj.(pname), 'CopyData') % recursive comparison
                    newFoundHandles = obj.(pname).find(nameClass, varargin{:});
                    foundHandles = [foundHandles;newFoundHandles];
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:length(obj.(pname))
                            newFoundHandles = obj.(pname){c}.find(nameClass, varargin{:});
                            foundHandles = [foundHandles;newFoundHandles];
                        end
                    end
                end
            end
            % remove duplicate entries, if sub-object itself was returned and
            % as a property of super-object
           % foundHandles = unique(foundHandles);
        end
        
        function update_properties_from(obj, input_obj, overwrite)
            % Updates properties of obj for all non-empty values of inputpobj recursively ...
            %
            % obj.update_properties_from(input_obj, overwrite)
            %
            % IN
            % input_obj
            % overwrite     0, {1}
            %               0 = don't overwrite set values in obj; set empty values to set values in input_obj
            %               1 = overwrite all values in obj, which have non-empty values in input_obj;
            %
            % OUT
            % obj           updated obj w/ properties of input-obj
            if nargin < 3
                overwrite = 1;
            end
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive comparison
                    obj.(pname).update_properties_from ...
                        (input_obj.(pname), overwrite);
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) && iscell(input_obj.(pname)) ...
                            && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:min(length(obj.(pname)),length(input_obj.(pname)))
                            obj.(pname){c}.update_properties_from ...
                                (input_obj.(pname){c}, overwrite);
                            
                        end
                    end
                    if ~isempty(input_obj.(pname)) && (isempty(obj.(pname)) || overwrite)
                        obj.(pname) = input_obj.(pname);
                    end
                end
            end
        end
        
        function clear(obj)
            % Recursively sets all non-CopyData-objects to empty([])
            % to clear default values
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive comparison
                    obj.(pname).clear;
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) ...
                            && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:length(obj.(pname))
                            obj.(pname){c}.clear;
                        end
                    else
                        obj.(pname) = [];
                    end
                end
            end
        end
        
        function [isObjectEqual, out_left, out_right] = comp(obj, input_obj)
            % Returns non-empty properties where  obj and input_obj differ ...
            %
            % IN
            % input_obj
            %
            % OUT
            % out_left - holds values of obj, which differ from input_obj
            % out_right- holds values of input_obj, which differ from obj
            oc = obj.copyobj;
            ioc = input_obj.copyobj;
            out_left = obj.copyobj;
            out_right = input_obj.copyobj;
            isLeftObjectEqual = out_right.diff(oc);
            isRightObjectEqual = out_left.diff(ioc);
            
            isObjectEqual = isLeftObjectEqual & isRightObjectEqual;
        end
        
        function isObjectEqual = diff(obj, input_obj)
            % Sets all values of obj to [] which are the same in input_obj; i.e. keeps only the distinct differences in obj
            %
            % IN
            % input_obj     the input CopyData from which common elements are subtracted
            %
            % NOTE: empty values in obj, but not in input_obj remain empty,
            % so are not "visible" as different. That's why
            % obj.diff(input_obj) delivers different results from
            % input_obj.diff(obj)
            isObjectEqual = true;
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive comparison
                    isSubobjectEqual = obj.(pname).diff ...
                        (input_obj.(pname));
                    isObjectEqual = isObjectEqual & isSubobjectEqual;
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) && iscell(input_obj.(pname)) ...
                            && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:min(length(obj.(pname)),length(input_obj.(pname)))
                            isSubobjectEqual = obj.(pname){c}.diff ...
                                (input_obj.(pname){c});
                            isObjectEqual = isObjectEqual & isSubobjectEqual;
                        end
                    else
                        if ~isempty(input_obj.(pname)) && ~isempty(obj.(pname))
                            p = obj.(pname);
                            ip = input_obj.(pname);
                            % same strings?
                            if ischar(p)
                                isPropertyEqual = strcmp(p,ip); % property equals input property
                            elseif iscell(p)
                                % same cell of strings?
                                if ischar(p{1})
                                    isPropertyEqual = (length(p)==length(ip) && sum(strcmp(p,ip))==length(p));
                                else
                                    % same cell of numerical values?
                                    isPropertyEqual = (length(p)==length(ip) && sum(cell2mat(cellfun(@(x,y) ~any(x-y), p, ip, 'UniformOutput', false))));
                                end
                            else % same vector/matrix (size)?
                                isPropertyEqual = prod(double(size(p)==size(ip)));
                                if isPropertyEqual
                                    isPropertyEqual = ~any(p-ip);
                                end
                            end
                            if isPropertyEqual
                                obj.(pname) = [];
                            else
                                isObjectEqual = false;
                            end
                        end
                        
                    end
                end
            end
        end
        
        function s = print(obj, pfx, verbose)
            % Prints all non-empty values of a CopyData-object along with their
            % property name
            %
            % IN
            % verbose   {true} or false; if false, only the string is created, but no output to the command window
            %
            % OUT
            % s         cell of strings of reported non-empty values of CopyData-object
            %
            if nargin < 2
                pfx = '';
            end
            if nargin < 3
                verbose = true;
            end
            s = cell(0,2);
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                tmps = [];
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive comparison
                    tmps = obj.(pname).print([pfx '.' pname], verbose);
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) ...
                            && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:length(obj.(pname))
                            tmps2 = obj.(pname){c}.print([pfx '.' pname], verbose);
                            if ~isempty(tmps2), tmps = [tmps; tmps2]; end
                        end
                    else
                        p = obj.(pname);
                        if ~isempty(p)
                            tmps{1,1} = [pfx '.' pname];
                            if ischar(p)
                                tmps{1,2} = p;
                            elseif iscell(p)
                                if ischar(p{1})
                                    tmps{1,2} = sprintf('cell array %s ', p{1});
                                else
                                    tmps{1,2} = sprintf('cell array %f ', p{1});
                                end
                            else
                                pp = p(1,1:min(size(p,2), 16));
                                if (floor(double(pp(1)))==ceil(double(pp(1)))) %print integers differently
                                    tmps{1,2} = sprintf('%d ', pp);
                                else
                                    tmps{1,2} = sprintf('%4.2e ', pp);
                                end
                                if numel(p)>numel(pp), tmps{1,2} = [tmps{1,2}, '...']; end
                            end
                            if verbose
                                fprintf('%70s = %s\n', tmps{1,1}, tmps{1,2});
                            end
                        end
                    end
                end
                if ~isempty(tmps), s = [s; tmps]; end
            end
            
        end
        
        function s = print_diff(obj, input_obj, verbose)
            % Prints differing property names along with their values
            % IN
            % verbose   {true} or false; if false, only the string is created, but no output to the command window
            %
            % OUT
            % s         cell of strings of reported non-empty values of CopyData-object
            
            [out_left, out_right] = obj.comp(input_obj);
            if nargin  < 3
                verbose = true;
            end
            sl = out_left.print('',0);
            sr = out_right.print('',0);
            
            % find unique affected properties
            sUniqueProps = unique([sl(:,1); sr(:,1)]);
            nU = length(sUniqueProps);
            
            s = cell(nU,3);
            for c = 1:nU
                iL = find(strcmp(sUniqueProps{c}, sl(:,1)));
                iR = find(strcmp(sUniqueProps{c}, sr(:,1)));
                s{c,1} = sUniqueProps{c};
                if isempty(iL)
                    s{c,2} = '[]';
                else
                    s{c,2} = sl{iL,2};
                end
                if isempty(iR)
                    s{c,3} = '[]';
                else
                    s{c,3} = sr{iR,2};
                end
                if verbose
                    fprintf('%40s: %40s   VS   %s\n', s{c,1}, s{c,2}, s{c,3});
                end
            end
        end
    end
end