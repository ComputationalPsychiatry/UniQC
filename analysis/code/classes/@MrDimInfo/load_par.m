function this = load_par(this, filename)
% Reads dimInfo for Philips par/rec format. 
% TODO: extend to ND-data (so far, only 4D time series supported)
%
%   Y = MrDimInfo()
%   Y.load_par(filename)
%
% This is a method of class MrDimInfo.
% 
% NOTE: The output labels refer to dimensions in MNI space, *not* the
%       Philips scanner axis notation
%
% IN
%
% OUT
%
% EXAMPLE
%   load_par
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-10-25
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
% $Id$

header = read_par_header(filename);


%% rotated data matrix depending on slice acquisition orientation

dimLabels = {'x', 'y', 'z', 't'}; % MNI space XYZ, NOT Philips XYZ
units = {'mm', 'mm', 'mm', 's'};
nSamples = [header.xDim, header.yDim, header.zDim, header.tDim];

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

this.set_dims(dimLabels, 'resolutions', resolutions, 'nSamples', nSamples, ...
    'units', units);

%% Permute dimInfo depending on slice orientation to retain that info
switch ori
    case 1
        order = [1 2 3 4];
    case 2
        order = [2 3 1 4];
    case 3
        order = [1 3 2];
end
this.permute(order);