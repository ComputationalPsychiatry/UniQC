function geometry4D = get_geometry4D(this, dimLabelsGeom)
% Converts specified dimensions into classical (e.g. nifti) 4D geometry
%
%   Y = MrDimInfo()
%   geometry4D = Y.get_geometry4D(dimLabelsGeom)
%
% This is a method of class MrDimInfo.
%
%
% IN
%   dimLabelsGeom   cell(1,4) of dimension labels constituting 4D geometry
%                   default: {x,y,z,t}
%
% OUT
%   geometry4D      FOV_mm, resolution_mm, TR_s, nVoxels will be adapted
%                   See also MrImageGeometry
%
% EXAMPLE
%   get_geometry4D
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
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
if nargin < 2
    dimLabelsGeom = {'x', 'y', 'z', 't'};
end

nDims = numel(dimLabelsGeom);

for d = 1:nDims
    iDim = this.get_dim_index(dimLabelsGeom{d});
    nVoxels(d) = this.nSamples(iDim);
    
    switch dimLabelsGeom{d}
        case 't' % temporal spacing
            TR_s = this.resolutions(iDim);
            
            % unit conversion
            switch this.units{iDim}
                case 'ms'
                    TR_s = TR_s / 1000;
            end
            
        case {'x', 'y', 'z'}
            offcenter_mm(d) = this.first(iDim);
            resolution_mm(d) = this.resolutions(iDim);
            
            % unit conversion
            switch this.units{iDim}
                case 'm'
                    resolution_mm(d) = resolution_mm(d) * 1000;
                    offcenter_mm(d) = offcenter_mm(d) * 1000;
                case 'cm'
                    resolution_mm(d) = resolution_mm(d) * 10;
                    offcenter_mm(d) = offcenter_mm(d) * 10;
            end
    end
    
end

geometry4D = MrImageGeometry([], ...
    'resolution_mm', resolution_mm, ...
    'nVoxels', nVoxels, ...
    'offcenter_mm', offcenter_mm, ...
    'TR_s', TR_s, ...
    'coordinateSystem', CoordinateSystems.nifti);
geometry4D.convert(CoordinateSystems.scanner);