% Script demo_load_fileformats - to be excluded
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

pathExamples    = get_path('data');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Load different types of nifti
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% a) load data from fileName and updates both name and parameters.save of
% nifti files, header is read to update MrImage.parameters
fileName = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

Y1 = MrImage(fileName);
disp(Y1);
disp(Y1.dimInfo);

% b) load data from fileName with different load options

% selectedVolumes: Note that selectedVolumes is specific to loading nifti,
% cpx and par/rec files and refers to the 4rd dimension of the loaded data;
% the advantage is it avoids loading the full data and then selecting a subset.
Y2 = MrImage(fileName, 'selectedVolumes', 3:2:9);
disp(Y2.dimInfo);

% updateProperties: Note that per default the name of the MrImage object is
% set to the file. For more information see MrDataNd.read_single_file. In
% the example here, the save parameters are set to the load path. Per
% default, a new path depending on the pwd is created to prevent accidental
% overwrite. Be careful with this option!
Y3 = MrImage(fileName, 'updateProperties', 'save');
disp(Y3.parameters.save);

% c) load data from fileName with additinal dimInfo information

% default: The dimInfo information is gathered from the header (same as Y1,
% nothing to do here).
Y4 = MrImage(fileName);

% fileName_dimInfo.mat: An additional dimInfo.mat file exisits.
Y4.dimInfo.units = {'this', 'and', 'that', 'too'};
Y4.save;

% load file, dimInfo is automatically added
Y5 = MrImage(Y4.get_filename);
disp(Y5.dimInfo);

% compare to only loading the nifti file
[fp, fn] = fileparts(Y4.get_filename);
delete(fullfile(fp, [fn, '_dimInfo.mat']));
Y6 = MrImage(Y4.get_filename);
disp(Y6.dimInfo);

% restore correct dimInfo via dimInfo argument
Y7 = MrImage(Y4.get_filename, 'dimInfo', Y5.dimInfo);

disp(Y7.dimInfo);

% or, alternatively, via prop/val pair
Y8 = MrImage(Y4.get_filename, 'units', Y4.dimInfo.units);
disp(Y8.dimInfo)

%% 2. Load multiple files in folder
% a) load multiple .nii files in folder with filenames containing additional
% dimension information but no additinal _dimInfo.mat files
fileNameSplit = fullfile(pathExamples, 'nifti', 'split2', 'units');
YSplit = MrImage(fileNameSplit);


% b) load multiple .nii files in folder without the filenames containing
% dimension information
fileNameSplitRes = fullfile(pathExamples, 'nifti', 'split_residual_images');
YSplitRes = MrImage(fileNameSplitRes);



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

