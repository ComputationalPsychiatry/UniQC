function this = propval_string(this)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   Y.propval_string(inputs)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   propval_string
%
%   See also MrUnitTest
 
% Author:   Matthias Mueller-Schrader
% Created:  2023-01-04
% Copyright (C) 2023 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

sizes = [3 4 5];
dimLabels = {'a','b','c'};
haveOldVersion = verLessThan('matlab','9.10'); % No f(arg=var)
% Use String
mri_string = MrImage(ones(sizes),"dimLabels",dimLabels);
% Use char
mri_char = MrImage(ones(sizes),'dimLabels',dimLabels);


S = warning('off', 'MATLAB:structOnObject');
if ~haveOldVersion
    mri_equal = MrImage(ones(sizes),dimLabels=dimLabels);
    S = warning('off', 'MATLAB:structOnObject'); % Here I know that it should be off...
    this.verifyEqual(struct(mri_equal), struct(mri_char));
end
this.verifyEqual(struct(mri_string), struct(mri_char));
warning(S.state, 'MATLAB:structOnObject');
    