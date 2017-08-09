function this = MrDimInfo_variant2(this)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   Y.run(MrDimInfo_variant2)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDimInfo_variant2
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
% Unit test for MrDimInfo Variant 2

% Initialize MrDimInfo via resolutions (variant (1) in MrDimInfo)
samplingPoints5D = ...
    {0:0.1:10, 0:10, 0:1:10, 0:1:10, 0:10};
expSolution = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', ''}, ...
    'samplingPoints', samplingPoints5D);

% Initialize MrDimInfo via nSamples + ranges (variant (2))
actSolution = MrDimInfo(...
    'dimLabels', expSolution.dimLabels, ...
    'units', expSolution.units, ...
    'nSamples', expSolution.nSamples, ...
    'ranges', expSolution.ranges);

% compare solutions
% import unittest constraints methods
import matlab.unittest.constraints.AbsoluteTolerance
import matlab.unittest.constraints.IsEqualTo
import matlab.unittest.constraints.PublicPropertyComparator

% verify eqaulity of actual and expected solution within an absolute
% Tolerance of 1e-6 using all public object fields (not the objects
% themselves)
verifyThat(this, ...
    actSolution, ...
    IsEqualTo(expSolution, 'Within', AbsoluteTolerance(1e-6), ...
    'Using', PublicPropertyComparator.supportingAllValues));

% compare solutions
% verifyEqual(this, ...
%     actSolution,...
%     expSolution);
end