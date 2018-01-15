function this = MrAffineGeometry_load_from_file(this, testFile)
% Unit test for MrAffineGeometry Constructor from file
%
%   Y = MrUnitTest()
%   Y.MrAffineGeometry_load_from_file(inputs)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrAffineGeometry_load_from_file
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-11-30
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
 
% Unit test for MrDimInfo Constructor loading from different example files

doVerify = true;

switch testFile
    case '3DNifti'
        % 3D Nifti
        % actual solution
        dataPath = get_path('data');
        niftiFile3D = fullfile(dataPath, 'nifti', 'rest', 'meanfmri.nii');
        actSolution = MrAffineGeometry(niftiFile3D);
        % expected solution
        % get classes path
        classesPath = get_path('classes');
        expSolution = load(fullfile(classesPath, '@MrUnitTest' , ...
            'affineGeom-meanfmri20171130_174524.mat'));
        expSolution = expSolution.affineGeom;
    case '4DNifti'
        % 4D Nifti
        % actual solution
        dataPath = get_path('data');
        niftiFile4D = fullfile(dataPath, 'nifti', 'rest', 'fmri_short.nii');
        actSolution = MrAffineGeometry(niftiFile4D);
        % expected solution
        % get classes path
        classesPath = get_path('classes');
        expSolution = load(fullfile(classesPath, '@MrUnitTest' , ...
            'affineGeom-fmri_short20171130_174616.mat'));
        expSolution = expSolution.affineGeom;
    case 'ParRec'
        % par/rec data
        % actual solution
        dataPath = get_path('data');
        % par/rec
        parRecFile = fullfile(dataPath, 'parrec', 'rest_feedback_7T', 'fmri1.par');
        actSolution = MrAffineGeometry(parRecFile);
        % expected solution
        % get classes path
        classesPath = get_path('classes');
        expSolution = load(fullfile(classesPath, '@MrUnitTest' , ...
            'affineGeom-fmri120171130_174717.mat'));
        expSolution = expSolution.affineGeom;
    otherwise
        doVerify = false;
end

if doVerify
    this.verifyEqual(actSolution, expSolution, 'absTol', 10e-7);
end

end
