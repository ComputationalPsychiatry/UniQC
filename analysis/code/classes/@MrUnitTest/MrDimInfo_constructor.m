function this = MrDimInfo_constructor(this)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   Y.run(MrDimInfo_constructor)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDimInfo_constructor
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-08-08
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
% Unit test for MrDimInfo Constructor via resolutions...
% (variant (1) in MrDimInfo)
samplingPoints5D = ...
    {-111:1.5:111, -111:1.5:111, -24:1.5:24, 0:0.65:300.3, 1:4};
dimInfo = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', ''}, ...
    'samplingPoints', samplingPoints5D);

% define actual solution
actSolution = dimInfo;
% load expected solution
classesPath = get_path('classes');
solutionFileName = fullfile(classesPath, '@MrUnitTest' , 'dimInfo.mat');
expSolution = load(solutionFileName);
expSolution = expSolution.dimInfo;
% compare solutions
verifyEqual(this, ...
    actSolution,...
    expSolution);
end