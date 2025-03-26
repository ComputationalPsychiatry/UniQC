function X = tapas_uniqc_dicom_mosaic2image(pathDicom)
% Computes MrImage from Dicom-Folder with mosaic images (over slices), one
% image per volume
%
%   X = tapas_uniqc_dicom_mosaic2image(pathDicom)
%
% IN
%   pathDicom   folder with mosaic-style *.IMA or DCM files (DICOM) or paht
%               to a single file
% OUT
%
% EXAMPLE
%   tapas_uniqc_dicom_mosaic2image
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-02-02
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

if nargin < 1
    pathDicom = pwd;
end

%% try to find dicom files (.dcm or .ima)
fileNames = {};
if isfile(pathDicom)
    fileNames = {pathDicom};
else
    d = dir(fullfile(pathDicom, '*.IMA'));
    if isempty(d)
        d = dir(fullfile(pathDicom, '*.dcm'));
    end
    fileNames = strcat(pathDicom, filesep, {d.name}');
end

nFiles = numel(fileNames);

if nFiles == 0
    error('tapas:uniqc:MrDataNd:UnsupportedOrNonExistingDICOMFile', ...
        'DICOM file non-existing or with unsupported extension');
end

%% read first dicom file header to determine dimensions

dimInfo = MrDimInfo(fileNames{1});

dimInfo.nSamples(4) = nFiles;

nSamples = dimInfo.nSamples;


% TODO: check whether 1&2 should be reversed
info = dicominfo(fileNames{1});
nSlicesMosaicRow = info.Rows/nSamples(1);
nSlicesMosaicCol = info.Columns/nSamples(2);

data = zeros(nSamples);

%% read all files in loop
for n = 1:nFiles
    mosaicData = dicomread(fileNames{n});
    volData = reshape(permute(reshape(mosaicData, ...
        [nSamples(1) nSlicesMosaicCol nSamples(2) nSlicesMosaicRow]), ...
        [1 3 4 2]), ...
        nSamples(1), nSamples(2), []);
    data(:,:,:,n) = volData(:,:,1:nSamples(3));
end

%%
X = MrImage(data, 'dimInfo', dimInfo);

% create reasonable name for image
nameImage = pathDicom;
nameImage(1:end-30) = [];
nameImage = ['...' nameImage];
X.name = nameImage;

%% TODO: adjust affine geometry according to http://nipy.org/nibabel/dicom/dicom_mosaic.html