function this = MrDataNd_value_operation(this, testVariantValueOperation)
% Unit test for MrDataNd for arithmetic operations (perform binary
% operation)
%
%   Y = MrUnitTest()
%   run(Y, 'MrDataNd_value_operation')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDataNd_value_operation
%
%   See also MrUnitTest

% Author:   Saskia Bollmann
% Created:  2018-02-08
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


%% create MrDataNd object with sine frequencies
resolutionXY    = 3; %mm
nSamplesXY      = 64;
nFrequencies    = 32; % one frequency per slice, 0:.5:(nFreq/2-.5) full periods within duration of experiment
nVolumes        = 128;
TR              = 1;
dt              = TR;%TR/16;

dimInfo = MrDimInfo('nSamples', [nSamplesXY nSamplesXY nFrequencies nVolumes], ...
    'resolutions', [resolutionXY, resolutionXY, 0.5, TR], ...
    'firstSamplingPoint', [resolutionXY/2, resolutionXY/2 0, 0]);

dataMatrixX = zeros(nVolumes, nFrequencies);
t = dimInfo.t.samplingPoints{1}';
fArray = 0:0.5:(nFrequencies/2-0.5);
for f = 1:nFrequencies
    dataMatrixX(:,f) = sin(t/(TR*nVolumes)*2*pi*(fArray(f)));
end

% figure; plot(dataMatrixX)

dataMatrixX = repmat(permute(dataMatrixX, [3 4 2 1]), 64, 64, 1, 1);

%% 4D image with sinusoidal modulation of different frequency per slice
% should be dataNd, but ROI tests easier on MrImage
x = MrImage(dataMatrixX, 'dimInfo', dimInfo); 
x.name = 'raw time series';
switch testVariantValueOperation
    case 'shift_timeseries'
        %% Shift time series and compare in predefined ROIs
        % define actual solution
        actSolution = 0;%?
        % define expected solution
        expSolution = 0;%;dataMatrixX - dataMatrixY;
        y = x.shift_timeseries(dt);
        y.name = 'shifted time series';
        
        % define mask of one central voxel, over all slices
        M = x.select('t',1);
        iMaskVoxelXY = round([nSamplesXY/2, nSamplesXY/2]);
        M.data(:) = 0;
        M.data(iMaskVoxelXY(1), iMaskVoxelXY(2), :) = 1;
        
        % extract roi from both raw and shifted data
        x.extract_rois(M);
        x.compute_roi_stats();
        
        y.extract_rois(M);
        y.compute_roi_stats();
        
        % plot with corresponding time vector
        x.rois{1}.plot()
        y.rois{1}.plot()
        
        % plot them together;
        stringTitle = sprintf('shift_timeseries: Joint plot before/after dt = %f', dt);
        figure('Name', stringTitle);
        nCols = ceil(sqrt(nFrequencies+1));
        nRows = ceil((nFrequencies+1)/nCols);
        
        for f = 1:nFrequencies
           subplot( 
        end
        
        
    otherwise
        actSolution.data = 0;
        expSolution = 0;
        warning(sprintf('No test for value operation %s yet. Returning OK', testVariantValueOperation));
end

%% verify equality of expected and actual solution
% import matlab.unittests to apply tolerances for objects
this.verifyEqual(actSolution.data, expSolution, 'absTol', 10e-7);


end