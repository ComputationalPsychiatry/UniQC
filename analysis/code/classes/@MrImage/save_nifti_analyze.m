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

geometry = this.parameters.geometry;

% captures coordinate flip matlab/analyze between 1st and 2nd dimension
indexSwapMatlabAnalyze = [2 1 3];
nVols = geometry.nVoxel(4);
sizeI = geometry.nVoxel(indexSwapMatlabAnalyze); 
FOV = geometry.fovMillimeter(indexSwapMatlabAnalyze);
res = geometry.resolutionMillimeter(indexSwapMatlabAnalyze);


iVolArray = 1:nVols;


% create different img-files for each volume, if analyze-format
[fileNameVolArray, nifti_flag] = get_vol_filenames(filename, iVolArray);

%% delete existing image files & header (.nii/.mat or .img/.hdr)
if nifti_flag && exist(filename, 'file')
    delete(filename);
    delete(regexprep(filename, '\.nii', '\.mat'));
else % delete img/hdr-files with same file name trunk one by one
    existingFileArray = get_vol_filenames(filename);
    nExistingFiles = numel(existingFileArray);
    for v = 1:nExistingFiles
        delete(existingFileArray{v});
        delete(regexprep(existingFileArray{v},'\.img', '\.hdr'));
    end
end

verbose = true;
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
    V.mat       = diag(res); V.mat(1,1) = -V.mat(1,1);
    V.mat(:,4)  = (-FOV.*(sizeI+1)./sizeI/2)';
    V.mat(1,4) = -V.mat(1, 4);
    V.mat(4,4) = 1;
    V.pinfo     = [1;0;0];
    V.dt        = [64 1]; % data type float 64; for float 32: [16 1];
    Y           = this.data(:,:,:,v);
    Y           = transform_matrix_matlab2analyze(Y);
    V.dim       = sizeI;
    spm_create_vol(V);
    spm_write_vol(V, Y);
end
if verbose, fprintf(1, '\n');end;
