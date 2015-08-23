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

% create dummy nifti of right image dimensions.
this.save(this.get_filename('raw'));

if nargin < 2 % reslice to sth that does not need a header, i.e. voxel space = world space
   targetGeometry = MrImageGeometry;
   targetGeometry.nVoxels = this.geometry.nVoxels;
   targetGeometry.offcenterMillimeters = this.geometry.offcenterMillimeters;
   targetGeometry.resolutionMillimeters = this.geometry.resolutionMillimeters;
   % targetGeometry.fovMillimeters = % just make it big enough...how?
end

% check whether input is actually a geometry
isGeometry = isa(targetGeometry, 'MrImageGeometry');
if ~isGeometry, disp('Input has to be of class MrImageGeometry.'); end
[diffGeometry, isEqualGeometry] = targetGeometry.diffobj(this.geometry);

% if only 4th geometry dimension is unequal between, no problem, no resize 
% necessary!
if ~isEqualGeometry
    fieldNamesDiff = diffGeometry.get_nonempty_fields;
    isEqualGeometry = numel(fieldNamesDiff) == 1 && ...
        strcmp(fieldNamesDiff{1}, 'nVoxels') && ...
        isequal(this.geometry.nVoxels(1:3), targetGeometry.nVoxels(1:3));
end

if ~isEqualGeometry
    Y = this.copyobj('exclude', 'data');
    Y.geometry = targetGeometry.copyobj;
    Y.geometry.nVoxels(4) = 1; % 3D image geometry is needed only for resizing
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