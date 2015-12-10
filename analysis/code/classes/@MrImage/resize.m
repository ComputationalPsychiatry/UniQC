function this = resize(this, targetGeometry)
% resizes image to image size of other image
%
%   Y = MrImage()
%   Y.resize(targetGeometry)
%
% This is a method of class MrImage.
%
% IN
%   targetGeometry     object of MrImageGeometry
%                      Image will be resized to this geometry, i.e.
%
%
% OUT
%
% EXAMPLE
%   Y = MrImage();
%   Z = MrImage();
%   targetGeometry = Z.geometry;
%   Y.resize(targetGeometry)
%
%   See also MrImage MrImageGeometry spm_reslice spm_run_coreg
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-18
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

% Save as nifti to use spm functionality
this.save(this.get_filename('raw'));

if nargin < 2 % reslice to sth that does not need a header, i.e. voxel space = world space
   targetGeometry = MrImageGeometry;
   targetGeometry.nVoxels = this.geometry.nVoxels;
   targetGeometry.resolutionMillimeters = this.geometry.resolutionMillimeters;
 end

% check whether input is actually a geometry
isGeometry = isa(targetGeometry, 'MrImageGeometry');
if ~isGeometry, 
    if isa(targetGeometry, 'MrImage')
        targetGeometry = targetGeometry.geometry;
    else
        disp('Input has to be of class MrImage or MrImageGeometry.');
    end
end

[diffGeometry, isEqual, isEqualGeom3D] = targetGeometry.diffobj(this.geometry);

if ~isEqualGeom3D
    
    % Dummy 3D image with right geometry is needed for resizing
    emptyImage = targetGeometry.create_empty_image('selectedVolumes', 1);
    emptyImage.parameters.save.path = this.parameters.save.path;
    fnTargetGeometryImage = emptyImage.save();
    
    matlabbatch = this.get_matlabbatch('resize', fnTargetGeometryImage);
    save(fullfile(this.parameters.save.path, 'matlabbatch.mat'), ...
        'matlabbatch');
    spm_jobman('run', matlabbatch);
    
    % clean up: move/delete processed spm files, load new data into matrix
    this.finish_processing_step('resize', fnTargetGeometryImage);
end