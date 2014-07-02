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

n = this.n;

nVols = n.t;
FOV = this.fovMillimeter;
res = this.resolutionMillimeter;

sizeI = [n.x, n.y, n.z];


iVolArray = 1:nVols;

[fp, fn, ext] = fileparts(filename);

nifti_flag = strcmpi(ext, '.nii');

if nVols>=1 && ~nifti_flag
    fnames = get_vol_filenames(fn, iVolArray, nifti_flag);
else
    fnames{1} = fn;
end

verbose = true;
if verbose, fprintf(1, 'writing %s, volume %04d', fn, 0); end;
for v = 1:nVols
    if verbose
                fprintf(1, '\b\b\b\b%04d', v);
    end
    if nifti_flag
        V.fname = fn;
        V.n = [v, 1];
    else
        V.fname     = fnames{v};
    end
    V.mat       = diag(res); V.mat(1,1) = -V.mat(1,1);
    V.mat(:,4)  = (-FOV.*(sizeI+1)./sizeI/2)';
    V.mat(1,4) = -V.mat(1, 4);
    V.mat(4,4) = 1;
    % V.mat(4,3) = V.mat(4,3)/2; % don't know why, but THIS puts it into iso-centre...
    V.pinfo     = [1;0;0];
    V.dt        = [64 1];[16 1]; % data type float 32/64
    Y           = this.data(:,:,:,v);
    Y           = transform_matrix_matlab2analyze(Y);
    V.dim       = sizeI;
    spm_create_vol(V);
    spm_write_vol(V, Y);
end
if verbose, fprintf(1, '\n');end;
