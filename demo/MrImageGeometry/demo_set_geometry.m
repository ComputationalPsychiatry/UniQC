% Script demo_set_geometry
% Illustrates the different components that define an image geometry.
%
%  demo_set_geometry
%
%
%   See also definition_of_geometry

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-11-05
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get example data
dataPath = get_path('data');
niftiFile4D = fullfile(dataPath, 'nifti', 'rest', 'fmri_short.nii');
dataRaw = MrImage(niftiFile4D);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Create MrImage object from matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% no geometry information is supplied, defaults are used
data = MrImage(dataRaw.data);
dataOrig = MrImage(dataRaw.data);
dataOrig = dataOrig.select('t', 1);
dataOrig.parameters.save.fileName = 'orig.nii';
disp_centre_and_origin(data);
data.plot('plotType', 'spmi');
% note: first sampling point is 1, not the centre of the voxel (assuming a
% resolution of 1, which would correspond to 0.5)
% note 2: origin is in [-1 -1 -1], should it be in [0 0 0]?
ADimInfo = data.dimInfo.get_affine_matrix;
data.affineGeometry.update_from_affine_matrix(data.affineGeometry.affineMatrix/ADimInfo);
data.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Add resolution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot data using the classical way, but adding sampling points
% (this option is only available with the image processing toolbox)
iptsetpref('ImshowAxesVisible', 'on');
f = data.plot;
a = f.CurrentAxes;
nX = round(a.XLim(2)/data.dimInfo.nSamples(1));
xAxis = repmat(data.dimInfo.samplingPoints{1}, [1,nX]);
a.XTickLabel = xAxis(a.XTick);
nY = round(a.YLim(2)/data.dimInfo.nSamples(2));
yAxis = repmat(data.dimInfo.samplingPoints{2}, [1,nY]);
a.YTickLabel = yAxis(a.YTick);

data.dimInfo.resolutions = dataRaw.dimInfo.resolutions;
disp_centre_and_origin(data);
data.plot('plotType', 'spmi', 'overlayImages', dataOrig);
% note: origin changes now. Is that what we want? Centre voxel is
% maintained, though.

f = data.plot;
a = f.CurrentAxes;
nX = round(a.XLim(2)/data.dimInfo.nSamples(1));
xAxis = repmat(data.dimInfo.samplingPoints{1}, [1,nX]);
a.XTickLabel = xAxis(a.XTick);
nY = round(a.YLim(2)/data.dimInfo.nSamples(2));
yAxis = repmat(data.dimInfo.samplingPoints{2}, [1,nY]);
a.YTickLabel = yAxis(a.YTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Add Shear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% none of these options will affect matrix plot
data.affineGeometry.shear = [0.5 0 0];
data.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Add Rotation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.affineGeometry.shear = [0 0 0];
data.affineGeometry.rotation_deg = [0 30 0];
data.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Add Translation (offcentre_mm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data.affineGeometry.offcenter_mm(3) = data.affineGeometry.offcenter_mm(3) + 10;
data.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 5. Start with origin in centre of block (set via dimInfo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSamples = data.dimInfo.nSamples;
firstSamplingPoint = [-nSamples(1)/2+0.5, -nSamples(2)/2+0.5, ...
    -nSamples(3)/2+0.5, 0];
% this does not work :/ todo!
data2 = MrImage(dataRaw.data, 'nSamples', nSamples, ...
    'firstSamplingPoint', firstSamplingPoint);
% try again
clear data2;
dimInfo2 = MrDimInfo('nSamples', nSamples, 'firstSamplingPoint', firstSamplingPoint);
data2 = MrImage(dataRaw.data, 'dimInfo', dimInfo2);
% plot
data2.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data2);
data2.plot('plotType', 'spmi');

f = data2.plot;
a = f.CurrentAxes;
nX = round(a.XLim(2)/data2.dimInfo.nSamples(1));
xAxis = repmat(data2.dimInfo.samplingPoints{1}, [1,nX]);
a.XTickLabel = xAxis(a.XTick);
nY = round(a.YLim(2)/data2.dimInfo.nSamples(2));
yAxis = repmat(data2.dimInfo.samplingPoints{2}, [1,nY]);
a.YTickLabel = yAxis(a.YTick);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4. Add Rotation (2nd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data2.affineGeometry.rotation_deg = [0 30 0];
data2.plot('plotType', 'spmi', 'overlayImages', dataOrig);
disp_centre_and_origin(data2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 6. Example with slightly different origins
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data2.affineGeometry.rotation_deg = [0 0 0];
dimInfo3 = MrDimInfo('nSamples', nSamples, 'firstSamplingPoint', firstSamplingPoint+[10, 10, 5, 0]);
data3 = MrImage(dataRaw.data, 'dimInfo', dimInfo3);
data3 = data3.select('t', 1);
data2.plot('plotType', 'spmi', 'overlayImages', data3);
disp_centre_and_origin(data2);
disp_centre_and_origin(data3);

data2rot = data2.copyobj;
data2rot.parameters.save.fileName = 'data2rot.nii';
data3rot = data3.copyobj;
data3rot.parameters.save.fileName = 'data3rot.nii';

data2rot.affineGeometry.rotation_deg = [0 0 30];
data3rot.affineGeometry.rotation_deg = [0 0 30];
data2.plot('plotType', 'spmi', 'overlayImages', {data3, data2rot.select('t', 1), data3rot});

