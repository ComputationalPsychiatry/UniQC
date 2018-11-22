% Script demo_reorient_geometries
% Shows how to reorient different functional runs/anatomy to a common space
% for voxel-wise comparisons
%
%  demo_reorient_geometries
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-12-01
% Copyright (C) 2015 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

%
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
pathExamples    = get_path('data');
pathGeom        = fullfile(pathExamples, 'nifti', 'reorient_geometries');

fileArray = {
    'fmri1_minus20degRL.nii';
    'fmri2_plus20degRL.nii';
    'struct_transversal.nii'
    };


Img = cell(3,1);
for n = 1:3
    Img{n} = MrImage(fullfile(pathGeom, fileArray{n}));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Data to show different geometry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:3
    nSlices1 = Img{n}.geometry.nVoxels(1);
    Img{n}.plot('sliceDimension', 1, 'rotate90', 2, ...
        'selectedSlices', round(nSlices1/2+(-8:7)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Attempt re-sizing/slicing to geometry of 3rd, anatomical image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rImg = cell(3,1);
for n = 1:2
    rImg{n} = Img{n}.copyobj.reslice(Img{3});
end

%%
for n = 1:2
    nSlices1 = rImg{n}.geometry.nVoxels(1);
  %  rImg{n}.plot('sliceDimension', 1);
    rImg{n}.plot('sliceDimension', 1, 'rotate90', 2, ...
        'selectedSlices', round(nSlices1/2+(-8:7)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Coregister functional images to each other
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

crImg = cell(3,1);
for n = 1:2
    crImg{n} = rImg{n}.copyobj;
end

% NOTE: if done as follows, there will be the geometry overwritten...
%crImg{2} = crImg{2}.coregister_to(crImg{1});
crImg{2}.coregister_to(crImg{1});

%
for n = 1:2
    nSlices1 = crImg{n}.geometry.nVoxels(1);
  %  rImg{n}.plot('sliceDimension', 1);
    crImg{n}.plot('sliceDimension', 1, 'rotate90', 2, ...
        'selectedSlices', round(nSlices1/2+(-8:7)));
end


%% Plot outcome of coregistration
crImg{2}.plot_overlays(crImg{1}, 'selectedSlices', 100:3:200, 'overlayMode', 'edge');
crImg{2}.plot_overlays(crImg{1}, 'selectedSlices', 71:7:180, 'sliceDimension',1, 'rotate90', 2, 'overlayMode', 'edge');