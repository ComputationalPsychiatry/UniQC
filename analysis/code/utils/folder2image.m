function outputImage = folder2image(pathFolder, filePrefix, ...
    dimensionLabels, savedVariable)
% Collects mat-files of slices (e.g. from Recon-code), and combines to
% MrImage
%
%   output = folder2image(input)
%
% IN
%   pathFolder      name (string) of folder where all mat-files are stored
%   filePrefix      start string that all mat-files share, e.g. 'recon_'
%   dimensionLabels cell of string parts of file name distinguishing
%                   3rd and 4th image dimension,
%                   e.g. {'sli', 'dyn'}
%   savedVariable   in which 2D (slice) data is saved
%                   default 'data'
%   labelSeparator  char that separates dimensionLabels, default: _
%                   (e.g. recon_sli001_dyn0001_echo01.mat)
% OUT
%
% EXAMPLE
%   folder2image
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2015-12-15
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
% $Id$

if nargin < 1
    pathFolder = '/Users/kasperla/Temp/Output/Reconstructions/Default/8';
end

if nargin < 2
    filePrefix = 'recon';
end

if nargin < 3
    dimensionLabels = {'sli', 'echo'};
end

if nargin < 4
    savedVariable = 'data_sos';
end

if nargin < 5
    labelSeparator = '_';
end

matFileArray = dir(fullfile(pathFolder, [filePrefix, '*.mat']));
matFileArray = {matFileArray.name}';

nFiles = numel(matFileArray);

sliceLabel = dimensionLabels{1};
volumeLabel = dimensionLabels{2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine number of valid slices/volumes indices from file names in directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iDim = 1:2
    dimLabel = dimensionLabels{iDim};
    
    % Extract 'dyn0001', 'dyn0002' , ...etc substrings from all file names
    [extractedDimSubstring{iDim}, extractedOtherSubstring] = ...
        regexp(matFileArray, [dimLabel '([\d]*)'], 'match', 'split');
    
    % Each cell was transformed into {}{} cell, take 1st element only
    extractedDimSubstring{iDim} = cellfun(@(x) x{1}, extractedDimSubstring{iDim}, ...
        'UniformOutput', false);
    
    prefixFileStringArray{iDim} = cellfun(@(x) x{1}, extractedOtherSubstring, ...
        'UniformOutput', false);
    suffixFileStringArray{iDim} = cellfun(@(x) x{2}, extractedOtherSubstring, ...
        'UniformOutput', false);
    
    
    % Remove label, and transform remaining string to number
    iDimArray{iDim} = cell2mat(cellfun(@(x) str2num(...
        regexprep(x, dimLabel, '')), extractedDimSubstring{iDim}, ...
        'UniformOutput', false));
    
    nDims(iDim) = max(iDimArray{iDim});
end

foundRepresentative = false;

% find at least one dataset to get dimensions from
for iVolume = 1:nDims(2)
    for iSlice = 1:nDims(1)
        iFile = find(iDimArray{1} == iSlice & ...
            iDimArray{2} == iVolume);
        
        foundRepresentative = ~isempty(iFile);
        if foundRepresentative
            break;
        end
    end
end
load(fullfile(pathFolder, matFileArray{iFile}));
data = eval(savedVariable);
zeroImage = zeros(size(data));

% read in geometry parameters from Recon-saved file
if exist('geom', 'var')
    resolutionMillimeters = (geom.FOV./geom.matrix_size);
    resolutionMillimeters(3) = geom.slice_gap + geom.slice_thickness;
    resolutionMillimeters = resolutionMillimeters * 1000;
end


for iVolume = 1:nDims(2)
    for iSlice = 1:nDims(1)
        iFile = find(iDimArray{1} == iSlice & ...
            iDimArray{2} == iVolume);
        
        if ~isempty(iFile)
            fileSlice = fullfile(pathFolder, matFileArray{iFile});
            load(fileSlice, savedVariable);
            data = eval(savedVariable);
       else
            % generate dummy data...but how, if no previous one existing?
            data = zeroImage;
        end
        if iSlice == 1
            newVolume = MrImage(data, 'resolutionMillimeters', ...
                resolutionMillimeters);
        else
            newVolume.append(data);
        end
    end
    
    % Assembled volume appended to time series
    if iVolume == 1
        outputImage = newVolume;
    else
        outputImage.append(newVolume);
    end
end