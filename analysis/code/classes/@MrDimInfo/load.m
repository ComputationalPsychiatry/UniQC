function this = load(this, inputDataOrFile)
% Loads Geometry info from affine image header (.nii/.hdr/.img) or Philips
% (par/rec)
%
% NOTE: .mat-header files (for 4D niftis) are ignored, since the same voxel
%       position is assumed in each volume for MrImage
%
%   dimInfo = MrDimInfo()
%   dimInfo.load(inputs)
%
% This is a method of class MrDimInfo.
%
% IN
%
% OUT
%
% EXAMPLE
%   dimInfo = MrImageGeometry()
%   dimInfo.load('test.nii')
%   dimInfo.load('test.hdr/img')
%   dimInfo.load('test.par/rec')
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-10-19
% Copyright (C) 2017 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

fileName = inputDataOrFile;
% check whether file exists
if exist(fileName, 'file')
    
    % get geometry parameters from file
    [~, ~, ext] = fileparts(fileName);
    isValidExtension = ismember(ext, {'.hdr', '.nii', '.img', '.par', '.rec'});
    if isValidExtension
        switch ext
            case {'.hdr', '.nii', '.img'}
                % read header info
                V = spm_vol(fileName);
                
                % number of dimensions to be set
                nSamples = V(1).private.dat.dim;
                nDims = numel(nSamples);
                tempDimInfo = MrDimInfo('nSamples', nSamples);
                
                % prepare setting dimension
                iDimGeom = 1:nDims;
                dimLabels = tempDimInfo.dimLabels;
                units = tempDimInfo.units;
                P = round(spm_imatrix(V(1).mat),7);
                resolution_mm  = P(7:9);
                
                % some nifti formats supply timing information
                if isfield(V(1), 'private')
                    if isstruct(V(1).private.timing)
                        TR_s = V(1).private.timing.tspace;
                        tStart = 0;
                    else
                        TR_s = 1;
                        units{4} = 'samples';
                        tStart = 1;
                    end
                end
                
                % now set dims
                % need nifti to reference first sampling point as offcenter
                resolutions = ones(1, nDims);
                resolutions(1, 1:4) = [resolution_mm TR_s];
                
            case {'.par', '.rec'}
                % read header information
                header = read_par_header(fileName);
                
                % rotated data matrix depending on slice acquisition orientation
                dimLabels = {'x', 'y', 'z', 't'}; % MNI space XYZ, NOT Philips XYZ
                units = {'mm', 'mm', 'mm', 's'};
                nSamples = [header.xDim, header.yDim, header.zDim, header.tDim];
                nDims = numel(nSamples);
                iDimGeom = 1:nDims;
                tStart = 0;
                % (transverse, sagittal, coronal)
                ori             = header.sliceOrientation;
                resolutions     = [header.xres, header.yres, header.zres header.TR_s];
                
                switch ori
                    case 1 % transversal, dim1 = ap, dim2 = fh, dim3 = rl (ap fh rl)
                        ind = [3 1 2];    % ap,fh,rl to rl,ap,fh
                        ind_res = [1 2 3]; % OR [2 1 3];    % x,y,z to rl,ap,fh
                    case 2 % sagittal, dim1 = ap, dim2 = fh, dim3 = lr
                        ind = [3 1 2];
                        ind_res = [3 1 2];  % OR [3 2 1]
                    case 3 % coronal, dim1 = lr, dim2 = fh, dim3 = ap
                        ind = [3 1 2];
                        ind_res = [1 3 2]; % OR [2 3 1]; % x,y,z to rl,ap,fh
                end
                
                
                %% perform matrix transformation from (ap, fh, rl) to (x,y,z);
                % (x,y,z) is (rl,ap,fh)
                
                resolutions(1:3)    = resolutions(ind_res);
                nSamples(1:3)       = nSamples(ind);
        end       
        
        % update existing geom dimensions, add new ones for
        % non-existing
        iValidDimLabels = this.get_dim_index(dimLabels);
        iDimGeomExisting = find(iValidDimLabels);
        iDimGeomAdd = setdiff(iDimGeom, iDimGeomExisting);
        
        % voxel position by voxel center, time starts at 0 seconds/1 sample
        firstSamplingPoint = ones(1, nDims);
        firstSamplingPoint(1:4) = [resolutions(1:3)/2 tStart];
        
        % if dimension labels exist, just update values
        this.set_dims(dimLabels(iDimGeomExisting), ...
            'resolutions', resolutions(iDimGeomExisting), ...
            'nSamples', nSamples(iDimGeomExisting), ...
            'firstSamplingPoint', firstSamplingPoint(iDimGeomExisting), ...
            'units', units(iDimGeomExisting));
        
        % if they do not exist, create dims
        this.add_dims(dimLabels(iDimGeomAdd), ...
            'resolutions', resolutions(iDimGeomAdd), ...
            'nSamples', nSamples(iDimGeomAdd), ...
            'firstSamplingPoint', firstSamplingPoint(iDimGeomAdd), ...
            'units', units(iDimGeomAdd));        
        
    else % no valid extension
        warning('Only Philips (.par/.rec), nifti (.nii) and analyze (.hdr/.img) files are supported');
    end
    
else
    fprintf('Geometry data could not be loaded: file %s not found.\n', ...
        fileName);
end


end