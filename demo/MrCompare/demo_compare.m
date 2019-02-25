% Script demo_compare
% This demo shows core functionality of the MrCompare class, comparing
% arrays of MrImage and MrSeries (e.g., from different subjects, sequences)
% wrt different quality measures, and via different ways of comparison (vs
% mean, vs each other)
%
%  demo_compare
%
%
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-02-14
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
%% First demo: MrImage
%  Load time series from different subjects and combine into one MrCompare
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% Construct filenames and load data

subjectIdArray = [55, 101,102];
nSubjects = numel(subjectIdArray);

maskThreshold = 300; % signal intensity of mean
iRun = 2;

imageArray = cell(nSubjects,1);
for s=1:nSubjects
    subjectId = subjectIdArray(s);
    pathDicom = sprintf('C:/Users/kasperla/Documents/Temp/COMPI_QC/Data/compi_%04d/raw_mri/run%d', ...
        subjectId, iRun);
    fprintf('Loading %s ...\n', pathDicom);
    X = dicom_mosaic2image(pathDicom);
    imageArray{s} = X;
end
fprintf('Done.\n');

%% Create MrCompare from individual images
extraDimInfo = MrDimInfo('dimLabels', 'subjects', 'samplingPoints', {subjectIdArray}, ...
    'units', ''); 

C = MrCompare(imageArray, extraDimInfo); % TODO: also allow fileArray?

%% Combine tSNR images for all subjects

tSnr = C.combine('snr');

tSnr.plot('z', 20, 'imagePlotDim', {'x','y','subjects'}, 'sliceDimension', 'subjects');