classdef MrImage < CopyData
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
    %               'resolutionMillimeters'    , [1 1 1]
    %               'offcenterMillimeters'     , [0 0 0]
    %               'rotationDegrees'          , [0 0 0]
    %               'shearMillimeters'         , [0 0 0]
    %
    %
    % OUT
    %
    % EXAMPLE
    %   Y = MrImage(dataMatrix, 'resolutionMillimeters', [2.5 2.5 4], ...
    %       'fovMillimeters', [220 220 110], 'trSeconds', 3)
    %   Y = MrImage('spm12b/canonical/single_subj_T1.nii')
    %
    %   See also MrImage.load
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
        
        % cell(nRows,1) of strings with detailed image information, e.g.
        % previous processing steps to arrive at that image
        % (masking/thresholding...)
        info    = {'detailed image information'; 'given in cell strings'};
        
        % A short string identifier of the image, used e.g. as plot-title
        name    = 'MrImage';
        
        data    = []; % nX*nY*nZ data matrix
        rois    = []; % see also MrRoi
         
        % Geometry properties of data-matrix, in particular for save/load
        % provides full voxel to world mapping, i.e. affine transformation
        % including rotation/translation/voxel scaling
        geometry = []; % see also MrImageGeometry
        % TODO: change fileUnprocessed/Processed-handling via directories
                        % 'fileName', 'raw.nii', ...
    
        parameters = struct( ...
           'save', struct( ...
            'path', './zFatTmp', ...  % path where disk files can be stored temporarily
            'fileName', 'imageData.nii', ... %  file name for saving
            'keepCreatedFiles', 'none' ... % 'none', 'all', 'processed' keep temporary files on disk after method finished
            ) ...
            );
                    % add the acquisition parameters? useful for 'advanced' image
            % processing such as unwrapping and B0 computation.
    end
    methods
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
        %           resolutionMillimeter = [1,3] vector of x,y,z-dimension of voxel
        %           offsetMillimeter = [1,3] vector of x,y,z-dimension of
        %                               volume offcenter/translational offset
        % Y = MrImage(variableName, 'PropertyName', PropertyValue, ...)
        %       matlab matrix "variableName" loaded from workspace
        
        function this = MrImage(fileName, varargin)
            if exist('spm_jobman') || ~exist('cfg_files')
                spm_jobman('initcfg');
            else
                error(sprintf(['SPM (Statistical Parametric Mapping) Software not found.\n\n', ...
                    'Please add to Matlab path or install from http://www.fil.ion.ucl.ac.uk/spm/']));
            end
            this.geometry = MrImageGeometry();
          
            % save path
            stringTime = datestr(now, 'yymmdd_HHMMSS');
            pathSave = fullfile(pwd, ['MrImage_' stringTime]);
            this.parameters.save.path = pathSave;
          
            if nargin >= 1
                this.load(fileName, varargin);
            end
        end
    end
end