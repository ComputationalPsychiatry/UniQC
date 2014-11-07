function this = load(this, fileName, varargin)
% Loads Geometry info from affine trafo matrix or image header (.nii/.hdr/.img)
%
% NOTE: .mat-header files (for 4D niftis) are ignored, since the same voxel
%       position is assumed in each volume for MrImage
%
%   geom = MrImageGeometry()
%   geom.load(affineTransformationMatrix)
%   geom.load(fileName)
%
% This is a method of class MrImageGeometry.
%
% IN
%
% OUT
%
% EXAMPLE
%   geom = MrImageGeometry()
%   geom.load(affineTransformationMatrix)
%   geom.load('test.nii')
%   geom.load('test.img')
%   geom.load('test.hdr')
%
%   See also MrImageGeometry
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-15
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

if ~isempty(fileName)
    isMatrix = ~ischar(fileName);
    
    affineTransformationMatrix = [];
    trSeconds = [];
    if isMatrix
        affineTransformationMatrix = fileName;
    else % nifti or analyze (header) file
        fileName = fileName;
        
        if exist(fileName, 'file')
            [fp, fn, ext] = fileparts(fileName);
            
            switch ext
                case {'.hdr', '.nii', '.img'}
                    V = spm_vol(fileName);
                    affineTransformationMatrix = V.mat;
                    if isfield(V(1), 'private') % some nifti formats supply timing information
                        trSeconds = V(1).private.timing.tspace;
                    end
                case {'.par', '.rec'}
                    % TODO: implement by moving readin from load_par_rec here
                otherwise
                    warning('Only Philips (.par/.rec), nifti (.nii) and analyze (.hdr/.img) files are supported');
            end
        else
            fprintf('Geometry data could not be loaded: file %s not found.\n', ...
                fileName);
        end
    end
    
    if ~isempty(affineTransformationMatrix)
        this.update_from_affine_transformation_matrix(...
            affineTransformationMatrix);
    end
    
    % read TR in Seconds from file
    if ~isempty(trSeconds)
        this.trSeconds = trSeconds;
    end
end


defaults.offcenterMillimeters = this.offcenterMillimeters;
defaults.rotationDegrees = this.rotationDegrees;
defaults.resolutionMillimeters = this.resolutionMillimeters;
defaults.shearMillimeters = this.shearMillimeters;
defaults.nVoxels = this.nVoxels;
defaults.trSeconds = this.trSeconds;

args = propval(varargin, defaults);
strip_fields(args);

% update voxel count for geometry, ensure that always 4-dimensional
nVoxelsTemp = nVoxels;
nVoxels = ones(1,4);
nDims = numel(nVoxelsTemp);
nVoxels(1:nDims) = nVoxelsTemp;

this.offcenterMillimeters = offcenterMillimeters;
this.rotationDegrees = rotationDegrees;
this.resolutionMillimeters = resolutionMillimeters;
this.shearMillimeters = shearMillimeters;
this.nVoxels = nVoxels;
this.trSeconds = trSeconds;
this.fovMillimeters = this.resolutionMillimeters.*this.nVoxels(1:3);


