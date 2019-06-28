% Script demo_02_image_algebra
% Exemplifies native image algebra implementation and fast image math/plot concatenation and plotting 
%
%  demo_02_image_algebra
%
% Targets:
%   - integration enables concat, op/plot switching, fast adaptation
% 
%   See also
 
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-01-22
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
%% Load required multi-echo file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rootExample = get_path('example');
folderExample = 'nifti/data_multi_echo2';
pathExample = fullfile(rootExample, folderExample);

X = MrImage(pathExample);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Image Algebra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) tSNR comparison multi-echo data
% 2) ROI Analysis (tSNR)

%% 0. Clean up
close all; 


%% 1. Transition from Demo 01: Compare echoes tSNR
E1 = X.select('echo', 1);
E3 = X.select('echo', 3);

%% Part 1) 
% 2. Compute tSNR in 2 notations: output of operation is again _new_ MrImage
% - enables concatenation, power of object orientation
snr1 = E1.snr('t');
snr3 = snr(E3, 't');

snr1.plot('colorBar', 'on', 'displayRange', [0 100]);

%% 3. Compute tSNR difference 
dSnr = snr1 - snr3;
dSnr.plot()

%% 4. Allows for concatentation and flexible plot/algebra combination
plot(E1.snr('t')-E3.snr('t'), 'colorBar', 'on', 'colorMap', 'hot', 'displayRange', [-10 10])

%% 5. Plot in percent?
plot(dSnr./snr1.*100, 'colorBar', 'on', 'colorMap', 'hot', 'displayRange', [-10 100])




%% Part 2) ROI Analysis tSNR gain

%% 1. Compute relative tSNR gain in percent
snrGain = dSnr./snr1.*100;

%% 2. Trial and error create brain mask
E1.mean('t').plot

% simpler default: takes last dim always -> make this 't'
E1.remove_dims(); % removes empty echo dim
E1.mean.plot;

%% 3. Find treshold of mean
E1.mean.hist(100)
E1.mean.binarize(1000).plot
E1.mean.binarize(800).plot
E1.mean.binarize(500).plot

%% 4. Define mask and preprocess (erosion/dilation)
M = E1.mean.binarize(500);

% erode skull
M.imerode(strel('disk', 4)).plot

% what other methods to process an image exist?
methods(M)

% fill the holes
fM = M.imerode(strel('disk', 4)).imfill('holes');
fM.plot

%% 5. Display resulting mask
E1.mean.plot('overlayImages', fM)

% see what other options to plot
help MrImage.plot

E1.mean.plot('overlayImages', fM, 'overlayMode', 'edge')


%% 6. Extract data from ROI: SNR gain over whole volume
snrGain.extract_rois(fM);
snrGain.compute_roi_stats()
snrGain.rois{1}.plot('dataGrouping', 'perVolume')

%% 7. Details of ROI: SNR gain in specific slices

snrGain.rois{1}.perSlice.mean

snrGain.rois{1}.plot('selectedSlices', [5 20 35])

