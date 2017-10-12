function this = set_from_geometry4D(this, geometry)
% initializes dimInfo from MrImageGeometry (nifti etc) with standard labels
%
%   Y = MrDimInfo()
%   Y.set_from_geometry4D(geometry)
%
% This is a method of class MrDimInfo.
%
% IN
%   geometry    MrImageGeometry (4D nifti...)
%
% OUT
%
% EXAMPLE
%   set_from_geometry4D
%
%   See also MrDimInfo
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-10-12
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

% or add them...
dimLabelsGeom = {'x','y','z', 't'};
units = {'mm', 'mm', 'mm', 's'};
iDimGeom = 1:4;

% update existing geom dimensions, add new ones for
% non-existing
iValidDimLabels = this.get_dim_index(dimLabelsGeom);
iDimGeomExisting = find(iValidDimLabels);
iDimGeomAdd = setdiff(iDimGeom, iDimGeomExisting);

resolutions = [geometry.resolution_mm geometry.TR_s];
firstSamplingPoint = [geometry.offcenter_mm 0];

% if dimension labels exist, just update values
this.set_dims(dimLabelsGeom(iDimGeomExisting), ...
    'resolutions', resolutions(iDimGeomExisting), ...
    'nSamples', geometry.nVoxels(iDimGeomExisting), ...
    'firstSamplingPoint', firstSamplingPoint(iDimGeomExisting), ...
    'units', units(iDimGeomExisting));

% if they do not exist, create dims
this.add_dims(dimLabelsGeom(iDimGeomAdd), ...
    'resolutions', resolutions(iDimGeomAdd), ...
    'nSamples', geometry.nVoxels(iDimGeomAdd), ...
    'firstSamplingPoint', firstSamplingPoint(iDimGeomAdd), ...
    'units', units(iDimGeomAdd));