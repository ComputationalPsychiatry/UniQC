% Script demo_change_geometry
% How to change the gemetry parameters (shift, rot, zoom, shear) in
% MrImageGeometry or MrDimInfo (axis-parallel shift and zoom only)
%
%  demo_change_geometry
%
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-12-03
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
doInteractivePlot = 0;
% get example data
dataPath = get_path('data');
niftiFileStruct = fullfile(dataPath, 'nifti', 'rest', 'lowRes_struct_noGeom.nii');
mLoad = MrImage(niftiFileStruct);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Make up geometry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m = MrImage(mLoad.data);
m.plot();
if doInteractivePlot, m.plot('plotType', 'spmi'); end
% set start geometry
m.dimInfo.resolutions = [1 1.5 2];
m.plot();
% set start offcenter
m.dimInfo.set_dims(3, 'firstSamplingPoint', m.dimInfo.samplingPoints{3}(1)+10);
m.plot();

% all over parameters are set in affineTransformation and will not impact
% the plot
m.affineTransformation.rotation_deg = [30 0 0];
m.affineTransformation.shear = [0 0.2 0];
disp(m.affineTransformation);
if doInteractivePlot, m.plot('plotType', 'spmi'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Changes in world space (just as SPM display would do)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is our starting geometry
disp(m.geometry);
% we cannot change m.geometry directly, because it is always derived on the
% fly from affineTransformation and dimInfo
% changes in world space do not affect dimInfo

shiftedImage = m.shift([3 10 0]);
if doInteractivePlot, m.plot('plotType', 'spmi', 'overlayImages', shiftedImage); end

roatedImage = m.rotate([0 0 45]);
if doInteractivePlot, m.plot('plotType', 'spmi', 'overlayImages', roatedImage); end

% setting to a specific value
% offcenter_mm = position of the first voxel
% is combination of the shifts specicified in dimInfo and affineTrafo
m.affineTransformation.offcenter_mm = [-5 10 3];
disp(m.geometry.offcenter_mm);

setM = m.copyobj();
newGeom = m.geometry.copyobj();
newGeom.offcenter_mm = -newGeom.FOV_mm(1:3)/2;
newAffineTrafoMatrix = newGeom.get_affine_matrix()/setM.dimInfo.get_affine_matrix();
setM.affineTransformation.update_from_affine_matrix(newAffineTrafoMatrix);

% the same applies for shear
newGeom.shear = [0 0.2 0]; % that's what we originally wanted
newAffineTrafoMatrix = newGeom.get_affine_matrix()/setM.dimInfo.get_affine_matrix();
setM.affineTransformation.update_from_affine_matrix(newAffineTrafoMatrix);

% now changing the origin, i.e. axis parallel shifts
setO = m.copyobj();
affineM = setO.geometry.get_affine_matrix();
invAffineM = inv(affineM);
% now set origin
invAffineM(1:3, 4) = [60 50 10];
newAffineM = inv(invAffineM);

newAffineT = newAffineM/setM.dimInfo.get_affine_matrix();
setO.affineTransformation.update_from_affine_matrix(newAffineT);

disp(m.geometry);
disp(setO.geometry);

disp(m.geometry.get_origin);
disp(setO.geometry.get_origin);