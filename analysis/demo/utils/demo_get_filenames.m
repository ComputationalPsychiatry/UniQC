% Script demo_get_filenames
% Shows different use cases for utils/get_filenames to retrieve image files
% from different strings
%
%  demo_get_filenames
%
%
%   See also get_filenames
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-10-21
% Copyright (C) 2016 Institute for Biomedical Engineering
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
%% Set up folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathExamples = get_path('examples');
pathTmp = pwd;

cd(pathExamples);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Try out use-cases and compare with reference results in comments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_filenames(fullfile('nifti', 'rest', 'fmri_short.nii'));
%%       -> {'nifti/rest/fmri_short.nii'} is returned


get_filenames(fullfile('nifti', 'rest'));
%%       -> {'fmri_short.nii'; 'struct.nii'; 'meanfmri.nii'} is returned

isExact = 1;
get_filenames(fullfile('nifti', 'rest', 'f', isExact)
%       -> {} is returned

isExact = 0;
get_filenames(fullfile('nifti', 'rest', 'f'), isExact)
get_filenames(fullfile('nifti', 'rest', 'f*'))
get_filenames(fullfile('nifti', 'rest', 'f.*')
%       -> in all 3 cases, {'funct_short.nii'} is returned

cd(pathTmp);
