% function output = test_perform_binary_operation()
% Unit Test for perform_binary_operation on example dataset
%
%   output = test_perform_binary_operation(input)
%
% IN
%
% OUT
%
% EXAMPLE
%   test_perform_binary_operation
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

%% Load example files

pathExamples = get_path('examples');
fileTest = fullfile(pathExamples, ...
    'resting_state_ingenia_3T/data/funct_short.nii');

S       = MrSeries(fileTest);

S.data.plot();
S.data.plot('selectedSlices', 1, 'selectedVolumes', Inf, ...
    'fixedWithinFigure', 'slice');



%% Perform Test Operations

meanS       = S.data.mean();
meanS.name  = 'meanS';

stdS        = S.data.std();
stdS.name   = 'stdS';

% old compute SNR
snrS1       = S.data.compute_snr();
snrS1.name  = 'snrS1';

% compute SNR via binary operation
snrS2       = meanS./stdS;
snrS2.name  = 'snrS2';


% a somehow self-referring test, since we use perform_binary_operation :-)
deltaSnr    = snrS2 - snrS1;
deltaSnr.name = 'deltaSnr';

relDeltaSnr         = (snrS2 - snrS1)./snrS1;
relDeltaSnr.name    = 'relDeltaSnr';

%% Report and compare to expected results

snrS1.plot;
snrS2.plot

deltaSnr.plot;
relDeltaSnr.plot;

