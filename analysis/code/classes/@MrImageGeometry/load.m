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
    TR_s = [];
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
                    % some nifti formats supply timing information
                    if isfield(V(1), 'private') 
                        if isstruct(V(1).private.timing)
                            TR_s = V(1).private.timing.tspace;
                        end
                    end
                case {'.par', '.rec'}
                    % TODO: implement by movingg readin from load_par_rec here
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
    if ~isempty(TR_s)
        this.TR_s = TR_s;
    end
end


defaults.FOV_mm         = this.FOV_mm;
defaults.offcenter_mm 	= this.offcenter_mm;
defaults.rotation_deg 	= this.rotation_deg;
defaults.resolution_mm 	= this.resolution_mm;
defaults.shear_mm 		= this.shear_mm;
defaults.nVoxels 		= this.nVoxels;
defaults.TR_s 			= this.TR_s;

args = propval(varargin, defaults);
strip_fields(args);

% update voxel count for geometry, ensure that always 4-dimensional
nVoxelsTemp 		= nVoxels;
nVoxels 			= ones(1,4);
nDims 				= numel(nVoxelsTemp);
nVoxels(1:nDims) 	= nVoxelsTemp;

% if resolution is empty/zero, it will be computed by
%   this.resolution_mm =
%       this.FOV_mm/this.nVoxels(1:3)
%
% otherwise, FOV will be computed as nVoxels*resolution

this.offcenter_mm 		= offcenter_mm;
this.rotation_deg 		= rotation_deg;
this.FOV_mm             = FOV_mm;
this.resolution_mm 		= resolution_mm;
this.shear_mm 			= shear_mm;
this.nVoxels 			= nVoxels;
this.TR_s 				= TR_s;


% replace resolution, if forced by empty/zero value
if isempty(resolution_mm) || ~any(resolution_mm)
    this.resolution_mm  = this.FOV_mm ./ ...
        this.nVoxels(1:3);
end

this.FOV_mm             = this.resolution_mm.*...
    this.nVoxels(1:3);
   
end


