function results = tapas_uniqc_Poser_ME_example(verbosity, workspaceRoot)
% Runs the Poser echo-combination comparison on the public Reddy subset.
%   results = tapas_uniqc_Poser_ME_example(verbosity, workspaceRoot)
% verbosity: 0 no plots, 1 comparison figures, 2 summary maps, 3 diagnostics.
% workspaceRoot: writable scratch folder (preferably outside OneDrive).
% Download first: tapas_uniqc_download_example_data('openneuro_ds004662')
% See POSER_ME_EXAMPLE.md for interpretation and differences from the paper.
% See also tapas_uniqc_Poser_ME_example_func
%
% Copyright (C) 2026 UniQC developers. GNU GPL version 3 or later.

if nargin < 1, verbosity = 1; end
if nargin < 2
    workspaceRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end
% Same subject/run subset as the Reddy wrapper and download function.
subjectRunPairs = [3 1; 4 1; 8 2; 1 2];
results = cell(size(subjectRunPairs, 1), 1);
for iPair = 1:size(subjectRunPairs, 1)
    results{iPair} = tapas_uniqc_Poser_ME_example_func( ...
        subjectRunPairs(iPair, 1), subjectRunPairs(iPair, 2), ...
        verbosity, workspaceRoot);
end
end
