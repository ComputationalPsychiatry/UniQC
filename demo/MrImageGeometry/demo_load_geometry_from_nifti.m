% Script demo_load_geometry_from_nifti
% load geometry from nifti
%
%  demo_load_geometry_from_nifti
%
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-10-18
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>. 

fileNifti = fullfile(get_path('examples'), 'nifti', 'rest', 'meanfmri.nii'); 

dimInfo = MrDimInfo(fileNifti); % origin at voxel [1 1 1]
affineTransformation = MrAffineTransformation(fileNifti); % scaling still has resolution)
affineTransformationOrig = MrAffineTransformation(fileNifti);
%% by hand
ADimInfo = dimInfo.get_affine_matrix;
affineTransformation.update_from_affine_matrix(affineTransformation.affineMatrix/ADimInfo)

geometry = MrImageGeometry(dimInfo,affineTransformation);

geometry.resolution_mm - affineTransformationOrig.scaling
geometry.shear - affineTransformationOrig.shear
geometry.rotation_deg - affineTransformationOrig.rotation_deg
geometry.offcenter_mm - affineTransformationOrig.offcenter_mm

%% now in MrAffineTransformation
clear affineTransformation
affineTransformation = MrAffineTransformation(fileNifti, dimInfo);
geometry2 = MrImageGeometry(dimInfo, affineTransformation);
geometry2.isequal(geometry);

% try with affine matrix as well
affineTransformation2 = MrAffineTransformation(affineTransformationOrig.affineMatrix, dimInfo);
geometry3 = MrImageGeometry(affineTransformation2, dimInfo);
geometry.isequal(geometry3);

%% Shift origin
% shifts origin of dimInfo into center of data block, puts scaling of
% affineGeom to 1, since it is reflected by dimInfo.resolutions
origAffineGeom = geometry.get_affine_matrix;
dimIndex = dimInfo.get_dim_index({'x', 'y', 'z'});
nSamples = dimInfo.nSamples(dimIndex);

% shift samplingPoints = samplingPoints - FOV_mm/2
% keep resolution fixed

% TODO: think about odd and even number of Samples for res/2 shift
dimInfo.set_dims(dimIndex, ...
    'firstSamplingPoint', -geometry.FOV_mm/2 + geometry.resolution_mm/2, ...
    'resolutions', dimInfo.resolutions(dimIndex));

ADimInfo = dimInfo.get_affine_matrix;
affineTransformation.update_from_affine_matrix(origAffineGeom/ADimInfo);
geometry4 = MrImageGeometry(affineTransformation, dimInfo);
geometry.isequal(geometry4)


[this.dimInfo,this.affineTransformation] = geometry.convert_nifti_to_uniqc();

% 
% image.geometry -> set method of MrImage -> 
%             MrImageGeometry(this.dimInfo, this.affineTransformation)