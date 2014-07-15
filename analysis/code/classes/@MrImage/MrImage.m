classdef MrImage < CopyData
    %An MR image (3D, 4D), on which typical image processing operations can be
    %performed (similar, e.g. to fslmaths),
    % e.g. realign, smooth, temporal filter
    %
    %   output = MrImage(input)
    %
    % IN
    %
    % OUT
    %
    % EXAMPLE
    %   MrImage
    %
    %   See also
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
        name    = 'MrImage';
        data    = []; % nX*nY*nZ data matrix
        rois    = []; % see also MrRoi
         
        % Geometry properties of data-matrix, in particular for save/load
        % provides full voxel to world mapping, i.e. affine transformation
        % including rotation/translation/voxel scaling
        geometry = []; % see also MrImageGeometry
        parameters = struct( ...
           'save', struct( ...
            'path', './zFatTmp', ...  % path where disk files can be stored temporarily
            ... %  file name before processing (disk-file has to be created for
            ... %  SPM-processing in certain methods)
            'fileUnprocessed', 'raw.nii', ...
            'fileProcessed', 'processed.nii', ...   % file name after processing (applying an spm-method)
            'keepCreatedFiles', false ... % keep temporary files on disk (processed and unprocessed) after method finished
            ) ...
            );
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
            if exist('spm_jobman')
                % spm_jobman runs this automatically, does not have to be
                % done again here! ...only warning is generated
                %spm_jobman('initcfg');
            else
                error(sprintf(['SPM (Statistical Parametric Mapping) Software not found.\n\n', ...
                    'Please add to Matlab path or install from http://www.fil.ion.ucl.ac.uk/spm/']));
            end
            this.geometry = MrImageGeometry();
            if nargin >= 1
                this.load(fileName, varargin);
            end
        end
    end
end