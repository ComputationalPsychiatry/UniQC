classdef MrImageGeometry < CopyData
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
    fovMillimeters           = [0 0 0];

    % [1,4] vector of number of voxels per image dimension
    % (x, y, z and time (number of volumes)
    nVoxels                  = [0 0 0 0];

    % [1,3] vector of image resolution (voxel size in mm) in x,y,z
    % direction
    resolutionMillimeters    = [1 1 1];

    % Repetition time in seconds
    % between subsequent scans/volumes (4th dim samples)
    trSeconds                = 1;

    % [1,3] vector of translational offcenter (in mm) in x,y,z of
    % image volume with respect to isocenter
    offcenterMillimeters        = [0 0 0];

    % [1,3] vector of rotation (in degrees) 
    % around x,y,z-axis (i.e. pitch, roll and yaw), i.e. isocenter (0,0,0)
    rotationDegrees          = [0 0 0];
    
    % [1,3] vector of x-y, x-z and y-z shear (in mm)
    %
    % equivalent to off-diagonal elements of affine transformation matrix: 
    % S   = [1      P(10)   P(11)   0;
    %        0      1       P(12)   0;
    %        0      0       1       0;
    %        0      0       0       1];
    shearMillimeters         = [0 0 0]
    
end % properties


methods

    % Constructor of class, allows input of affine transformation matrix or
    % nifti/analyze file parsing its header information
    %
    %   MrImageGeometry(fileName, 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry(affineTransformationMatrix, 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry([], 'PropertyName', PropertyValue, ...)
    %   MrImageGeometry('', 'PropertyName', PropertyValue, ...)
    function this = MrImageGeometry(fileName, varargin)
        if ~nargin
            fileName = [];
        end
        this.load(fileName, varargin);
    end

    % NOTE: Most of the methods are saved in separate function.m-files in this folder;
    %       except: constructor, delete, set/get methods for properties.

end % methods

end
