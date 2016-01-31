function this = load_par(this, filename)
% Loads Par (Philips)-Header information referring to geometry into object
%
%   Y = MrImageGeometry()
%   Y.load_par(inputs)
%
% This is a method of class MrImageGeometry.
%
% NOTE: This is based on the header read-in from GyroTools ReadRecV3
%
% IN
%
% OUT
%
% EXAMPLE
%   load_par
%
%   See also MrImageGeometry read_par_header
%
% Author:   Lars Kasper
% Created:  2016-01-31
% Copyright (C) 2016 Institute for Biomedical Engineering
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
% (transverse, sagittal, coronal)
resolution_mm = [header.xres, header.yres, header.zres];

switch header.sliceOrientation
    case 1 % transversal, do nothing
    case 2 % sagittal, dim1 = ap, dim2 = fh, dim3 = lr
        resolution_mm  = permute(resolution_mm, [3 1 2]);
    case 3 % coronal, dim1 = lr, dim2 = fh, dim3 = ap
        resolution_mm  = permute(resolution_mm, [1 3 2]);
end

%% perform matrix transformation from (ap, fh, rl) to (x,y,z);

offcenter_mm = header.offcenter_mm([3 1 2]);
angulation_deg = header.angulation_deg([3 1 2]);

% rl -> lr, radiological to neurological
offcenter_mm(1) = -offcenter_mm(1); 
angulation_deg(1) = -angulation_deg(1);

FOV_mm = header.FOV_mm([3 1 2]);

this.update(...
    'resolution_mm', resolution_mm, ...
    'offcenter_mm', offcenter_mm, ...
    'rotation_deg', angulation_deg, ...
    'FOV_mm', FOV_mm, ...
    'TR_s', header.TR_s, ...
    'coordinateSystem', 'scanner'); 
%TODO make coord system philips and incorporate axis change!
