function this = save_nifti_analyze(this, filename)
% saves MrImage to nifti/analyze file depending on file extension
% (.nii/.this.data)
%
%   MrImage = save_nifti_analyze(MrImage)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   save_nifti_analyze
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

geometry = this.geometry;
verbose = true;

% captures coordinate flip matlab/analyze between 1st and 2nd dimension
nVols = geometry.nVoxels(4);
iVolArray = 1:nVols;

% create different img-files for each volume, if analyze-format
[fileNameVolArray, nifti_flag] = get_vol_filenames(filename, iVolArray);

%% delete existing image files & header (.nii/.mat or .img/.hdr)
if exist(filename, 'file')
    if nifti_flag
        delete_with_hdr(filename);
    else % delete img/hdr-files with same file name trunk one by one
        existingFileArray = get_vol_filenames(filename);
        delete_with_hdr(existingFileArray);
    end
end

if verbose, fprintf(1, 'writing %s, volume %04d', filename, 0); end;
for v = 1:nVols
    if verbose
        fprintf(1, '\b\b\b\b%04d', v);
    end
    if nifti_flag
        % remove ", iVol" to make it readable for spm_write_vol
        V.fname = regexprep(fileNameVolArray{v}, ',.*', '');
        V.n = [v, 1];
    else
        V.fname     = fileNameVolArray{v};
    end
    V.mat       = geometry.get_affine_transformation_matrix();
    V.pinfo     = [1;0;0];
    % use [64 1] double 64 or [16 1] float 32 for single images, but [8 1]
    % signed int (32 bit/voxel) or [4 1] signed short (16 bit/voxel)
    % for raw data (more than 30 images)
    if nVols < 30
        V.dt    = [64 1];
    else
        V.dt    = [4 1];
    end
    Y           = this.data(:,:,:,v);
    V.dim       = geometry.nVoxels(1:3);
    spm_create_vol(V);
    spm_write_vol(V, Y);
end
if verbose, fprintf(1, '\n');end;
