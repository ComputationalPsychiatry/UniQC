function this = MrImageGeometry_load_from_file(this)
% Unit test for MrImageGeometry Constructor from file
%
%   Y = MrUnitTest()
%   run(Y, 'MrImageGeometry_load_from_file')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrImageGeometry_load_from_file
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-01-17
% Copyright (C) 2018 Institute for Biomedical Engineering
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

% Unit test for MrImageGeometry Constructor loading from different example files

switch testFile
    case '3DNifti'
        % 3D Nifti
        % actual solution
        dataPath = get_path('data');
        niftiFile3D = fullfile(dataPath, 'nifti', 'rest', 'meanfmri.nii');
        actSolution = MrDimInfo(niftiFile3D);
        % expected solution
        % get classes path
        classesPath = get_path('classes');
        