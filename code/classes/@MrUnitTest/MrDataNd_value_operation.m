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

%% Changeable parameters for sine simulation
resolutionXY    = 3; %mm
nSamplesXY      = 32;
nFrequencies    = 4; % one frequency per slice, 0:.5:(nFreq/2-.5) full periods within duration of experiment
nVolumes        = 128;
TR              = 3;
dt              = 2; % in seconds %TR;%TR/16;

% 0 = no plots, 1 = shift vs raw time series plot, 2 = indvididual MrRoi.plot
verboseLevel = 1;

doPlotRoi = verboseLevel >=2;
doPlot = verboseLevel >=1;

%% Create MrDataNd object with sine frequencies
dimInfo = MrDimInfo('nSamples', [nSamplesXY nSamplesXY nFrequencies nVolumes], ...
    'resolutions', [resolutionXY, resolutionXY, 0.5, TR], ...
    'firstSamplingPoint', [resolutionXY/2, resolutionXY/2 0, 0]);

dataMatrixX = zeros(nVolumes, nFrequencies);
t = dimInfo.t.samplingPoints{1}';
fArray = 0:0.5:(nFrequencies/2-0.5);
for iFreq = 1:nFrequencies
    dataMatrixX(:,iFreq) = sin(t/(TR*nVolumes)*2*pi*(fArray(iFreq)));
end

dataMatrixX = repmat(permute(dataMatrixX, [3 4 2 1]), 64, 64, 1, 1);

%% 4D image with sinusoidal modulation of different frequency per slice
% should be dataNd, but ROI tests easier on MrImage
x = MrImage(dataMatrixX, 'dimInfo', dimInfo);
x.name = 'raw time series';
switch testVariantValueOperation
    case 'shift_timeseries'
        %% Shift time series and compare in predefined ROIs
        % define actual solution
        actSolution.data = 0;%?
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
        if doPlotRoi
            x.rois{1}.plot()
            y.rois{1}.plot()
        end
        
        % plot them together;
        if doPlot
            stringSupTitle{1} = sprintf('shift timeseries (time axis): Joint plot before/after dt = %.2f s (TR = %.2f s)', dt, TR);
            stringSupTitle{2} = sprintf('shift timeseries (volum axis): Joint plot before/after dt = %.2f s (TR = %.2f s)', dt, TR);
            for iFig = 1:2
                fh(iFig) = figure('Name', stringSupTitle{iFig}, 'WindowStyle', 'docked');
            end
            nCols = ceil(sqrt(nFrequencies));
            nRows = ceil(nFrequencies/nCols);
            t_x = x.dimInfo.t.samplingPoints{1}';
            t_y = y.dimInfo.t.samplingPoints{1}';
            for iFig = 1:2
                for iFreq = 1:nFrequencies
                    figure(fh(iFig))
                    hs = subplot(nRows, nCols, iFreq);
                    stringTitle = sprintf('f = %.1f cycles per run', fArray(iFreq));
                    
                    if iFig == 1
                        plot(t_x, x.rois{1}.data{iFreq}, 'o-'); hold all;
                        plot(t_y, y.rois{1}.data{iFreq}, 'x-');
                        xlabel('t (s)');
                    else
                        plot(x.rois{1}.data{iFreq}, 'o-'); hold all;
                        plot(y.rois{1}.data{iFreq}, 'x-');
                        xlabel('volumes');
                    end
                    if iFreq == 1, legend(hs, 'raw', sprintf('shifted by %.2f s', dt)); end
                    title(stringTitle);
                end
                suptitle(stringSupTitle{iFig});
            end
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