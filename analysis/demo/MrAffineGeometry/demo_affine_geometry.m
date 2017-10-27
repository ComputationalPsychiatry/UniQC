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

dataPath = get_path('data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load from Nifti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
niftiFile4D = fullfile(dataPath, 'nifti', 'rest', 'fmri_short.nii');
affineGeometryNifti = MrAffineGeometry(niftiFile4D);
disp(affineGeometryNifti);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load from Par/Rec
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parRecFile = fullfile(dataPath, 'parrec/rest_feedback_7T', 'fmri1.par');
affineGeometryParRec = MrAffineGeometry(parRecFile);
disp(affineGeometryParRec);