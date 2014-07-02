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
        n       = struct('x', 0, 'y', 0, 'z', 0, 't', 0); % counter structure of x,y,z dimension of data
        data    = []; % nX*nY*nZ data matrix
        rois    = []; % see also MrRoi
        parameters = struct( ...
            'geometry', ... % cool geometry properties of data-matrix, in particular for saving and plotting
            struct( ...
            'fovMillimeter', [1 1 1], ...
            'nVoxel', struct('x', 0, 'y', 0, 'z', 0, 't', 0), ...
            'resolutionMillimeter', [1 1 1] ...
            ), ...
            'save', struct( ...
            'path', './zFatTmp', ...  % path where disk files can be stored temporarily
            ... %  file name before processing (disk-file has to be created for
            ... %  SPM-processing in certain methods)
            'fileUnprocessed', 'raw.nii', ...
            'fileProcessed', 'processed.nii', ...   % file name after processing (applying an spm-method)
            'keep', false ... % keep temporary files on disk (processed and unprocessed) after method finished
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
        % Y = MrImage('filename.mat', resolutionMillimeter)
        %       matlab matrix loaded from file, specify
        %           resolutionMillimeter = [1,3] vector of x,y,z-dimension of voxel
        % Y = MrImage(variableName, resolutionMillimeter)
        %       matlab matrix "variableName" loaded from workspace, specify
        %           resolutionMillimeter = [1,3] vector of x,y,z-dimension of voxel
        
        function this = MrImage(fileName, resolutionMillimeter)
            
            if nargin >= 1
               isMatrix = ~isstr(fileName);
                
                if isMatrix
                    this.data = fileName;
                else
                    [p,f,ext] = fileparts(fileName);
                    switch ext
                        case {'.nii', '.img','.hdr'}
                            this.load_nifti_analyze(fileName);
                        case {'.mat'} % assumes mat-file contains one variable with 3D image data
                            this.data = load(fileName);
                            
                            if nargin < 2
                                resolutionMillimeter = [1 1 1];
                            end
                            this.parameters.resolutionMillimeter = resolutionMillimeter;
                            
                        case ''
                            if isdir(fileName) % previously saved object, load
                            else
                                error('File with unsupported extension or non-existing');
                            end
                    end
                end
                this.n.x = size(this.data,1);
                this.n.y = size(this.data,2);
                this.n.z = size(this.data,3);
                
                % loads matrix into .data from nifti or analyze file using spm_read_vols
                this.load_nifti_analyze(fileName);
            end
        end
    end
end