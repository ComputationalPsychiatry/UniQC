classdef CopyData < handle
    % provides a common clone-method for all object classes
    %
    % based on a posting by Volkmar Glauche
    % http://www.mathworks.com/matlabcentral/fileexchange/22965-clone-handle-object-using-matlab-oop
    %
    % kasper/ibt_2010/university and eth zurich, switzerland
    % $Id$
    methods
        function new = copyobj(obj)
            % This method acts as a copy constructor for all derived classes.
            %
            % new = obj.copyobj;
            %
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
                    new.(pname) = obj.(pname).copyobj;
                else
                    if iscell(obj.(pname)) ...
                        && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:length(obj.(pname))
                            new.(pname){c} = obj.(pname){c}.copyobj;
                        end
                    else
                        new.(pname) = obj.(pname);
                    end
                end
            end
        end
        
        function update_properties_from(obj, input_obj, overwrite)
            % updates properties of obj for all non-empty values of inputpobj recursively ...
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
            % recursively sets all non-CopyData-objects to empty([]) to clear default values
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
        
        function [out_left, out_right] = comp(obj, input_obj)
            % returns output objs which have only non-empty values where and input_obj differ ...
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
            out_right.diff(oc);
            out_left.diff(ioc);
        end
        
        function diff(obj, input_obj)
            % Sets all values of obj to [] which are the same in input_obj; i.e. keeps only the distinct differences in obj
            %
            % IN
            % input_obj     the input CopyData from which common elements are subtracted
            %
            % NOTE: empty values in obj, but not in input_obj remain empty,
            % so are not "visible" as different. That's why
            % obj.diff(input_obj) delivers different results from
            % input_obj.diff(obj)
            mobj = metaclass(obj);
            sel = find(cellfun(@(cProp)(~cProp.Constant && ...
                ~cProp.Abstract && ...
                (~cProp.Dependent || ...
                (cProp.Dependent && ...
                ~isempty(cProp.SetMethod)))),mobj.Properties));
            for k = sel(:)'
                pname = mobj.Properties{k}.Name;
                if isa(obj.(pname), 'CopyData') %recursive comparison
                    obj.(pname).diff ...
                        (input_obj.(pname));
                else
                    % cell of CopyData also treated
                    if iscell(obj.(pname)) && iscell(input_obj.(pname)) ...
                            && length(obj.(pname)) ...
                            && isa(obj.(pname){1}, 'CopyData')
                        for c = 1:min(length(obj.(pname)),length(input_obj.(pname)))
                            obj.(pname){c}.diff ...
                                (input_obj.(pname){c});
                        end
                    else
                        if ~isempty(input_obj.(pname)) && ~isempty(obj.(pname))
                            p = obj.(pname);
                            ip = input_obj.(pname);
                            % same strings?
                            if ischar(p)
                                p_eq_ip = strcmp(p,ip);
                            elseif iscell(p)
                                % same cell of strings?
                                if ischar(p{1})
                                    p_eq_ip = (length(p)==length(ip) && sum(strcmp(p,ip))==length(p));
                                else
                                    % same cell of numerical values?
                                    p_eq_ip = (length(p)==length(ip) && sum(cell2mat(cellfun(@(x,y) ~any(x-y), p, ip, 'UniformOutput', false))));
                                end
                            else % same vector/matrix (size)?
                                p_eq_ip = prod(double(size(p)==size(ip)));
                                if p_eq_ip
                                    p_eq_ip = ~any(p-ip);
                                end
                            end
                            if p_eq_ip
                                obj.(pname) = [];
                            end
                        end
                        
                    end
                end
            end
        end
        
        function s = print(obj, pfx, verbose)
            % prints all non-empty values of a CopyData-object along with their
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
            %             prints differing property names along with their values
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