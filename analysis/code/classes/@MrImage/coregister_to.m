function [affineCoregistrationGeometry] = coregister_to(this, stationaryImage, ...
    applyTransformation)
% Coregister this MrImage to another given MrImage
% NOTE: Also does reslicing of image
%
%   Y = MrImage()
%   affineCoregistrationMatrix = Y.coregister_to(this, otherImage, ...
%               applyTransformation);
%
% This is a method of class MrImage.
%
% IN
%       stationaryImage  MrImage that serves as "stationary" or reference image
%                        to which this image is coregistered to
%       applyTransformation
%                   'geometry'      MrImageGeometry is updated,
%                                   MrImage.data remains untouched
%                   'data'          MrImage.data is resized to new
%                                   geometry
%                                   NOTE: An existing affine
%                                   transformation in MrImageGeometry will
%                                   also be applied to MrImage, combined
%                                   with the calculated one for
%                                   coregistration
%
%                   'none'          affine transformation matrix is
%                                   computed, but not applied to geometry of data of this
%                                   image
% OUT
%       affineCoregistrationGeometry  MrImageGeometry holding mapping from
%                                     stationary to transformed image
%
%
% EXAMPLE
%   Y = MrImage();
%   otherImage = MrImage();
%
%   co-registers Y to otherImage, i.e. changes geometry of Y
%   Y.coregister_to(otherImage);
%
%   See also MrImage spm_coreg
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-24
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

if nargin < 3
    applyTransformation = 'data';
end

% save data for spm as nifti
this.save();
fileStationaryImage = fullfile(this.parameters.save.path, 'rawStationary.nii');
stationaryImage.copyobj.save(fileStationaryImage);

matlabbatch = this.get_matlabbatch('coregister_to', fileStationaryImage);
save(fullfile(this.parameters.save.path, 'matlabbatch.mat'), ...
    'matlabbatch');

% NOTE: This job is not actually run to enable a clean separation of
% coregistration and re-writing of the object
% spm_jobman('run', matlabbatch);
% NOTE: The following lines are copied and modified from spm_run_coreg to
% enable a separation between computation and application of coregistration
% parameters
%
job = matlabbatch{1}.spm.spatial.coreg.estimate;

% Enable affine instead of rigid body registration by setting scaling of
% zoom-parameters to 1,1,1

job.eoptions.params = [0 0 0 0 0 0 1 1 1 0 0 0];
job.eoptions.sep = 4;
% Compute coregistration transformation
x  = spm_coreg(char(job.ref), char(job.source), job.eoptions);

% Apply coregistration, if specified, but leave raw image untouched!

fileProcessed = fullfile(this.parameters.save.path, ...
    this.parameters.save.fileProcessed);
this.save(fileProcessed);
job.source = cellstr(fileProcessed);

% header of stationary image:
% MatF voxel -> world
% header of transformed image:
% MatV voxel -> world
%
% transformation in spm_coreg:
% worldF -> worldF

%  mapping from voxels in G to voxels in F is attained by:
%           i.e. from reference to source:
%               G = reference
%               F = source
%
%         VF.mat\spm_matrix(x(:)')*VG.mat
% =       inv(VF.mat) * spm_matrix(x) * VG.mat
% A\B = inv(A) * B

affineCoregistrationMatrix = spm_matrix(x);
affineCoregistrationGeometry = MrImageGeometry(affineCoregistrationMatrix);

doUpdateGeometry = ismember(applyTransformation, {'data', 'geometry'});

if doUpdateGeometry
    this.geometry.apply_inverse_transformation(affineCoregistrationGeometry);
end


doResizeImage = strcmpi(applyTransformation, 'data');

if doResizeImage
    parametersSave = this.parameters.save;
    this.parameters.save.keepCreatedFiles = 1;
    this.parameters.save.fileUnprocessed = parametersSave.fileProcessed;
    this.parameters.save.fileProcessed = prefix_files(...
        parametersSave.fileProcessed, 'resized', 0, 1);
    this.resize(stationaryImage.geometry);
    % processed can be deleted, not needed any more if resizing finished
    fnOutputSpm = fullfile(parametersSave.path, ...
        this.parameters.save.fileProcessed);
    this.parameters.save = parametersSave;
else
    fnOutputSpm = {}; % nothing to be moved later on;
end

this.save(fileProcessed); % as processed.nii

% clean up: move/delete processed spm files, load new data into matrix

this.finish_processing_step('coregister_to', fileStationaryImage, ...
    fnOutputSpm);% run coregister job