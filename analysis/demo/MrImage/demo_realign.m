% Script demo_realign
% Shows realignment for n-dimensional data with different scenarios of 4D
% subsets feeding into estimation, and parameters applied to other subsets,
% e.g.
%   - standard 4D MrImageSpm realignment
%   - multi-echo data, 1st echo realigned, applied to all echoes
%   - complex data, magnitude data realigned, phase data also shifted
%   - multi-coil data, root sum of squares realigned, applied to each coil
%
%  demo_realign
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-25
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. 4D fMRI, real valued, standard realignment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

% load data
Y4d = MrImageSpm4D(fileTest);

[~,rp] = Y4d.realign();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. 5D multi-echo fMRI, standard realignment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataPath = 'C:\Users\uqsboll2\Desktop\multi_echo';
filenames = {fullfile(dataPath, '20150709_145603BPep2dMEMSTR06525mms013a001.nii'), ...
    fullfile(dataPath, '20150709_145603BPep2dMEMSTR06525mms014a001.nii'), ...
    fullfile(dataPath, '20150709_145603BPep2dMEMSTR06525mms015a001.nii')};

TE = [9.9, 27.67 45.44];

for nFiles = 1:numel(filenames)
    Isingle{nFiles} = MrImage(filenames{nFiles});
    Isingle{nFiles}.dimInfo.add_dims('echo', 'units', 'ms', 'samplingPoints', TE(nFiles));
end

I = Isingle{1}.combine(Isingle);

I.realign('applicationIndexArray', {'echo', 1:3});
