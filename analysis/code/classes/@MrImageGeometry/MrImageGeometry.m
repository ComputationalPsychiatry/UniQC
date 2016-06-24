classdef MrImageGeometry < MrCopyData
% Geometry properties of MrImage, in particular for operations on niftis
% Provides full voxel to world mapping, i.e. affine transformation
% Including rotation/translation/voxel scaling
%
%
% EXAMPLE
%   MrImageGeometry
%
%   See also MrImage spm_matrix spm_imatrix
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

properties
    % [1,3] vector of Field of View (in mm)
    FOV_mm          = [0 0 0];

    % [1,4] vector of number of voxels per image dimension
    % (x, y, z and time (number of volumes)
    nVoxels         = [0 0 0 0];

    % [1,3] vector of image resolution (voxel size in mm) in x,y,z
    % direction
    resolution_mm   = [1 1 1];

    % Repetition time in seconds
    % between subsequent scans/volumes (4th dim samples)
    TR_s            = 1;

    % [1,3] vector of translational offcenter (in mm) in x,y,z of
    % image volume with respect to isocenter
    offcenter_mm    = [0 0 0];

    % [1,3] vector of rotation (in degrees) 
    % around x,y,z-axis (i.e. pitch, roll and yaw), i.e. isocenter (0,0,0)
    rotation_deg    = [0 0 0];
    
    % [1,3] vector of x-y, x-z and y-z shear (in mm)
    %
    % equivalent to off-diagonal elements of affine transformation matrix: 
    % S   = [1      P(10)   P(11)   0;
    %        0      1       P(12)   0;
    %        0      0       1       0;
    %        0      0       0       1];
    shear_mm         = [0 0 0]
    
    % @Laetitia: What is 1,2,3 <=> sagittal/coronal/transversal?
    sliceOrientation = 1;
    
    % coordinate system that defines
    % 1) x,y,z axis orientation relative to patient RL-AP-FH
    % 2) origin of coordinate system: e.g. voxel [1,1,1] (Nifti) or
    % midcenter-midslice (Philips)
    % See also CoordinateSystems
    coordinateSystem = CoordinateSystems.scanner;
end % properties

properties (Dependent)
    % Affine transformation matrix, computed from SPM
    affineMatrix;
end

methods

    % Constructor of class, allows input of affine transformation matrix or
    % nifti/analyze file parsing its header information
    %
    %   MrImageGeometry(fileName, 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry(affineTransformationMatrix, 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry([], 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry('', 'PropertyName', PropertyValue, ...)
    function this = MrImageGeometry(fileName, varargin)
        hasInputFile = nargin && ~isempty(fileName) && ischar(fileName);
        hasInputAffineMatrix = nargin && ~isempty(fileName) && isnumeric(fileName);
        if hasInputFile
            this.load(fileName);
        elseif hasInputAffineMatrix
            affineMatrix = fileName;
            this.update('affineMatrix', affineMatrix);
        end
        % update explicit geometry parameters
        if nargin > 1
            this.update(varargin{:});
        end
    end

    % NOTE: Most of the methods are saved in separate function.m-files in this folder;
    %       except: constructor, delete, set/get methods for properties.
 
    function affineMatrix = get.affineMatrix(this)
        affineMatrix = this.get_affine_matrix();
    end
    
end % methods

end
