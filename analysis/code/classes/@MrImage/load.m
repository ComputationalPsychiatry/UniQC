function this = load(this, fileName, varargin)
%loads MrImage from different file types, allowing property-name/value
%pairs to be set for geometry parameters
%
%   Y = MrImage();
%   Y.load(fileName,'PropertyName', PropertyValue, ...);
%
% This is a method of class MrImage.
%
% IN
%   fileName    string or cell of strings; if cell is given, image files
%               have to have the same 3D geometry and are appended to a 4D
%               MrImage

%              - supported file-types:
%              .nii         nifti, header info used
%              .img/.hdr    analyze, header info used
%              .cpx         Philips native complex (and coilwise) image
%                           data format
%              .par/.rec    Philips native image file format
%              .mat         matlab file, assumes data matrix in variable 'data'
%                           and parameters in 'parameters' (optional)
%               <data>      workspace variable can be given as input directly
%   'PropertyName'
%               'selectedCoils'         [1,nCoils] vector of selected Coils to
%                                           be loaded (deafult: 1)
%               'selectedVolumes'       [1,nVols] vector of selected volumes to
%                                           be loaded
%               'signalPart'            'abs'       - absolute value
%                                       'phase'     - phase of signal
%               'doUpdateSaveParameters' true or false (default)
%                                        if true parameters.save.path and
%                                                parameters.save.fileUnprocessed
%                                        are updated to match the input
%                                        file name
%               properties of MrImageGeometry; See also MrImageGeometry
%               e.g.
%               'resolutionMillimeters'    , [1 1 1]
%               'offcenterMillimeters'     , [0 0 0]
%               'rotationDegrees'          , [0 0 0]
%               'shearMillimeters'         , [0 0 0]
%    
%
% OUT
%   Y.data                  updated with data
%   Y.geometry              updated from input property values or file headers
%
% EXAMPLE
%   Y = MrImage('fileName.nii')
%       nifti files, header is read to update MrImage.parameters
%
%   Y = MrImage({'avg152PD.nii';'avg152T1.nii'; 'avg152T2.nii'});
%       cell of nifti files (in spm12b/canonical), appended to a 4D MrImage
%
%   Y = MrImage('fileName.img') or Y = MrImage('fileName.hdr')
%       analyze files, header is read to update MrImage.parameters
%   Y = MrImage('fileName.mat', 'resolutionMillimeter', [2 2 2])
%
%   data = rand(64, 64, 37, 200);
%   Y = MrImage(data, 'offsetMillimeter', [110 90 -92])
%       matlab matrix, 'data' must be in workspace
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-02
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

if nargin < 2
    fileName = fullfile(this.parameters.save.path, ....
        this.parameters.save.fileUnprocessed);
end


defaults.selectedVolumes = Inf;
defaults.selectedCoils = 1; % Inf for all, 0 for SoS-combination
defaults.signalPart = 'abs';
defaults.doUpdateSaveParameters = false;

% input arguments without defaults are assumed to be for
% MrImageGeometry and will be forwarded
[args, argsGeom] = propval(varargin, defaults);
strip_fields(args);

isMatrix = isnumeric(fileName);

hasSelectedVolumes = ~isinf(selectedVolumes);


% load cell of filenames by appending them
if iscell(fileName)
    
    this.load(fileName{1}, varargin{:}); % load first file
    nFiles = numel(fileName);
    for iFile = 2:nFiles % append other files
        this.append(fileName{iFile});
    end
    
else % file name or matrix
    
    if isMatrix
        this.data = fileName;
    else %load single file, if existing
        
        hasFoundFile = exist(fileName, 'file');
        if ~hasFoundFile
            warning(sprintf('File %s not existing, clearing data \n', fileName));
            this.data = [];
        else
            [fp,fn,ext] = fileparts(fileName);
            switch ext
                case '.cpx'
                    this.load_cpx(fileName, selectedVolumes, selectedCoils, ...
                        signalPart);
                case {'.par', '.rec'}
                    this.load_par_rec(fileName);
                case {'.nii', '.img','.hdr'}
                    this.load_nifti_analyze(fileName, selectedVolumes);
                case {'.mat'} % assumes mat-file contains one variable with 3D image data
                    tmp = load(fileName,'data', 'parameters', 'geometry');
                    this.data = tmp.data;
                    
                    % also update parameters and geometry, if stored
                    if isfield(tmp, 'parameters')
                        this.parameters = tmp.parameters;
                    end
                    
                    if isfield(tmp, 'geometry')
                        this.geometry = tmp.geometry;
                    else
                        this.geometry.resolutionMillimeter = resolutionMillimeter;
                        this.geometry.offsetMillimeter = offsetMillimeter;
                    end
                    
                case ''
                    if isdir(fileName) % previously saved object, load
                        % TODO: load MrImage from folder
                    else
                        error('File with unsupported extension or non-existing');
                    end
            end
            
            % define name from loaded file and data selection parameters
            
            hasSelectedCoils = strcmp(ext, '.cpx') && ~isinf(selectedCoils);
            if hasSelectedCoils
                stringCoils  = ['_coil', sprintf('_%02d', selectedCoils)];
            else
                stringCoils = '';
            end
            
            this.name = sprintf('%s_type_%s%s_%s', fn, ...
                regexprep(ext, '\.', ''), stringCoils, signalPart);
            
            if doUpdateSaveParameters
                this.parameters.save.path = fp;
                this.parameters.save.fileUnprocessed = [fn ext];
            end
           
            
        end % exist(fileName)
    end % else isMatrix
    
    % Some loading functions load full dataset, filter out unnecessary parts
    % here
    hasLoadedAllData = isMatrix || ...
        (hasFoundFile && ismember(ext, {'.par', '.rec', '.mat'}));
    if hasLoadedAllData && hasSelectedVolumes
        this.data = this.data(:,:,:,selectedVolumes);
    end
    
    % loads header from nifti/analyze files, overwrites other geometry
    % properties as given in MrImage.load as property/value pairs
    if ~isMatrix
        this.geometry.load(fileName, {argsGeom{:}, 'nVoxels', size(this.data)});
    else % don't give filename, when it is a matrix
        % to avoid misinterpretation as affine transformation matrix
        this.geometry.load([], {argsGeom{:}, 'nVoxels', size(this.data)});
    end
end

end % iscell(fileName)
