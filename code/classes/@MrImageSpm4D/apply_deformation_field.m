function warpedImage = apply_deformation_field(this, deformationField, varargin)
% Applies a previously estimated deformation field
%
%   Y = MrImage()
%   deformation_field = MrImage;
%   outputImage = Y.apply_deformation_field(deformation_field)
%
% This is a method of class MrImage.
%
% IN
% MrImage object containing the deformation field
%
% OUT
%
% EXAMPLE
%   apply_deformation_field
%
%   See also MrImage

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-10
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

defaults.interpolation = 7;     % degree of b-spline interpolation for estimation and reslicing
defaults.voxelSize = [2 2 2];   % resolution after interpolation
% bounding box for which images shall be written out (in mm)
defaults.boundingBox = [-78 -112 -70
                         78 76 85];
spmParameters = propval(varargin, defaults);

warpedImage = this.copyobj();

% for batch
warpedImage.save('fileName', warpedImage.get_filename('prefix', 'raw'));

% save deformation field for usage in batch
spmParameters.deformationField = cellstr(...
    fullfile(warpedImage.parameters.save.path, 'deformationField.nii'));
deformationField.save('fileName', spmParameters.deformationField{1}, ...
    'splitDims', []); %important to keep as 1 5D file!

matlabbatch = warpedImage.get_matlabbatch('apply_transformation_field', ...
    spmParameters);
save(fullfile(warpedImage.parameters.save.path, 'matlabbatch.mat'), ...
            'matlabbatch');
spm_jobman('run', matlabbatch);
% clean up: move/delete processed spm files, load new data into matrix

warpedImage.finish_processing_step('apply_transformation_field',  ...
    spmParameters.deformationField{1});