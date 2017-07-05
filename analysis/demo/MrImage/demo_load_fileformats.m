% Script demo_load_fileformats
% Shows versatile file format loading capabilities of MrImage.load
% 
% demo_load_fileformats
% 
% 
% See also
% 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2017-02-14
% Copyright (C) 2017 Institute for Biomedical Engineering
% University of Zurich and ETH Zurich
% 
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
% <http://www.gnu.org/licenses/>.
% 
% $Id$
% 
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load different types of nifti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% loads data from fileName and updates both name and parameters.save of

%%  nifti files, header is read to update MrImage.parameters
Y = MrImage('fileName.nii');

%%   cell of nifti file names (e.g. individual volumes) loaded into
%   appended matrix.
Y = MrImage({'fileName_volume001.nii', 'fileName_volume002.nii'});


% cell of nifti files (in spm12b/canonical), appended to a 4D MrImage
Y = MrImage({'avg152PD.nii';'avg152T1.nii'; 'avg152T2.nii'});

%   analyze files, header is read to update MrImage.parameters
Y = MrImage('fileName.img');
% or 
Y = MrImage('fileName.hdr');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load different types file types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Philips par/rec files, load phase image of 2nd echo
Y = MrImage('fileName.rec', 'imageType', 'phase', 'iEcho', 2);

Y = MrImage('fileName.mat', 'resolution_mm', [2 2 2]);

%  matlab matrix, 'data' must be in workspace
data = rand(64, 64, 37, 200);
Y = MrImage(data, 'offcenter_mm', [110 90 -92]);

