function this = read_single_file(this, fileName, varargin)
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
%
%   'PropertyName'/value - pairs possible:
%               'updateProperties'      (cell of) strings containing the
%                                       properties of the object to be updated with the new
%                                       (file)name and its data
%                                       'name'  name is set to file name
%                                              (default)
%                                       'save'  parameters.save.path and
%                                               parameters.save.fileUnprocessed
%                                               are updated to match the input
%                                               file name
%                                       'none'  only data and geometry
%                                               updated by loading
%                                       'all'   equivalent to
%                                       {'name','save'}

%
%
% OUT

% EXAMPLE
%   Y = MrImage;
%
%   % loads data from fileName and updates both name and parameters.save of
%   % MrImage
%   Y.load('fileName.nii', 'updateProperties', 'all');
%
%   % as before, but takes filename from parameters.save
%   Y.load([], 'updateProperties', 'all');
%
%   Y = MrImage('fileName.nii')
%       nifti files, header is read to update MrImage.parameters
%
%   Y = MrImage({'fileName_volume001.nii', 'fileName_volume002.nii', ...})
%       cell of nifti file names (e.g. individual volumes) loaded into
%       appended matrix.
%
%   Y = MrImage('fileName.rec', 'imageType', 'phase', 'iEcho', 2);
%       Philips par/rec files, load phase image of 2nd echo
%
%   Y = MrImage({'avg152PD.nii';'avg152T1.nii'; 'avg152T2.nii'});
%       cell of nifti files (in spm12b/canonical), appended to a 4D MrImage
%
%   Y = MrImage('fileName.img') or Y = MrImage('fileName.hdr')
%       analyze files, header is read to update MrImage.parameters
%   Y = MrImage('fileName.mat', 'resolution_mm', [2 2 2])
%
%   data = rand(64, 64, 37, 200);
%   Y = MrImage(data, 'offcenter_mm', [110 90 -92])
%       matlab matrix, 'data' must be in workspace
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-09-24
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

if nargin < 2 || isempty(fileName)
    fileName = this.get_filename;
end


defaults.selectedVolumes = Inf;
defaults.selectedCoils = 1; % Inf for all, 0 for SoS-combination
defaults.signalPart = 'abs';
defaults.updateProperties = 'name';
defaults.dimInfo = [];

% input arguments without defaults are assumed to be for
% MrImageGeometry and will be forwarded
[args, argsGeomDimInfo] = propval(varargin, defaults);
strip_fields(args);

doUpdateName = any(ismember({'name', 'all', 'both'}, cellstr(updateProperties)));
doUpdateSave = any(ismember({'save', 'all', 'both'}, cellstr(updateProperties)));

hasDimInfo = ~isempty(dimInfo);

isMatrix = isnumeric(fileName) || islogical(fileName);

hasSelectedVolumes = ~isempty(selectedVolumes) && ~any(isinf(selectedVolumes));

if isMatrix
    this.data = fileName;
    this.name = 'workspaceDataMatrix';
    this.info{end+1,1} = ...
        sprintf('Constructed from %s', this.name);
    
else %load single file, if existing
    
    hasFoundFile = (exist(fileName, 'file')) > 0;
    if ~hasFoundFile
        warning(sprintf('File %s not existing, clearing data \n', fileName));
        this.data = [];
        ext = '';
    else
        [fp,fn,ext] = fileparts(fileName);
        switch ext
            case '.cpx'
                this.read_cpx(fileName, selectedVolumes, selectedCoils, ...
                    signalPart);
            case {'.par', '.rec'}
                % forwards only unused elements
                [this, argsGeomDimInfo] = this.read_par_rec(fileName, argsGeomDimInfo);
            case {'.nii', '.img','.hdr'}
                this.read_nifti_analyze(fileName, selectedVolumes);
            case {'.mat'} % assumes mat-file contains one variable with 3D image data
                % TODO replace by struct2obj to iteratively construct
                % from hierarchical structure
                tmp = load(fileName,'obj');
                this = tmp.obj;
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
        
        if doUpdateName
            this.name = sprintf('%s_type_%s%s_%s', fn, ...
                regexprep(ext, '\.', ''), stringCoils, signalPart);
        end
        
        % always update info about file loading
        this.info{end+1,1} = ...
            sprintf('Constructed from %s', fileName);
        
        
        if doUpdateSave
            this.parameters.save.path = fp;
            this.parameters.save.fileName = [fn ext];
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

% Convert data to double for compatibility with all functions
this.data = double(this.data);
nSamples = size(this.data);

% loads header from nifti/analyze files, overwrites other geometry
% properties as given in MrImage.load as property/value pairs
loadGeometryFromHeader = ~isMatrix && ismember(ext, {'.par', '.rec', ...
    '.nii', '.img', '.hdr'});

% check whether actually any data was loaded and we need to update the
% geometry
hasData = ~isempty(this.data);

% dimInfo updates geometry, if given...has to be complete, though!
if hasDimInfo
    this.dimInfo = dimInfo.copyobj();
end

if hasData
    this.dimInfo.set_dims(1:numel(nSamples), 'nSamples', nSamples);
end

if loadGeometryFromHeader
    [this, TR_s, sliceOrientation] = this.affineGeometry.load(fileName);
    
    % TODO: transfer info from TR and slice orientation to dimInfo
    % (sampling-spacing)
    
    
end
