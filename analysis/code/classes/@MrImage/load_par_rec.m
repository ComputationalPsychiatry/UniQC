function this = load_par_rec(this, filename, dimSizes)
% reads Philips par/rec files using Gyrotools ReadRecV3 (June 2014)
%
%   Y = MrImage()
%   Y.load_par_rec(inputs)
%
% This is a method of class MrImage.
%
% IN
%           filename    e.g. 'recon.rec'
%
%           if no dimSizes:
%               load from par file (probably only works for 2D acquisitions)
%               & rescale according to the rescale factor
%           else:
%               dimSizes(xdim, ydim, zdim, tDim, noOfImg)
%               noOfImg = 2 bei 1D Flow (M, P)
%               noOfImg = 4 bei 3D Flow (M, Px, Py, Pz)
%
% OUT
%
% EXAMPLE
%   load_par_rec
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-04
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

[fp fn ext] = fileparts(filename);

switch ext
    case '.par'
        ext = '.rec';
    case '.rec'
        % everything fine
    otherwise
        error('No par/rec file specified. Cannot read this file');
end

filename = fullfile(fp, [fn ext]);

parFile = [filename(1:end-3) 'par'];
if nargin < 3 % load dimSizes from par file (probably only works for 2D acquisitions)
    fid = fopen(parFile);
    C = textscan(fid, '%s','delimiter', '\n');
    par = str2num(C{1}{101});
    xdim = par(10);
    ydim = par(11);
    xres = par(29);
    yres = par(30);
    sliceThickness = par(23);
    sliceGap = par(24);
    zres = sliceThickness + sliceGap;
    zdim = str2num(C{1}{22}(regexp(C{1}{22},'[\d]')));
    tdim = str2num(C{1}{23}(regexp(C{1}{23},'[\d]')));
    %noOfImg = length(C{1})-102;
    noOfImg = 1;
    dimSizes = [xdim ydim zdim tdim noOfImg];
    
    rescale = par(13);
    

end

xDim = dimSizes( 1 );
yDim = dimSizes( 2 );
zDim = dimSizes( 3 );
tDim = dimSizes( 4 );
noOfImg = dimSizes( 5 );

% load voxel dimensions from par-file
% read voxel size from pixel spacing and thickness+gap
    %#sl   ec  dyn ph  ty   idx    pix %   rec size       (re)scale                   window       angulation        offcentre             thick  gap     info     spacing      echo  dtime ttime diff   avg flip    freq  RR_int turbo delay b grad cont      anis              diffusion      L.ty
    % 1    1   1   1   0  2 0      16 100  224  224        0  12.2877 5.94433e-003   1070   1860 -0.75  0.11  0.67  -1.644 -12.978  -1.270 0.80   0.20    0 1 1 2 .97599 .97599 28.39 0.0   0.0   0        1 84.0     0    0     0  57 0.00   1    1 0          0            0       0       0  0
 fid = fopen(parFile);
 C = textscan(fid, '%f', 30, 'CommentStyle', '#');

fid = fopen( filename );
data = fread( fid, 'uint16' );
fclose( fid );

data = reshape(data,xDim,yDim,zDim,noOfImg,tDim);

%data = permute(data,[1 2 5 3 4]);

data = permute(data,[1 2 3 5 4]);


if nargin < 2 % rescale if factor was loaded
    data = data * rescale;
    disp(['data rescaled by ' num2str(rescale)])
end

this.data = data;
this.parameters.geometry.resolutionMillimeter = [xres, yres, zres];

