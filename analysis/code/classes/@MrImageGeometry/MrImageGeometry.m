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
    
    properties (SetObservable = true)
        %     properties (SetAccess = immutable)
        
        % [1,3] vector of Field of View (in mm)
        FOV_mm          = [0 0 0];
        
        % [1,4] vector of number of voxels per image dimension
        % (x, y, z and time (number of volumes)
        nVoxels         = [1 1 1 1];
        
        % [1,3] vector of image resolution (voxel size in mm) in x,y,z
        % direction
        resolution_mm   = [0 0 0];
        
        % Repetition time in seconds
        % between subsequent scans/volumes (4th dim samples)
        TR_s            = 0;
        
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
        coordinateSystem = CoordinateSystems.nifti;
    end % properties
    
    methods
        
        function this = MrImageGeometry(varargin)
            % Constructor of class, allows input of affine transformation matrix or
            % nifti/analyze file parsing its header information
            %
            %   MrImageGeometry(fileName, 'PropertyName', PropertyValue, ...)
            %   MrImageGeometry([], 'PropertyName', PropertyValue, ...)
            %   MrImageGeometry(dimInfo, affineGeometry)
            %
            
            % check whether input provide
            if nargin
                hasInputFile = ~isempty(varargin{1}) ...
                    && ischar(varargin{1});
                % if input is not file, check whether input is object
                if ~hasInputFile
                    % check whether dimInfo is first input
                    inputDimInfoFirst = isa(varargin{1}, 'MrDimInfo');
                    % set defaults here
                    inputAffineGeomSecond = 0;
                    inputAffineGeometryFirst = 0;
                    inputDimInfoSecond = 0;
                    if inputDimInfoFirst
                        if nargin > 1 % check if second input supplied
                            inputAffineGeomSecond = isa(varargin{2}, 'MrAffineGeometry');
                        else
                            inputAffineGeomSecond = 0;
                        end
                        % check whether affineGeometry is first input
                    else
                        inputAffineGeometryFirst = isa(varargin{1}, 'MrAffineGeometry');
                        if nargin > 1 % check if second input supplied
                            inputDimInfoSecond = isa(varargin{2}, 'MrDimInfo');
                        else
                            inputDimInfoSecond = 0;
                        end
                    end
                    hasInputObjects = (inputDimInfoFirst  && inputAffineGeomSecond) ...
                        || (inputAffineGeometryFirst && inputDimInfoSecond);
                end
                if hasInputFile % file is provided
                    fileName = varargin{1};
                    tempDimInfo = MrDimInfo(fileName);
                    tempAffineGeometry = MrAffineGeometry(fileName);
                    this.set_from_dimInfo_and_affineGeom(tempDimInfo, tempAffineGeometry);
                    hasInputObjects = 0;
                elseif hasInputObjects % dimInfo and affineGeometry are provided
                    if inputDimInfoFirst
                        this.set_from_dimInfo_and_affineGeom(varargin{1}, varargin{2});
                    elseif inputAffineGeometryFirst
                        this.set_from_dimInfo_and_affineGeom(varargin{2}, varargin{1});
                    end
                elseif inputDimInfoFirst && ~inputAffineGeomSecond
                    affineGeometry = MrAffineGeometry(varargin{1});
                    this.set_from_dimInfo_and_affineGeom(varargin{1}, affineGeometry);
                elseif inputAffineGeometryFirst && ~inputDimInfoSecond
                    dimInfo = MrDimInfo(varargin{1}); % TODO!
                    this.set_from_dimInfo_and_affineGeom(dimInfo, varargin{1});
                end
                % update explicit geometry parameters
                if hasInputFile && (nargin > 1)
                    this.update(varargin{2:end});
                elseif hasInputObjects && (nargin > 2)
                    this.update(varargin{3:end});
                end
            end
            % else, do nothing
        end
        
        % NOTE: Most of the methods are saved in separate function.m-files in this folder;
        %       except: constructor, delete, set/get methods for properties.
    end % methods
    
end
