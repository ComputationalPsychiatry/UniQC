classdef MrAffineGeometry < MrCopyData
    % Stores affine transformation (e.g. for nifti) for an image. Is
    % disregarded during display
    %
    % Assumes that matrix always refers to dimensions in order 
    % {'x', 'y', 'z'} => if dims are in different order in dimInfo, they
    % are resorted before applying a transformation
    %
    % EXAMPLE
    %   MrAffineGeometry
    %
    %   See also
    %
    % Author:   Saskia Bollmann & Lars Kasper
    % Created:  2016-06-15
    % Copyright (C) 2016 Institute for Biomedical Engineering
    %                    University of Zurich and ETH Zurich
    %
    % This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
    % under the terms of the GNU General Public License (GPL), version 3.
    % You can redistribute it and/or modify it under the terms of the GPL
    % (either version 3 or, at your option, any later version).
    % For further details, see the file COPYING or
    %  <http://www.gnu.org/licenses/>.
    %
    % $Id$
    
    properties
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
        
        % scaling of voxel size
        scaling = [1 1 1];
        
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
        
        % TODO@Laetitia: What do you need it for?
        % What is 1,2,3 <=> sagittal/coronal/transversal?
        % compute from which orientation is necessary to achieve
        % z as third dimension
        % Or: solve via dimInfo order of 1st 3 dimensions
        sliceOrientation = 1;
    end
    
    methods
        
        % Constructor of class
        %   MrAffineGeometry(affineMatrix) 
        %       OR
        %   MrAffineGeometry('PropertyName', PropertyValue, ...)
        function this = MrAffineGeometry(varargin)
            if nargin == 1
                % affineMatrix
                this.update_from_affine_matrix(varargin{1});
            else
                for cnt = 1:nargin/2 % save 'PropertyName', PropertyValue  ... to object properties
                    this.(varargin{2*cnt-1}) = varargin{2*cnt};
                end
            end    
        end
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
        
        function affineMatrix = get.affineMatrix(this)
            affineMatrix = this.get_affine_matrix();
        end
        
        
        
    end % methods
    
end
