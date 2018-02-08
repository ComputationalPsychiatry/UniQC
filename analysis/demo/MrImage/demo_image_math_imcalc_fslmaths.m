% function output = demo_math_with_two_images()
% Unit Test for perform_binary_operation on example dataset
%
%   output = demo_math_with_two_images(input)
%
% IN
%
% OUT
%
% EXAMPLE
%   demo_math_with_two_images
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-11-18
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load example files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

S       = MrSeries(fileTest);

S.data.plot();
S.data.plot('selectedSlices', 1, 'selectedVolumes', Inf, ...
    'fixedWithinFigure', 'slice');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Perform Test Operations on statistical image functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

meanS       = S.data.mean();
meanS.name  = 'meanS';

stdS        = S.data.std();
stdS.name   = 'stdS';

% old compute SNR
snrS1       = S.data.snr();
snrS1.name  = 'snrS1';

% compute SNR via binary operation
snrS2       = meanS./stdS;
snrS2.name  = 'snrS2';

% a somehow self-referring test, since we use perform_binary_operation :-)
deltaSnr    = snrS2 - snrS1;
deltaSnr.name = 'deltaSnr';

relDeltaSnr         = (snrS2 - snrS1)./snrS1;
relDeltaSnr.name    = 'relDeltaSnr';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Report and compare to expected results by plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

snrS1.plot;
snrS2.plot

% should be all zero
deltaSnr.plot;
relDeltaSnr.plot;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Difference of time series and Fourier analysis in space and time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diffS = S.data.diff;

fftSSpace = fft(S.data, '2D');

backTransformedS = ifft(fftSSpace, '2D');

% perform FFT along time dimension, extract region data and plot it
fftTime = fft(S.data, 4);

maskMean = meanS.compute_mask('threshold', 0.5);
maskMean.plot();
meanS.plot();

absFftTime = abs(fftTime);
absFftTime.extract_rois(maskMean);
absFftTime.compute_roi_stats();
absFftTime.plot_rois('plotType', 'timeseries');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Add random phase to image and unwrap
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

phaseS = meanS.copyobj();
offresonanceFrequency = 50*2*pi; % 50 Hz offresonance frequency

% append volumes with linearly increasing phase
for iVolume = 1:15 % milliseconds
   phaseS.append(meanS.*exp(1i*offresonanceFrequency*iVolume/1000));
end

phaseS.name = 'wrapped linear phase & mean abs';
phaseS.plot('signalPart', 'phase', 'fixedWithinFigure', ...
    'slice', 'selectedSlices', 10, 'selectedVolumes', Inf);

% unwrap phase along time dimension
unwrappedPhaseS = unwrap(phaseS);
unwrappedPhaseS.name = 'Unwrapped Phase Image';
unwrappedPhaseS.plot('fixedWithinFigure', ...
    'slice', 'selectedSlices', 10, 'selectedVolumes', Inf);
