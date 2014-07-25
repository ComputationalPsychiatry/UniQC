function affineCoregistrationMatrix = coregister_to(this, stationaryImage, ...
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

% spm_jobman('run', matlabbatch);
% NOTE: The following lines are copied and modified from spm_run_coreg to
% enable a separation between computation and application of coregistration
% parameters
%
job = matlabbatch{1}.spm.spatial.coreg.estimate;

% enable affine instead of rigid body registration by setting scaling of
% zoom-parameters to 1,1,1

% Compute coregistration transformation
job.eoptions.params = [0 0 0 0 0 0 1 1 1 0 0 0];
x  = spm_coreg(char(job.ref), char(job.source), job.eoptions);

% Apply coregistration, if specified
switch applyTransformation
    case 'geometry'
    case 'data'
        PO = [job.source(:); job.other(:)];
        M  = spm_matrix(x);
        MM = zeros(4,4,numel(PO));
        for j=1:numel(PO)
            MM(:,:,j) = spm_get_space(PO{j});
        end
        for j=1:numel(PO)
            spm_get_space(PO{j}, M\MM(:,:,j));
        end
end

% clean up: move/delete processed spm files, load new data into matrix

this.finish_processing_step('coregister_to');% run coregister job
