function tapas_uniqc_new_method(varargin)
% tapas_uniqc_new_method creates a new method assuming that you are in the corresponding class
% folder; creates header using a template.
% tapas_uniqc_new_method(funname) opens the editor and pastes the content
% of a user-defined template into the file funname.m.
%
%   Example
%       tapas_uniqc_new_method myfunfun
%           OR
%       tapas_uniqc_new_method myfunfun author
%
%   opens the editor and pastes the following
%
% 	function output = myfunfun(input)
% 	%MYFUNFUN  One-line description here, please.
% 	%   output = myfunfun(input)
% 	%
% 	%   Example
% 	%   myfunfun
% 	%
% 	%   See also
%
% 	% Author: Your name
% 	% Created: 2005-09-22
% 	% Copyright 2005 Your company.
%
%   See also edit, mfiletemplate

% Author: Peter (PB) Bodin
% Created: 2005-09-22
% Modified: 2014-04-15 (Saskia Klein and Lars Kasper, IBT Zurich)


% See the variables repstr, repwithstr and tmpl to figure out how
% to design your own template.
% Edit tmpl to your liking, if you add more tokens in tmpl, make
% sure to add them in repstr and repwithstr as well.

% I made this function just for fun to check out some java handles to
% the editor. It would probably be better to fprintf the template
% to a new file and then call edit, since the java objects might change
% names between versions.

switch nargin
    case 0
        edit
        warning('new_method without argument is the same as edit')
        return;
    case 1
        fname=varargin{1};
        edit(fullfile(pwd,fname));
        authors = 'Saskia Bollmann & Lars Kasper'; %defuaults authors, set down in function authors
    case 2
        fname = varargin{1};
        authors = varargin{2};
    otherwise
        error('tapas:uniqc:TooManyInputArguments', ...
            'too many input arguments')
end

% determine class name from directory name
[~, classname] = fileparts(pwd);
classname = regexprep(classname, '@', '');

% open Matlab Editor instance (needs some java handling that is
% version-dependent) and fill with parsed template text
try
    edhandle=com.mathworks.mlservices.MLEditorServices;

    % R2009a => 2009.0, R2009b = 2009.5
    vs = version('-release');
    v = str2double(vs(1:4));
    if vs(5)=='b'
        v = v + 0.5;
    end

    if v < 2009.0
        edhandle.builtinAppendDocumentText(strcat(fname,'.m'),parse(fname, authors, classname));
    else

        try
            edhandle.getEditorApplication.getActiveEditor.appendText(parse(fname, authors, classname));
        catch % probably version R2022, but not confirmed
            matlab.desktop.editor.getActive().appendText(parse(fname, authors, classname));
        end

    end
catch ME
    rethrow(ME)
end

    function out = parse(func, authors, classname)
        
        tmpl={ ...
            'function this = $filename(this)'
            '%ONE_LINE_DESCRIPTION'
            '%'
            '%   Y = $classname()'
            '%   Y.$filename(inputs)'
            '%'
            '% This is a method of class $classname.'
            '%'
            '% IN'
            '%'
            '% OUT'
            '%'
            '% EXAMPLE'
            '%   $filename'
            '%'
            '%   See also $classname'
            ' '
            '% Author:   $author'
            '% Created:  $date'
            '% Copyright (C) $year $institute'
            '%                    $company'
            '%'
            '% This file is part of the TAPAS UniQC Toolbox, which is released'
            '% under the terms of the GNU General Public License (GPL), version 3. '
            '% You can redistribute it and/or modify it under the terms of the GPL'
            '% (either version 3 or, at your option, any later version).'
            '% For further details, see the file COPYING or'
            '%  <http://www.gnu.org/licenses/>.'
            };
        
        repstr={...
            '$classname'
            '$filename'
            '$FILENAME'
            '$date'
            '$year'
            '$author'
            '$institute'
            '$company'};
        
        repwithstr={...
            classname
            func
            upper(func)
            datestr(now,29)
            datestr(now,10)
            authors
            'Institute for Biomedical Engineering'
            'University of Zurich and ETH Zurich'};
        
        for k = 1:numel(repstr)
            tmpl = strrep(tmpl,repstr{k},repwithstr{k});
        end
        out = sprintf('%s\n',tmpl{:});
    end
end