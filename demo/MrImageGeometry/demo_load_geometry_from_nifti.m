
fileNifti = fullfile(get_path('examples'), 'nifti', 'rest', 'meanfmri.nii'); 

dimInfo = MrDimInfo(fileNifti); % origin at voxel [1 1 1]
affineGeometry = MrAffineGeometry(fileNifti); % scaling still has resolution)

%%

% make them consistent
affineGeometry.remove_scaling(dimInfo)

geometry = MrImageGeometry(dimInfo,affineGeometry);

% shifts origin of dimInfo into center of data block, puts scaling of
% affineGeom to 1, since it is reflected by dimInfo.resolutions
[this.dimInfo,this.affineGeometry] = geometry.convert_nifti_to_uniqc();

image.geometry -> set method of MrImage -> 
            MrImageGeometry(this.dimInfo, this.affineGeometry)