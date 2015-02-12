%function output = test_iteration_plots(input)
% Shows Visualization capabilities of MrImage for ReconstructionData
%
%   output = test_iteration_plots(input)
%
% LONG_DESCRIPTION
%
% IN
%
% OUT
%
% EXAMPLE
%   test_iteration_plots
%
%   See also
%
% Author: Lars Kasper
% Created: 2014-11-30
% Copyright (c) kasper/ibt_2014/university and eth zurich, switzerland
% $Id: tedit.m 889 2014-07-30 17:12:32Z lkasper $



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup files and load Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathRecon = ['/usr/ibtnas02/data-05/kasperla/MatchedFilterSpiral/data' ...
    '/LK334_14_12_02_MFSSpeedPhantomSpiky_10' ...
    '/reconstructions/arrays_spike_correction_3/'];
fileRecon = 'recon_FullTest_speedspi35_1';
fileRecon = fullfile(pathRecon, fileRecon);

doReloadRecon = true;

if doReloadRecon || ~exist('recon', 'var')
    load(fileRecon);
    recon = reconArray{1,2,2,2};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot video of iterations, difference images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

it  = recon2image(recon, 'iterations');
it.plot('useSlider', true, 'signalPart', 'abs');

dit = diff(it);

dit.plot('signalPart', 'abs', 'selectedVolumes', 1:80, ...
    'fixedWithinFigure', 'slices', 'plotMode', 'log');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot video of differences
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dit.plot('useSlider', true, 'signalPart', 'abs');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot scaled video of differences in image space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dit01 = dit.^0.1;

dit01.plot('useSlider', true, 'signalPart', 'abs');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot scaled video of differences in k-space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dkit01 = diff(abs(image2k(it))).^0.1;

dkit01.plot('useSlider', true, 'signalPart', 'abs');
