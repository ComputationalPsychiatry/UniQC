
fileNifti = fullfile(get_path('examples'), 'nifti', 'rest', 'meanfmri.nii'); 

dimInfo = MrDimInfo(fileNifti); % origin at voxel [1 1 1]
affineGeometry = MrAffineGeometry(fileNifti); % scaling still has resolution)
affineGeometryOrig = MrAffineGeometry(fileNifti);
%%
ADimInfo = dimInfo.get_affine_matrix;
affineGeometry.update_from_affine_matrix(affineGeometry.affineMatrix/ADimInfo)

geometry = MrImageGeometry(dimInfo,affineGeometry);

geometry.resolution_mm - affineGeometryOrig.scaling
geometry.shear - affineGeometryOrig.shear
geometry.rotation_deg - affineGeometryOrig.rotation_deg
geometry.offcenter_mm - affineGeometryOrig.offcenter_mm

% shifts origin of dimInfo into center of data block, puts scaling of
% affineGeom to 1, since it is reflected by dimInfo.resolutions
[this.dimInfo,this.affineGeometry] = geometry.convert_nifti_to_uniqc();

image.geometry -> set method of MrImage -> 
            MrImageGeometry(this.dimInfo, this.affineGeometry)