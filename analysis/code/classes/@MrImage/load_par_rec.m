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
%           rescaleMode default: 'none'
%                       'none' - no rescaling
%                       'display'/'console' rescaling to values displayed
%                       on console, i.e. by displayValue =
%                           pixelValue * rescaleSlope + rescaleIntercept
%                       'floating' rescaling to floating point values, i.e.
%                           floatingValue = pixelValue / scaleSlope
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
defaults.dimSizes       = [];
defaults.imageType      = 'abs';
defaults.iEcho          = 1;
defaults.rescaleMode    = 'none';
[args, argsUnused]      = propval(varargin, defaults);
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
%#sl   ec  dyn ph  ty   idx    pix %   rec size       (re)scale                   window       angulation_deg        offcenter_mm             thick  gap     info     spacing      echo  dtime ttime diff   avg flip    freq  RR_int turbo delay b grad cont      anis              diffusion      L.ty
% 1    1   1   1   0  2 0      16 100  224  224        0  12.2877 5.94433e-003   1070   1860 -0.75  0.11  0.67  -1.644 -12.978  -1.270 0.80   0.20    0 1 1 2 .97599 .97599 28.39 0.0   0.0   0        1 84.0     0    0     0  57 0.00   1    1 0          0            0       0       0  0
% load dimSizes from par file (probably only works for 2D acquisitions)
fid                         = fopen(parFile);
iRowFirstImageInformation   = 101;
C                           = textscan(fid, '%s','delimiter', '\n');
FOV_mm                      = cell2mat(textscan(C{1}{31}, ...
    '.    FOV (ap,fh,rl) [mm]                :   %f%f%f'));
offcenter_mm                = cell2mat(textscan(C{1}{34}, ...
    '.    Off Centre midslice(ap,fh,rl) [mm] :   %f%f%f'));
angulation_deg              = cell2mat(textscan(C{1}{33}, ...
    '.    Angulation midslice(ap,fh,rl)[degr]:   %f%f%f'));
TR_s                        = 1e-3*cell2mat(textscan(C{1}{30}, ...
    '.    Repetition time [msec]             :   %f'));

%% read data from first image information row
par = str2num(C{1}{iRowFirstImageInformation});
xDim = par(10);
yDim = par(11);
xres = par(29);
yres = par(30);

sliceOrientation    = par(26); % 1 = tra, 2 = sag, 3 = cor
sliceThickness      = par(23);
sliceGap            = par(24);

rescaleIntercept    = par(12);
rescaleSlope        = par(13);
scaleSlope          = par(14);

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


switch rescaleMode
    % formula from par-file
    % # === PIXEL VALUES =============================================================
    % #  PV = pixel value in REC file, FP = floating point value, DV = displayed value on console
    % #  RS = rescale slope,           RI = rescale intercept,    SS = scale slope
    % #  DV = PV * RS + RI             FP = PV /  SS
    case 'none'
    case {'display', 'console'}
        data = data * rescaleSlope + rescaleIntercept;
        disp(['data rescaled to console display by ' num2str(rescaleSlope)])
    case 'floating'
        data = data / scaleSlope;
        disp(['data rescaled to floating by 1/' num2str(scaleSlope)])
end

% TODO: are we flipping left/right now?
%
% rotate data matrix depending on slice acquisition orientation
% (transverse, sagittal, coronal)
switch sliceOrientation
    case 1 % transversal, do nothing
        resolution_mm = [xres, yres, zres];
    case 2 % sagittal, dim1 = ap, dim2 = fh, dim3 = lr
        data = permute(data, [3 1 2 4 5 6]); 
        resolution_mm = [zres, xres, yres];
    case 3 % coronal, dim1 = lr, dim2 = fh, dim3 = ap
        data = permute(data, [1 3 2 4 5 6]);
        data = flip_compatible(data, 3);
        resolution_mm = [xres, zres, yres];
end

this.data = data;


% perform matrix transformation from (ap, fh, rl) to (x,y,z);
offcenter_mm(3) = -offcenter_mm(3); % rl -> lr, radiological to neurological
angulation_deg(3) = -angulation_deg(3);

% half FOV has to be subtracted from offcenter_mm to have central voxel at [0
% 0 0] + midslice-offcenter_mm
% FOV always positive, therefore 3rd component does not have to be inverted

this.geometry.load([], ...
    'resolution_mm', resolution_mm, ...
    'offcenter_mm', offcenter_mm([3 1 2]), ...
    'rotation_deg', angulation_deg([3 1 2]), ...
    'nVoxels', size(data), ...
    'TR_s', TR_s, ...
    'coordinateSystem', 'scanner'); 
%TODO make coord system philips and incorporate axis change!
