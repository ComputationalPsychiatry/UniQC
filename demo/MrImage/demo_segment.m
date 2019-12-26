% Script demo_segment
% Illustrates usage of segment for 3D and 4D images, and the additional
% parameters available in the batch editor
%
%  demo_segment
%
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-12-01
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

clear;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0. Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathData            = get_path('examples');
fileFunctionalMean  = fullfile(pathData, 'nifti', 'rest', 'lowRes_struct.nii');
m = MrImage(fileFunctionalMean);

m.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Segment image with additional outputs and SPM parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the outputs are the tissue probability maps (can be used for maks
% generation, for example), the deformation fields, the (inverse) bias
% field and the bias corrected image
% Note: sampling distance is increased from its default value (3) to speed
% up the segmentation process

% all output parameters
[biasFieldCorrected, tissueProbMaps, deformationFields, biasField] = ...
    m.segment('samplingDistance', 20);

biasFieldCorrected.plot;
nTPM = numel(tissueProbMaps);
for n = 1:nTPM
    tissueProbMaps{n}.plot;
end
deformationFields{1}.plot;
biasField{1}.plot;

% all tissue types, larger bias FWHM, no clean up
tissueTypes = {'WM', 'GM', 'CSF', 'bone', 'fat', 'air'};
biasRegularisation = 1e-4;
biasFWHM = 90;
cleanUp = 0;

[biasFieldCorrected2, tissueProbMaps2, deformationFields2, biasField2] = ...
    m.segment('samplingDistance', 20, 'tissueTypes', tissueTypes, ...
    'biasRegularisation', biasRegularisation, 'biasFWHM', biasFWHM, ...
    'cleanUp', 0);

biasFieldCorrected2.plot;
nTPM2 = numel(tissueProbMaps2);
for n = 1:nTPM2
    tissueProbMaps2{n}.plot;
end
deformationFields2{1}.plot;
biasField2{1}.plot;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Segment 5D image with additional contrasts (channels)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load multi-echo data
pathData = get_path('examples');
pathMultiEcho = fullfile(pathData, 'nifti', 'data_multi_echo');
ME = MrImage(fullfile(pathMultiEcho, 'multi_echo*.nii'));
TE = [9.9, 27.67 45.44];
ME.dimInfo.set_dims('echo', 'units', 'ms', 'samplingPoints', TE);
ME.dimInfo.set_dims('t', 'resolutions', 0.65);

% this is a toy example, so we only choose a few time points
MESmall = ME.select('t', [1, 7, 8]);

% segment
% note that all dimensions except x, y and z will be treated as additional
% channels
[biasFieldCorrected3, tissueProbMaps3, deformationFields3, biasField3] = ...
    MESmall.segment('samplingDistance', 20);
for t = 1:MESmall.dimInfo.t.nSamples
    MESmall.plot('z', 23, 't', t, 'sliceDimension', 'echo', 'displayRange', [0 1400]);
    biasFieldCorrected3.plot('z', 23, 't', t, 'sliceDimension', 'echo', 'displayRange', [0 1400]);
end

nTPM3 = numel(tissueProbMaps3);
for n = 1:nTPM3
    tissueProbMaps3{n}.plot;
end
deformationFields3{1}.plot;
biasField3{1}.plot('t', 1:3);

%% Segment complex image
cm = m.copyobj();
cmI = (cm + 300*randn(cm.dimInfo.nSamples)).*(1i);
cm.data = cm.data + cmI.data;

cm.real.plot();
cm.imag.plot();
bcm = cm.segment();
bcm.real.plot();
bcm.imag.plot();