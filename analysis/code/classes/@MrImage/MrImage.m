classdef MrImage < MrDataNd
    %An MR image (3D, 4D), on which typical image processing operations can be
    %performed (similar, e.g. to fslmaths),
    % e.g. realign, smooth, temporal filter
    %
    %   Y = MrImage(dataMatrix, 'propertyName', propertyValue, ...)
    %       OR
    %   Y = MrImage(fileName, 'propertyName', propertyValue, ...)
    %
    % IN
    %   dataMatrix  3D or 4D matrix with the following dimension order
    %               [nVoxelX, nVoxelY, nSlices, nVolumes]
    %
    %               OR
    %
    %   fileName    string or cell of strings; if cell is given, image files
    %               have to have the same 3D geometry and are appended to a
    %               4D MrImage
    %
    %              - supported file-types:
    %              .nii         nifti, header info used
    %              .img/.hdr    analyze, header info used
    %              .cpx         Philips native complex (and coilwise) image
    %                           data format
    %              .par/.rec    Philips native image file format
    %              .mat         matlab file, assumes data matrix in
    %                           variable 'data'
    %                           and parameters in 'parameters' (optional)
    %
    %   'PropertyName'/value - pairs possible:
    %               'imageType'         'abs' or 'angle'/'phase'
    %                                   default: 'abs'
    %                                   (only for par/rec data)
    %               'iEcho'             echo number to be loaded
    %                                   default: 1
    %                                   (only for par/rec data)
    %               'selectedCoils'     [1,nCoils] vector of selected Coils
    %                                   to be loaded (default: 1)
    %               'selectedVolumes'   [1,nVols] vector of selected volumes
    %                                   to be loaded
    %               'signalPart'        'abs'       - absolute value
    %                                   'phase'     - phase of signal
    %               'updateProperties'  (cell of) strings containing the
    %                                   properties of the object to be
    %                                   updated with the new (file)name and
    %                                   its data
    %                                       'name'  name is set to file name
    %                                              (default)
    %                                       'save'  parameters.save.path and
    %                                               parameters.save.fileName
    %                                               are updated to match
    %                                               the input file name
    %                                       'none'  only data and geometry
    %                                               updated by loading
    %                                       'all'   equivalent to
    %                                       {'name','save'}
    %
    %               properties of MrImageGeometry; See also MrImageGeometry
    %               e.g.
    %               'resolution_mm'    , [1 1 1]
    %               'offcenter_mm'     , [0 0 0]
    %               'rotation_deg'     , [0 0 0]
    %               'shear_mm'         , [0 0 0]
    %
    %
    % OUT
    %
    % EXAMPLE
    %   Y = MrImage(dataMatrix, 'resolution_mm', [2.5 2.5 4], ...
    %       'FOV_mm', [220 220 110], 'TR_s', 3)
    %   Y = MrImage('spm12b/canonical/single_subj_T1.nii')
    %
    %   See also MrImage.load MrDimInfo MrImageGeometry MrDataNd MrAffineGeometry
    %
    % Author:   Saskia Klein & Lars Kasper
    % Created:  2014-04-15
    % Copyright (C) 2014 Institute for Biomedical Engineering
    %                    University of Zurich and ETH Zurich
    %
    % This file is part of the Zurich fMRI Analysis Toolbox, which is released
    % under the terms of the GNU General Public Licence (GPL), version 3.
    % You can redistribute it and/or modify it under the terms of the GPL
    % (either version 3 or, at your option, any later version).
    % For further details, see the file COPYING or
    %  <http://www.gnu.org/licenses/>.
    %
    % $Id$
    properties
        
        % other properties: See also MrDataNd
        rois    = []; % see also MrRoi
          
        % TODO: add the acquisition parameters? useful for 'advanced' image
        % processing such as unwrapping and B0 computation.
    end
    
    properties (Dependent)
        % geometry of a slab is both the extent of the slab (FOV, resolution, nVoxels
        %   => dimInfo
        % and its position and orientation in space (affineGeometry)
        % geometry is thus a dependent property (no set (?)) formed as a
        % combination of the two.
        % See also MrImageGeometry
        %
        % 3D Geometry properties of data-matrix + 4D time info,
        % in particular for save/load from nifti/par-rec for fMRI
        % provides full voxel to world mapping, i.e. affine transformation
        % including rotation/translation/voxel scaling
        geometry
    end
    
    methods
        
        function this = MrImage(varargin)
            % NOTE: Most of the methods are saved in separate function.m-files in this folder;
            %       except: constructor, delete, set/get methods for properties.
            
            % Constructor of MrImage class. Accepts fileName input for different
            % file type (nifti, analyze, mat):
            % EXAMPLES
            % Y = MrImage('filename.nii')
            %       nifti files, header is read to update MrImage.parameters
            % Y = MrImage('filename.img') or Y = MrImage('filename.hdr')
            %       analyze files, header is read to update MrImage.parameters
            % Y = MrImage('filename.mat', 'PropertyName', PropertyValue, ...)
            %       matlab matrix loaded from file, specify
            %       properties:
            %           dimInfo     MrDimInfo  e.g. resolutions, dimLabels
            %                                  ranges, ...)
            % Y = MrImage(variableName, 'PropertyName', PropertyValue, ...)
            %       matlab matrix "variableName" loaded from workspace
            
            % uses MrDataNd.load, which has affineGeomertry as 2nd output
            % argument, if file format was an image
            this@MrDataNd(varargin{:});
            
            this.parameters.save.path = regexprep(this.parameters.save.path, 'MrDataNd', class(this));
            this.parameters.save.fileName = 'MrImage.nii';
            
            % Call SPM job manager initialisation, if not done already.
            % Check via certain matlabbatch-function being on path
            if ~exist('cfg_files', 'file')
                if exist('spm_jobman')
                    spm_jobman('initcfg');
                else
                    warning(sprintf(['SPM (Statistical Parametric Mapping) Software not found.\n', ...
                        'Some fMRI-related functionality, esp. of MrSeries, will not work. \n\n', ...
                        'For complete utility, Please add SPM to Matlab path or install from http://www.fil.ion.ucl.ac.uk/spm/']));
                end
            end
            
        end
        
        function geometry = get.geometry(this)
            % Get-Method for geometry
            % geometry of a slab is both the extent of the slab (FOV, resolution, nVoxels
            %   => dimInfo
            % and its position and orientation in space (affineGeometry)
            % geometry is thus a dependent property set formed as a
            % combination of the two.
            % See also MrImageGeometry
            
            if ~isempty(this.dimInfo)
                geometry = this.dimInfo.get_geometry4D();
             else % if something goes wrong, we still want a functioning object...
                geometry = [];
            end
        end
        
        function this = set.geometry(this, newGeometry)
            % Set-Method for geometry
            % Likewise to Get, geometry (MrImageGeometry!) updates both values of dimInfo and
            % affineGeometry:
            % geometry of a slab is both the extent of the slab (FOV, resolution, nVoxels
            %   => dimInfo
            % and its position and orientation in => affineGeometry
            % geometry is thus a dependent property (no set (?)) formed as a
            % combination of the two.
            % See also MrImageGeometry
            try
                this.affineGeometry = MrAffineGeometry();
                 % since saved as affine geometry, for later use to store
                 % as nifti, we transform it to nifti already(?)
                newGeometry = newGeometry.convert(CoordinateSystems.nifti);
                this.affineGeometry.shear_mm = newGeometry.shear_mm;
                this.affineGeometry.rotation_deg = newGeometry.rotation_deg;
                % convention that no rescaling saved in AffineGeometry, but is
                % transferred directly to dimInfo
                this.affineGeometry.scaling = [1 1 1];
                this.affineGeometry.offcenter_mm = [0 0 0];
                this.affineGeometry.coordinateSystem = CoordinateSystems.nifti; % ??? or shall we remove this property at all from affine Geom?
                
                % TODO: check whether these dimensions exist, otherwise error,
                % or add them...
                dimLabelsGeom = {'x','y','z', 't'};
                units = {'mm', 'mm', 'mm', 's'};
                iDimGeom = 1:4;
                
                if isempty(this.dimInfo) % first creation!
                    this.dimInfo = MrDimInfo();
                end
                
                % update existing geom dimensions, add new ones for
                % non-existing
                iValidDimLabels = this.dimInfo.get_dim_index(dimLabelsGeom);
                iDimGeomExisting = find(iValidDimLabels);
                iDimGeomAdd = setdiff(iDimGeom, iDimGeomExisting);
                
                resolutions = [newGeometry.resolution_mm newGeometry.TR_s];
                firstSamplingPoint = [newGeometry.offcenter_mm 0];
                
                this.dimInfo.set_dims(dimLabelsGeom(iDimGeomExisting), ...
                    'resolutions', resolutions(iDimGeomExisting), ...
                    'nSamples', newGeometry.nVoxels(iDimGeomExisting), ...
                    'firstSamplingPoint', firstSamplingPoint(iDimGeomExisting), ...
                    'units', units(iDimGeomExisting));
                
                this.dimInfo.add_dims(dimLabelsGeom(iDimGeomAdd), ...
                    'resolutions', resolutions(iDimGeomAdd), ...
                    'nSamples', newGeometry.nVoxels(iDimGeomAdd), ...
                    'firstSamplingPoint', firstSamplingPoint(iDimGeomAdd), ...
                    'units', units(iDimGeomAdd));
                
            catch % if not initialized, well...ignore
            end
        end
    end
end