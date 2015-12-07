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

   targetGeometry.offcenterMillimeters = this.geometry.offcenterMillimeters;
   targetGeometry.resolutionMillimeters = this.geometry.resolutionMillimeters;
   
   % HACK for not missing any slices!
   factorIncrease = 1.5;
   targetGeometry.fovMillimeters = this.geometry.fovMillimeters;
   targetGeometry.fovMillimeters(3) = factorIncrease*targetGeometry.fovMillimeters(3);
   targetGeometry.nVoxels(3) = round(factorIncrease*targetGeometry.nVoxels(3));
   targetGeometry.offcenterMillimeters(3) = 2*targetGeometry.offcenterMillimeters(3);
   % targetGeometry.fovMillimeters = % just make it big enough...how?
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
    Y = this.copyobj('exclude', 'data');
    Y.geometry = targetGeometry.copyobj;
    Y.geometry.nVoxels(4) = 1;
    Y.data = zeros(Y.geometry.nVoxels);
    Y.parameters.save.fileName = 'dummyTargetGeometry.nii';
    fnTargetGeometry = Y.save();
    
    matlabbatch = this.get_matlabbatch('resize', fnTargetGeometry);
    save(fullfile(this.parameters.save.path, 'matlabbatch.mat'), ...
        'matlabbatch');
    spm_jobman('run', matlabbatch);
    
    % clean up: move/delete processed spm files, load new data into matrix
    this.finish_processing_step('resize', fnTargetGeometry);
end