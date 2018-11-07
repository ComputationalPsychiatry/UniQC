function this = MrImage_load_from_file(this, testCondition)
% Test loading from files for MrImage, in particular if additional
% parameters are given.
%
%   Y = MrUnitTest()
%   run(Y, MrImage_load_from_file)
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrImage_load_from_file
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-11-07
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

switch testCondition
    case '4DNifti'
        % 4D Nifti
        % actual solution
        dataPath = get_path('data');
        niftiFile4D = fullfile(dataPath, 'nifti', 'rest', 'fmri_short.nii');
        image = MrImage(niftiFile4D);
        % check poperties first
        % dimInfo
        % - assumes MrDimInfo(fileName) works and just verifies
        % that dimInfo is properly added to the object
        refDimInfo = MrDimInfo(niftiFile4D);
        if ~image.dimInfo.isequal(refDimInfo)
            this.assertFail('Failed to load or update dimInfo for MrImage.');
        end
        
        % imageGeometry
        % - assumes MrImageGeometry(fileName) works and just verifies
        % that imageGeometry is properly added to the object
        refImageGeom = MrImageGeometry(niftiFile4D);
        if ~image.geometry.isequal(refImageGeom)
            % the imageGeometry is created from dimInfo and affineTrafo, so
            % check MrAffineTrafo
            refAffineTrafo = MrAffineTransformation(niftiFile4D, image.dimInfo);
            if ~image.affineTransformation.isequal(refAffineTrafo)
                this.assertFail('Failed to load or update affineTrafo for MrImage.');
            else
                this.assertFail('Failed to compute imageGeometry for MrImage.');
            end
        end
        
        % data
        % - we don't want to save the whole matrix, so we just compare a
        % pre-computed hash
        md = java.security.MessageDigest.getInstance('MD5');
        actSolution = sprintf('%2.2x', typecast(md.digest(image.data(:)), 'uint8')');
        % pre-computed hash:
        expSolution = 'cc9db2c532989fc1b6585c38e2c66e68';
        
    case 'FilePlusDimLabelsUnits'
        
    case 'FilePlusResolutions'
        
    case 'FilePlussamplingWidths'
        
    case 'FilePlusSamplingPoints'
        
    case 'FilePlusShearRotation'
        
end

% verify equality
this.verifyEqual(actSolution, expSolution);

end
