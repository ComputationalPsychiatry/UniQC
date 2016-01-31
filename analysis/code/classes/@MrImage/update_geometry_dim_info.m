function this = update_geometry_dim_info(this, varargin)
% Updates Image geometry and keeps corresponding dimInfo in sync
%
%   Y = MrImage()
%   Y.update_geometry_dim_info(varargin)
%
% This is a method of class MrImage.
%
% IN
%   dependent   'geometry' or 'dimInfo';
%               specifies which of the two image properties is the
%               dependent one and will be updated according to the other
%               one
%               default: 'dimInfo'
%   dimLabels   cell(1,nUpdatedDims) of dimensions updated in dimInfo
%               (only, if geometry is dependent!, otherwise {'x','y','z',t'} 
%               is assumed)
% OUT
%
% EXAMPLE
%   update_geometry_dim_info
%
%   See also MrImage MrDimInfo.get_geometry4D
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

% create dim-Info, if not existing
defaults.dependent = 'dimInfo'; % 'dimInfo' or 'geometry'
defaults.dimLabels = []; % dimLabels for change of dimInfo via this method
[argsUpdate, argsUnused] = propval(varargin, defaults);

dimLabelsGeom = {'x', 'y', 'z', 't'};
dimUnitsGeom = {'mm', 'mm', 'mm', 's'};


switch lower(argsUpdate.dependent)
    case 'diminfo' % dimInfo updated from geometry-change
        argsGeometry = argsUnused;
        
        % Create dimInfo with right dimLabels/units, if it does not exist
        if isempty(this.dimInfo)
            this.dimInfo = MrDimInfo('dimLabels', dimLabelsGeom, ...
                'units', dimUnitsGeom);
        end
        
        % convert geometry for correct offcenter-calculation from 1st voxel corner!
        geometryNifti = this.geometry.copyobj.convert(...
            CoordinateSystems.nifti);
        
        this.geometry.update(argsGeometry{:});
        
        % combined 4D resolution, TR is spacing in t, i.e. temporal
        % resolution
        resolutions = [this.geometry.resolution_mm, this.geometry.TR_s];
        
        
        % Set all relevant dimensions, identified by typical labels
        this.dimInfo.set_dims(dimLabelsGeom, ...
            'units', dimUnitsGeom, ...
            'nSamples', this.geometry.nVoxels, ...
            'resolutions', resolutions, ...
            'firstSamplingPoint', [geometryNifti.offcenter_mm 0]);
        
    case 'geometry' % geometry updated from dimInfo
        
        % update all dimensions, if not specified otherwise
        if isempty(argsUpdate.dimLabels)
            argsUpdate.dimLabels = this.dimInfo.dimLabels;
        end
        
        % Update dimInfo by given parameters
        argsDimInfo = argsUnused;
        this.dimInfo.set_dims(argsUpdate.dimLabels, argsDimInfo{:});
        
        % Create dummy geometry
        geometry4D = this.dimInfo.get_geometry4D(dimLabelsGeom);
       
        this.geometry.update(...
            'nVoxels', geometry4D.nVoxels, ...
            'resolution_mm', geometry4D.resolution_mm, ...
            'TR_s', geometry4D.TR_s);
        
end