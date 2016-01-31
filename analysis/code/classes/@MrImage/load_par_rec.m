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

filename = fullfile(fp, [fn, ext]);

header = read_par_header(filename);

%% read binary data
fid = fopen( filename );
data = fread( fid, 'uint16' );
fclose( fid );

data = reshape(data, header.xDim, header.yDim, header.nEchoes, ...
    header.nImageTypes, header.zDim, header.tDim);

data = permute(data,[1 2 5 6 3 4]);


switch imageType
    case 'abs'
        data = data(:,:,:,:,iEcho,1);
    case {'angle', 'phase'} % shouldn't it be 4?
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
        data = data * header.rescaleSlope + header.rescaleIntercept;
        disp(['data rescaled to console display by ' num2str(header.rescaleSlope)])
    case 'floating'
        data = data / header.scaleSlope;
        disp(['data rescaled to floating by 1/' num2str(header.scaleSlope)])
end

% TODO: are we flipping left/right now?
%
% rotate data matrix depending on slice acquisition orientation
% (transverse, sagittal, coronal)
switch header.sliceOrientation
    case 1 % transversal, do nothing
    case 2 % sagittal, dim1 = ap, dim2 = fh, dim3 = lr
        data = permute(data, [3 1 2 4 5 6]); 
    case 3 % coronal, dim1 = lr, dim2 = fh, dim3 = ap
        data = permute(data, [1 3 2 4 5 6]);
        data = flip_compatible(data, 3);
end

this.data = data;