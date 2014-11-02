function [this, argsUnused] = load_par_rec(this, filename, varargin)
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
%           varargin:   as parameter name/value pairs
%
%           imageType   'abs' (default) or 'angle'/'phase'
%           iEcho       selected echo number (default: 1);
%
% OUT
%           this        loaded MrImage object with data from par/rec files
%           argsUnused  cell of input argument name/value pairs not used by
%                       this function
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
defaults.dimSizes   = [];
defaults.imageType  = 'abs';
defaults.iEcho      = 1;
[args, argsUnused] = propval(varargin, defaults);
strip_fields(args);

hasDimSizes = ~isempty(dimSizes);

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

% load voxel dimensions from par-file
% read voxel size from pixel spacing and thickness+gap
%#sl   ec  dyn ph  ty   idx    pix %   rec size       (re)scale                   window       angulation        offcenter             thick  gap     info     spacing      echo  dtime ttime diff   avg flip    freq  RR_int turbo delay b grad cont      anis              diffusion      L.ty
% 1    1   1   1   0  2 0      16 100  224  224        0  12.2877 5.94433e-003   1070   1860 -0.75  0.11  0.67  -1.644 -12.978  -1.270 0.80   0.20    0 1 1 2 .97599 .97599 28.39 0.0   0.0   0        1 84.0     0    0     0  57 0.00   1    1 0          0            0       0       0  0
% load dimSizes from par file (probably only works for 2D acquisitions)
    fid = fopen(parFile);
    iRowFirstImageInformation = 101;
    C = textscan(fid, '%s','delimiter', '\n');
    offcenter = cell2mat(textscan(C{1}{34}, '.    Off Centre midslice(ap,fh,rl) [mm] :   %f%f%f'));
    angulation = cell2mat(textscan(C{1}{33}, '.    Angulation midslice(ap,fh,rl)[degr]:   %f%f%f'));
    trSeconds = 1e-3*cell2mat(textscan(C{1}{30}, '.    Repetition time [msec]             :   %f'));
    
    %% read data from first image information row
    par = str2num(C{1}{iRowFirstImageInformation});
    xDim = par(10);
    yDim = par(11);
    xres = par(29);
    yres = par(30);
    sliceThickness = par(23);
    sliceGap = par(24);
    rescale = par(13);

    zres = sliceThickness + sliceGap;
    zDim = str2num(C{1}{22}(regexp(C{1}{22},'[\d]')));
    tDim = str2num(C{1}{23}(regexp(C{1}{23},'[\d]')));
    
    %% Read additional info from whole data matrix
    parAllRows = cell2mat(cellfun(@str2num, ...
        C{1}(iRowFirstImageInformation:end), 'UniformOutput', false));
    %noOfImg = size(parAllRows,1);
    nImageTypes = numel(unique(parAllRows(:,5)));
    nEchoes = numel(unique(parAllRows(:,2)));
    
fid = fopen( filename );
data = fread( fid, 'uint16' );
fclose( fid );

data = reshape(data, xDim, yDim, nEchoes, nImageTypes, zDim, tDim);

data = permute(data,[1 2 5 6 3 4]);


switch imageType
    case 'abs'
        data = data(:,:,:,:,iEcho,1);
    case {'angle', 'phase'}
        data = data(:,:,:,:,iEcho,2);
end



if nargin < 2 % rescale if factor was loaded
    data = data * rescale;
    disp(['data rescaled by ' num2str(rescale)])
end

this.data = data;

%TODO also

% perform matrix transformation from (ap, fh, rl) to (x,y,z);
offcenter(3) = -offcenter(3); % rl -> lr, radiological to neurological
angulation(3) = -angulation(3);
this.geometry.load([], ...
    'resolutionMillimeters', [xres, yres, zres], ...
    'offcenterMillimeters', offcenter([3 1 2]), ...
    'rotationDegrees', angulation([3 1 2]), ...
    'nVoxels', size(data), ...
    'trSeconds', trSeconds);
