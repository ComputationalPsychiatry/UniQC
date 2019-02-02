% Script qc_multiband
% Exemplify Quality Control for multiband sequence *after* acquisition
%
%  qc_multiband
%
%
%   See also

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-02-01
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
%% Load data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjectIdArray = [55, 101,102]';
nSubjects = numel(subjectIdArray);

maskThreshold = 300; % signal intensity of mean
doRealign = true;
%% TODO: coregister 3 subjects to each other to have similar slices referenced to!

for s=1:nSubjects
    
    subjectId = subjectIdArray(s);
    
    fileData = sprintf('C:/Users/kasperla/Documents/Temp/COMPI_QC/Results/s%d/s%d-run1.nii', ...
        subjectId, subjectId);
    
    X = MrImage(fileData);
    
    %% Basic quality measures on raw data - plot
    
    if doRealign
        X = X.realign();
    end
    
    X.mean.plot('displayRange', [0 1200], 'colorBar', 'on')
    X.std.plot('displayRange', [0 100], 'colorBar', 'on')
    X.snr.plot('displayRange', [0 50], 'colorBar', 'on')
    
    %% Find nice masks
    M = X.mean.binarize(maskThreshold).imerode.imfill;
    M.name = sprintf('Mask s%d for snr analyis',subjectId);
    M.plot;
    
    %% compute basic ROI analysis
    snr = X.snr;
    snr.extract_rois(M);
    snr.compute_roi_stats();
    snr.rois{1}.plot('selectedSlices', 5:35)
    
    XArray{s} = X;
    snrArray{s} = snr;
    maskArray{s} = M;
    stdArray{s} = X.std;
    meanArray{s} = X.mean;
    
end

%% Save figures;
doSaveFig = true;
if doSaveFig
    pathSaveFig =  'C:\Users\kasperla\polybox\Collaborations\COMPI\QC_new_gradient_coil_Jan2019';
    if doRealign
        pathSaveFig = fullfile(pathSaveFig, 'realigned');
    else
        pathSaveFig = fullfile(pathSaveFig, 'raw');
    end
    save_fig('fh', [1:18], 'pathSave',pathSaveFig, 'doPrefixFigNumber', false, 'imageType', 'fig')
    save_fig('fh', [1:18], 'pathSave',pathSaveFig, 'doPrefixFigNumber', false, 'imageType', 'png')
end

%% Slice leakage for 2 slices via crosscorrelation per voxel
sl1 = 10;
sl2 = 31;
Z = XArray{1};
Z = Z - mean(Z);
X = Z.select('z', sl1);
Y = Z.select('z', sl2);

% cross corr definition! ... could be extended for multiple slices, if
% known, which ones are excited together...then sl1-sl2 gap clear
L = sqrt(sum(X.*Y,'t'))./(std(X).*std(Y));


%% more sophisticated QC specific plots
doMoreSophisticated = false;
if doMoreSophisticated
    X = MrSeries(fileData);
    X.compute_stat_images();
    X.plot_stat_images();
    X.realign();
    X.compute_stat_images();
    X.plot_stat_images();
    
    X.mean.plot
    X.sd.plot
    X.snr.plot
    X.mean.hist(100); ylimit([0 10]);
    X.sd.hist(100)
    X.snr.hist(100)
end
