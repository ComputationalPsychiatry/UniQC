function tapas_uniqc_Reddy_ME_example(verbosity)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UniQC Multi-Echo Example Wrapper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Runs the Reddy multi-echo example for the same subject/run subset as
% selected in the OpenNeuro ds004662 example-data download function.
%
% Inputs:
%   verbosity - 0: no plots, 1: summary figure, 2: all plots

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2026-04-27
% Copyright (C) 2026 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 1
    verbosity = 1;
end

% Keep this list aligned with
% tapas_uniqc_download_example_data_openneuro_ds004662
subjectRunPairs = {
    3, 1
    4, 1
    8, 2
    1, 2
    };

nPairs = size(subjectRunPairs, 1);
for iPair = 1%:nPairs
    subID = subjectRunPairs{iPair, 1};
    run = subjectRunPairs{iPair, 2};
    
    fprintf('\n============================================================\n');
    fprintf('Running Reddy multi-echo example for sub-%02d run-%01d\n', ...
        subID, run);
    fprintf('============================================================\n');
    
    tapas_uniqc_Reddy_ME_example_func(subID, run, verbosity);
end

end
