
fileNifti = fullfile(get_path('examples'), 'nifti', 'rest', 'meanfmri.nii'); 

dimInfo = MrDimInfo(fileNifti); % origin at voxel [1 1 1]
affineGeometry = MrAffineTransformation(fileNifti); % scaling still has resolution)
affineGeometryOrig = MrAffineTransformation(fileNifti);
%% by hand
ADimInfo = dimInfo.get_affine_matrix;
affineGeometry.update_from_affine_matrix(affineGeometry.affineMatrix/ADimInfo)

geometry = MrImageGeometry(dimInfo,affineGeometry);

geometry.resolution_mm - affineGeometryOrig.scaling
geometry.shear - affineGeometryOrig.shear
geometry.rotation_deg - affineGeometryOrig.rotation_deg
geometry.offcenter_mm - affineGeometryOrig.offcenter_mm

%% now in MrAffineTransformation
clear affineGeometry
affineGeometry = MrAffineTransformation(fileNifti, dimInfo);
geometry2 = MrImageGeometry(dimInfo, affineGeometry);
geometry2.isequal(geometry);

% try with affine matrix as well
affineGeometry2 = MrAffineTransformation(affineGeometryOrig.affineMatrix, dimInfo);
geometry3 = MrImageGeometry(affineGeometry2, dimInfo);
geometry.isequal(geometry3);

%% Shift origin
% shifts origin of dimInfo into center of data block, puts scaling of
% affineGeom to 1, since it is reflected by dimInfo.resolutions
origAffineGeom = geometry.get_affine_matrix;
dimIndex = [dimInfo.get_dim_index('x'), dimInfo.get_dim_index('y'), dimInfo.get_dim_index('z')];
nSamples = dimInfo.nSamples(dimIndex);

dimInfo.set_dims(dimIndex, 'arrayIndex', {1:nSamples(1), 1:nSamples(2), 1:nSamples(3)}, ...
    'samplingPoints', cellfun(@minus, dimInfo.samplingPoints(dimIndex), ...
    num2cell(geometry.FOV_mm/2), 'UniformOutput', 0));

ADimInfo = dimInfo.get_affine_matrix;
affineGeometry.update_from_affine_matrix(origAffineGeom/ADimInfo);
geometry4 = MrImageGeometry(affineGeometry, dimInfo);
geometry.isequal(geometry4)


[this.dimInfo,this.affineGeometry] = geometry.convert_nifti_to_uniqc();


image.geometry -> set method of MrImage -> 
            MrImageGeometry(this.dimInfo, this.affineGeometry)