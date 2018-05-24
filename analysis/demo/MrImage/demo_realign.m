% Script demo_realign
% Shows realignment for n-dimensional data with different scenarios of 4D
% subsets feeding into estimation, and parameters applied to other subsets,
% e.g.
%   - standard 4D MrImageSpm realignment
%   - multi-echo data, 1st echo realigned, applied to all echoes
%   - complex data, magnitude data realigned, phase data also shifted
%   - multi-coil data, root sum of squares realigned, applied to each coil
%
%  demo_realign
%
%
%   See also
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-25
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
% $Id$
%
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. 4D fMRI, real valued, standard realignment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, 'nifti', 'rest', 'fmri_short.nii');

% load data
Y4d = MrImageSpm4D(fileTest);

[~,rp] = Y4d.realign();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2. Complex 4D data - magnitude data used for realignment parameter
%     estimation, phase is realigned accordingly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. Multi-echo data, 1st echo estimates realignment parameters, is applied
%     to all other echoes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% pathData = '/Users/kasperla/polybox/Projects/uniQC/data/multi_echo/20150709_145603BPep2dMEMSTR06525mms013a001.nii';
pathData = '/Users/kasperla/polybox/Projects/uniQC/data/multi_echo/';
dimInfo = MrDimInfo('dimLabels', {'x','y','z','t','echo'}, 'nSamples', ...
    [84 84 48 581 3]);
% load data
YME = MrImageSpm4D(pathData, 'dimInfo', dimInfo);

%[~,rp] = Y4d.realign();
