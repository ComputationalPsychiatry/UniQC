function [dimLabels, resolutions, nSamples, units, firstSamplingPoint] = ...
    read_dicom(~, fileName)
% Reads nifti files and extracts properties for dimInfo
%
%   Y = MrDimInfo()
%   [dimLabels, resolutions, nSamples, units] = Y.read_dicom(fileName)
%   used in Y.load(fileName)
%
% This is a method of class MrDimInfo.
%
% IN
%
% OUT
%
% EXAMPLE
%   read_dicom
%
%   See also MrDimInfo

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2021-10-28
% Copyright (C) 2021 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%


info = dicominfo(fileName);
resolutions = zeros(1,4);
resolutions(1:2) = double(info.PixelSpacing);
resolutions(4) = info.RepetitionTime/1000;
resolutions(3) = info.SpacingBetweenSlices;
samplingWidths = resolutions;
samplingWidths(3) = info.SliceThickness;

% The following metadata are probably site/release-specific
nSamples = zeros(1,4);
nSamples(1:2) = double(sscanf(info.Private_0051_100b, '%d*%d'));

% TODO: rather use NumberOfImagesInMosaic from private Siemens header
% (CSA)
% info=spm_dicom_headers(file)
% info{1}.CSAImageHeaderInfo(22).item(1)
% ...or is that the same?
nSamples(3) = info.Private_0019_100a;
nSamples(4) = 1;

FOV = (nSamples.*resolutions);
firstSamplingPoint = [-FOV(1:3)/2, 0];

%% to get dimLabels and units
tempDimInfo = MrDimInfo('resolutions', resolutions, 'nSamples', nSamples, ...
    'firstSamplingPoint', firstSamplingPoint , 'samplingWidths', samplingWidths);
dimLabels = tempDimInfo.dimLabels;
units = tempDimInfo.units;


