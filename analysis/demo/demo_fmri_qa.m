% Script demo_fmri_qa
% Performs quality assurance analysis on raw fMRI time series
%
%  demo_fmri_qa
%
%
%   See also
%
% Author:   Sandra Iglesias & Lars Kasper
% Created:  2015-08-13
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
%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specify file with fmri time series (nii, img, mat, par/rec, ...) and 
%  whether realignment shall be performed
%  Hint: perform this script twice, once without and once with realignment to 
%        study the impact of realignment 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
fileRaw = 'tSANTASK_3660S150527_151311_0010_ep2d_bold_physio_2mm_fov224_part2.nii';
doRealign = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load raw data in MrSeries
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
S = MrSeries(fileRaw);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Realign time series, if specified 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if doRealign
S.realign();
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Compute time series statistics (mean, sd, snr) and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.compute_stat_images();

S.mean.plot();
S.sd.plot();
S.snr.plot();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Some more detailed plots, different orientations, plot in SPM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.sd.plot('sliceDimension',1)
S.sd.plot('sliceDimension',2, 'selectedSlices', 50:59)
S.sd.plot('plotType', 'spmi') % plot interactive with SPM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find outliers: Difference Images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S.data.plot('useSlider', true);

% mean difference image
% alternative plot(mean(diff(S.data)))
 S.data.diff.mean.plot
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find outliers: Plot Difference Image interactively
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
 diffData = S.data.diff();
 diffData.name = [S.name ' - ' 'Difference Images (N+1 - N)' ];
 diffData.plot('useSlider', true)

 % plot some difference volumes in detail, with custom display range
diffData.plot('selectedVolumes', 317:325, 'displayRange', [-100,100])


diffData.parameters.save.path = 'figures'; ...
diffData.parameters.save.fileName = [str2fn(diffData.name), '.nii'];
diffData.save;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find outliers: Plot Differences to mean interactively
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

diffMean = S.data - S.mean;
diffMean.name = [S.name ' ' 'Difference to mean'];
% diffMean.plot('useSlider', true)
diffMean.plot('selectedVolumes', [1,360], 'displayRange', ...
    [-100 100], 'sliceDimension',1, 'selectedSlices', 25:96)

diffMean.parameters.save.path = 'figures'; 
diffMean.parameters.save.fileName = [str2fn(diffMean.name), '.nii'];
diffMean.save;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save images to figures folder  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save_fig('fh', 'all', 'imageType', 'fig', 'pathSave', 'figures');
