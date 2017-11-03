function this = MrDimInfo_empty_input(this, emptyInput)
% Unit test for MrDimInfo Constructor with empty input (labels or units)
%
%   Y = MrUnitTest()
%   Y.run(MrDimInfo_empty_input)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDimInfo_empty_input
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-09-11
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

%% test empty units
% set parameters
arraySize   = [64 50 33 8 3];

% check whether empty labels or units are checke
switch emptyInput
    case 'dimLabels'
        dimLabels   = {'', '', '', '', ''};
        % Initialize MrDimInfo via nSamples + dimLabels
        dimInfoUnits = MrDimInfo(...
            'nSamples', arraySize, 'dimLabels', dimLabels);
        % set expected and actual solution
        actSolution = dimInfoUnits.dimLabels;
        expSolution = dimLabels;
    case 'units'
        units       = {'', '', '', '', ''};
        
        % Initialize MrDimInfo via nSamples + units
        dimInfoUnits = MrDimInfo(...
            'nSamples', arraySize, 'units', units);
        
        % set expected and actual solution
        actSolution = dimInfoUnits.units;
        expSolution = units;
end

% compare actual and expected solution
this.verifyEqual(actSolution, expSolution)

end




