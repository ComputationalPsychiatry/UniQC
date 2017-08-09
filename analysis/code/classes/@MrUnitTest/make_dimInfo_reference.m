function dimInfo = make_dimInfo_reference(this, varargin)
% create a dimInfo reference object for unit testing
%
%   Y = MrUnitTest()
%   Y.make_dimInfo_reference()
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   make_dimInfo_reference
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-08-09
% Copyright (C) 2017 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

% check if created object should be saved for unit testing
if nargin > 1
    do_save = varargin{1};
else
    do_save = 1;
end

% specify sampling points
samplingPoints5D = ...
    {-111:1.5:111, -111:1.5:111, -24:1.5:24, 0:0.65:300.3, [1, 2, 4]};
% creat dimInfo object
dimInfo = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', ''}, ...
    'samplingPoints', samplingPoints5D);
% get classes path
classesPath = get_path('classes');
% make full filename using date
filename = fullfile(classesPath, '@MrUnitTest' , ['dimInfo-' datestr(now, 'yyyymmdd_HHMMSS') '.mat']);
if do_save
    if exist(filename, 'file')
        prompt = 'Overwrite current MrDimInfo constructor reference object? Y/N [N]:';
        answer = input(prompt, 's');
        if strcmpi(answer, 'N')
            do_save = 0;
        end
    end
end
if do_save
    save(filename, 'dimInfo');
end
end