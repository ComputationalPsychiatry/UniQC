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
%   fileName - supported file-types: 
%              .nii         nifti, header info used
%              .img/.hdr    analyze, header info used
%              .cpx         Philips native complex (and coilwise) image
%                           data format
%              .par/.rec    Philips native image file format
%              .mat         matlab file, assumes data matrix in variable 'data'
%                           and parameters in 'parameters' (optional)
%               <data>      workspace variable can be given as input directly 
%   'PropertyName'
%               'resolutionMillimeter'  [1,3] vector, default [1 1 1]  See also MrImage
%               'offsetMillimeter'      [1,3] vector, default [0 0 0]  See also MrImage
%               'selectedVolumes'       [1,nVols] vector of selected volumes to
%                                           be loaded
%
% OUT
%   Y.data                  updated with data
%   Y.parameters.geometry   updated from input property values or file headers
%
% EXAMPLE
%   Y = MrImage('fileName.nii')
%       nifti files, header is read to update MrImage.parameters
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
defaults.resolutionMillimeter = [1 1 1];
defaults.offsetMillimeter = [0 0 0];
defaults.selectedVolumes = Inf;
defaults.selectedCoils = 1; % Inf for all, 0 for SoS-combination
args = propval(varargin, defaults);
strip_fields(args);

isMatrix = ~isstr(fileName);

hasSelectedVolumes = ~isinf(selectedVolumes);

if isMatrix
    if hasSelectedVolumes
        this.data = fileName(:,:,:,selectedVolumes);
    else
        this.data = fileName;
    end
     
    this.parameters.geometry.resolutionMillimeter = resolutionMillimeter;
    this.parameters.geometry.offsetMillimeter = offsetMillimeter;
else
    [p,fn,ext] = fileparts(fileName);
    switch ext
        case '.cpx'
            this.load_cpx(fileName, selectedVolumes, selectedCoils);
        case {'.par', '.rec'}
            this.load_par_rec(fileName);
            if hasSelectedVolumes
                this.data = this.data(:,:,:,selectedVolumes);
            end
        case {'.nii', '.img','.hdr'}
            this.load_nifti_analyze(fileName, selectedVolumes);
        case {'.mat'} % assumes mat-file contains one variable with 3D image data
            tmp = load(fileName,'data', 'parameters');
           
            if hasSelectedVolumes
                this.data = tmp.data(:,:,:,selectedVolumes);
            else
                this.data = tmp.data;
            end
            
            if isfield(tmp, 'parameters')
                this.parameters = tmp.parameters;
            else
                this.parameters.geometry.resolutionMillimeter = resolutionMillimeter;
                this.parameters.geometry.offsetMillimeter = offsetMillimeter;
            end
            
        case ''
            if isdir(fileName) % previously saved object, load
            else
                error('File with unsupported extension or non-existing');
            end
    end
    this.name = ['MrImage_' fn ext '_coil', sprintf('_%02d', selectedCoils)];
end

this.parameters.geometry.nVoxel = size(this.data);

is3D = numel(size(this.data)) < 4;
if is3D
    this.parameters.geometry.nVoxel(4) = 1;
end

this.parameters.geometry.fovMillimeter = this.parameters.geometry.nVoxel(1:3) .*...
    this.parameters.geometry.resolutionMillimeter;