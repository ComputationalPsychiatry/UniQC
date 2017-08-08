function this = MrDimInfo_constructor_with_struct(this)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   Y.run(MrDimInfo_constructor_with_struct)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDimInfo_constructor_with_struct
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
% Unit test for MrDimInfo Constructor via resolutions (warning off)
% (variant (1) in MrDimInfo)
samplingPoints5D = ...
    {-111:1.5:111, -111:1.5:111, -24:1.5:24, 0:0.65:300.3, [1, 2, 4]};
dimInfo = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', ''}, ...
    'samplingPoints', samplingPoints5D);
dimInfo2 = MrDimInfo(...
    'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
    'units', {'mm', 'mm', 'mm', 's', ''}, ...
    'samplingPoints', samplingPoints5D);
% define actual solution
% warning off for struct to object
warning('off', 'MATLAB:structOnObject');
actSolution = struct(dimInfo);
% define expected solution
expSolution = struct(dimInfo2);
% warning on for struct to object
warning('on', 'MATLAB:structOnObject')
% compare solutions
verifyEqual(this, ...
    actSolution,...
    expSolution);


end