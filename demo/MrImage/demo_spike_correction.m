% function output = test_spike_correction(input)
% Tests spike correction on matched-filter speed-modulated spiral, 1mm resolution
%
%   output = test_spike_correction(input)
%
% IN
%
% OUT
%
% EXAMPLE
%   test_spike_correction
%
%   See also
%
% Author: Lars Kasper
% Created: 2014-11-29
% Copyright (C) 2014 Institute for Biomedical Engineering, ETH/Uni Zurich.
% $Id: tedit2.m 354 2013-12-02 22:21:41Z kasperla $



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
doHighRes           = 0;

pathSubject         = 'C:\Users\uqsboll2\polybox\Shared\data\LK332_14_11_11_MFSShapeSpeedInvivo3_9\';
dirSpikeCorrection  = 'reconstructions/arrays_spike_correction_2';

pathSpikeCorrection = fullfile(pathSubject, dirSpikeCorrection);

if doHighRes
    fileSpiral          = 'imgk_speedspi33_1.mat';
else
    fileSpiral          = 'imgk_speedspi35_2.mat';
end

fileSpiral          = fullfile(pathSpikeCorrection, fileSpiral);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(fileSpiral,'imageArray', 'kArray', 'descriptionArray');
% imageArray = imageArray';

indSpikes           = 1;
indNoSpikes         = 2;

matrixSpikes        = convert_cells_to_dyns(imageArray(indSpikes, :)');
matrixNoSpikes      = convert_cells_to_dyns(imageArray(indNoSpikes, :)');
descriptionSpikes   = convert_cells_to_dyns(descriptionArray(indSpikes, :)');
descriptionNoSpikes   = convert_cells_to_dyns(descriptionArray(indNoSpikes, :)');

% remove 1st volume to account for steady-state transition
matrixSpikes(:,:,:,1)   = [];
descriptionSpikes(:,:,:,1) = [];
matrixNoSpikes(:,:,:,1) = [];
descriptionNoSpikes(:,:,:,1) = [];

imageSpikes         = MrImage(matrixSpikes);
imageNoSpikes       = MrImage(matrixNoSpikes);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageSpikes.name = 'imageSpikes';
% static plot
imageSpikes.plot('t', 1:imageSpikes.dimInfo.t.nSamples, ...
    'sliceDimension', 't', 'signalPart', 'abs');
plot(imageSpikes.snr);
% dynamic plot
imageSpikes.plot('useSlider', true, 'signalPart', 'abs');

imageNoSpikes.name = 'imageNoSpikes';
imageNoSpikes.plot('t', 1:imageNoSpikes.dimInfo.t.nSamples, ...
    'sliceDimension', 't', 'signalPart', 'abs');
plot(imageSpikes.snr);
imageNoSpikes.plot('useSlider', true, 'signalPart', 'abs');

diffSpikes          = imageSpikes - mean(imageSpikes);
diffSpikes.name     = 'diffSpikes';
diffNoSpikes        = imageNoSpikes - mean(imageNoSpikes);
diffNoSpikes.name   = 'diffNoSpikes';

diffSpikes.plot('t', 1:diffSpikes.dimInfo.t.nSamples, ...
    'sliceDimension', 't', 'signalPart', 'abs');
diffNoSpikes.plot('t', 1:diffNoSpikes.dimInfo.t.nSamples, ...
    'sliceDimension', 't', 'signalPart', 'abs');

deltaImageSpikes = abs(abs(imageSpikes) - abs(imageNoSpikes));
deltaImageSpikes.name = 'deltaImageSpikes';
deltaImageSpikes.plot('t', 1:diffSpikes.dimInfo.t.nSamples, ...
    'sliceDimension', 't');


kNoSpikes = abs(image2k(imageNoSpikes));
diffK = abs(kNoSpikes - mean(kNoSpikes)).^0.1;
diffK.plot('fixedWithinFigure', 'slice', 'selectedVolumes', Inf, ...
    'signalPart', 'abs');
