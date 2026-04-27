function examplePath = tapas_uniqc_get_path_data(exampleID, dataRoot, mustExist)
% tapas_uniqc_get_path_data
%
% Returns the absolute path to a UniQC example dataset.
%
% Usage:
%   p = tapas_uniqc_get_path_data("openneuro_ds004662")
%   p = tapas_uniqc_get_path_data("openneuro_ds004662", "/custom/data/root")
%   p = tapas_uniqc_get_path_data("openneuro_ds004662", [], true)
%
% Inputs:
%   exampleID  : string specifying dataset
%   dataRoot   : root folder (default: <UniQC_root>/data)
%   mustExist  : logical flag (default: false)
%                If true, error if dataset folder does not exist.
%
% Output:
%   examplePath : absolute path to dataset folder

%% ------------------------------------------------------------------------
% Defaults
% -------------------------------------------------------------------------
if nargin < 1 || isempty(exampleID)
    error('You must specify an exampleID. Use tapas_uniqc_download_example_data("info") to list datasets.');
end

if nargin < 2 || isempty(dataRoot)
    thisFile = which('tapas_uniqc_get_path_data');
    uniqcRoot = fileparts(fileparts(fileparts(thisFile))); % '../../'
    dataRoot = fullfile(uniqcRoot, 'data');
end

if nargin < 3 || isempty(mustExist)
    mustExist = false;
end

exampleID = lower(string(exampleID));

%% ------------------------------------------------------------------------
% Registry
% -------------------------------------------------------------------------
registry = availableDatasets();

idx = find(strcmpi(registry.ids, exampleID), 1);

if isempty(idx)
    error('Unknown example dataset: %s\nUse tapas_uniqc_download_example_data("info") to list available datasets.', exampleID);
end

%% ------------------------------------------------------------------------
% Path mapping
% -------------------------------------------------------------------------
switch exampleID

    case "openneuro_ds004662"
        examplePath = fullfile(dataRoot, 'openneuro', 'ds004662');

    % --- Future datasets here ---

    otherwise
        error('Dataset mapping not implemented for: %s', exampleID);
end

examplePath = char(examplePath); % return char for compatibility

%% ------------------------------------------------------------------------
% Existence check
% -------------------------------------------------------------------------
if mustExist && ~exist(examplePath, 'dir')
    error('Example dataset not found at:\n  %s\nRun tapas_uniqc_download_example_data("%s") first.', ...
        examplePath, exampleID);
end

end

%% ========================================================================
function registry = availableDatasets()

registry.ids = [
    "openneuro_ds004662"
];

end