% Script demo_affine_geometry
% Exemplifies loading of AffineGeometry from different data types
%
%  demo_affine_geometry
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-10-27
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
% $Id: new_script2.m 354 2013-12-02 22:21:41Z kasperla $
%

clear;
close all;
clc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create and display empty MrAffineTransformation object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

affineGeometry = MrAffineTransformation();
disp(affineGeometry);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load from Nifti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataPath = get_path('data');
niftiFile4D = fullfile(dataPath, 'nifti', 'rest', 'fmri_short.nii');
affineGeometryNifti = MrAffineTransformation(niftiFile4D);
disp(affineGeometryNifti);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load from Par/Rec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parRecFile = fullfile(dataPath, 'parrec/rest_feedback_7T', 'fmri1.par');
affineGeometryParRec = MrAffineTransformation(parRecFile);
disp(affineGeometryParRec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create using prop/val
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

affineGeometry2 = MrAffineTransformation('offcenter_mm', [3 -5 6], ...
    'rotation_deg', [15 20 -20], 'resolution_mm', [2.5 2.5 2]);
disp(affineGeometry2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create using affine Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
affineGeometry3 = MrAffineTransformation(affineGeometry2.affineMatrix);
disp(affineGeometry3);